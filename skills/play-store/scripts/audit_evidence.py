"""Collect permission and literal-credential evidence without printing source values."""

import argparse
import json
import os
from pathlib import Path
import re
import sys
from xml.parsers import expat


ANDROID = 'http://schemas.android.com/apk/res/android|'
TOOLS = 'http://schemas.android.com/tools|'
PERMISSION_ELEMENTS = {'uses-permission', 'uses-permission-sdk-23', 'uses-permission-sdk-m'}
IGNORED_DIRECTORIES = {'build', 'generated', 'test', 'tests', 'androidTest', 'testFixtures', 'node_modules'}
SOURCE_SUFFIXES = {'.kt', '.java', '.kts', '.gradle'}
CREDENTIAL_NAMES = {
    'apikey', 'apisecret', 'apisign', 'authtoken', 'accesstoken', 'refreshtoken',
    'clientsecret', 'password', 'secret', 'secretkey', 'privatekey', 'token',
    'storepassword', 'keypassword',
}
SIGNING_NAMES = {'storepassword', 'keypassword'}
PLACEHOLDERS = {'changeme', 'replace_me', 'placeholder', 'dummy', 'redacted', 'todo'}
TOKEN = re.compile(
    r'(?P<comment>//[^\n]*|/\*[\s\S]*?\*/)|'
    r'(?P<string>"""[\s\S]*?"""|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\')|'
    r'(?P<word>[A-Za-z_][A-Za-z_0-9]*)|(?P<punctuation>[^\s])'
)


def get_permission_evidence(path: Path) -> list:
    parser = expat.ParserCreate(namespace_separator='|')
    stack = []
    evidence = []

    def start_element(element: str, attributes: dict) -> None:
        if not stack and element != 'manifest':
            raise ValueError('expected an Android <manifest> root')
        if stack == ['manifest'] and element in PERMISSION_ELEMENTS:
            permission = attributes.get(ANDROID + 'name', '')
            removed = attributes.get(TOOLS + 'node') in {'remove', 'removeAll'}
            if re.fullmatch(r'android\.permission\.[A-Z_0-9]+', permission):
                flags = attributes.get(ANDROID + 'usesPermissionFlags', '').split('|')
                details = ' android:usesPermissionFlags="onlyForLocationButton"' if (
                    'onlyForLocationButton' in {flag.strip() for flag in flags}
                ) else ''
                kind = 'removed' if removed else 'declared'
                evidence.append(f'{kind}\t{parser.CurrentLineNumber}: {permission}{details}')
            elif attributes.get(TOOLS + 'node') == 'removeAll':
                evidence.append(f'removed\t{parser.CurrentLineNumber}: {element} (removeAll)')
        stack.append(element)

    def end_element(_element: str) -> None:
        stack.pop()

    def reject_doctype(*_arguments) -> None:
        raise ValueError('DOCTYPE is unsupported')

    parser.StartElementHandler = start_element
    parser.EndElementHandler = end_element
    parser.StartDoctypeDeclHandler = reject_doctype
    with path.open('rb') as manifest:
        parser.ParseFile(manifest)
    return evidence


def get_literal(token: str, allows_interpolation: bool) -> str:
    if token.startswith('"""') and token.endswith('"""'):
        value = token[3:-3]
    elif len(token) >= 2 and token[0] == token[-1] and token[0] in {'"', "'"}:
        value = token[1:-1]
    else:
        return ''
    if allows_interpolation and token[0] == '"' and re.search(r'(?<!\\)\$(?:\{|[A-Za-z_])', value):
        return ''
    return value.strip()


def get_value_index(tokens: list, index: int, gradle: bool) -> int:
    if tokens[index + 1] == ':':
        index += 2
        if tokens[index + 1] == '?':
            index += 1
    if tokens[index + 1] == '=':
        return index + 2
    if gradle and tokens[index + 1] == '(' and tokens[index + 3] == ')':
        return index + 2
    if gradle:
        return index + 1
    return -1


def get_embedded_literal(tokens: list, index: int) -> tuple:
    if tokens[index + 1:index + 4] != ['(', '"String"', ','] or tokens[index + 5] != ',':
        return '', ''
    name = get_literal(tokens[index + 4], False).replace('_', '').lower()
    expression = tokens[index + 6]
    if tokens[index + 7] != ')' or not get_literal(expression, True):
        return '', ''
    try:
        java_literal = json.loads(expression)
    except ValueError:
        return '', ''
    return name, get_literal(java_literal, False)


def scan_credentials(path: Path) -> None:
    text = path.read_text(encoding='utf-8', errors='replace')
    matches = [match for match in TOKEN.finditer(text) if match.lastgroup != 'comment']
    tokens = [match.group() for match in matches] + [''] * 8
    gradle = path.name.endswith(('.gradle', '.gradle.kts'))
    for index, match in enumerate(matches):
        name = tokens[index].replace('_', '').lower()
        if gradle and name == 'buildconfigfield':
            name, value = get_embedded_literal(tokens, index)
            kind = 'embedded'
        elif name in CREDENTIAL_NAMES:
            if path.suffix == '.kt' and index > 0 and tokens[index - 1] in {'(', ','}:
                # Named call arguments can be preview data or public parameter names.
                continue
            kind = 'signing' if gradle and name in SIGNING_NAMES else 'credential'
            value_index = get_value_index(tokens, index, gradle)
            if value_index < 0 or tokens[value_index + 1] in {'+', '.', '?', 'as'}:
                continue
            value = get_literal(tokens[value_index], path.suffix != '.java')
            if tokens[value_index].startswith("'") and path.suffix != '.gradle':
                continue
        else:
            continue
        if name in CREDENTIAL_NAMES and value and value.lower() not in PLACEHOLDERS:
            if value.replace('_', '').lower() == name:
                continue
            line = text.count('\n', 0, match.start()) + 1
            print(f'{kind}\t{path}:{line} [literal redacted]')


def scan_project(root: Path) -> None:
    def raise_walk_error(error: OSError) -> None:
        raise error

    for directory, subdirectories, filenames in os.walk(root, onerror=raise_walk_error):
        subdirectories[:] = sorted(
            name for name in subdirectories if name not in IGNORED_DIRECTORIES and not name.startswith('.')
        )
        for filename in sorted(filenames):
            path = Path(directory) / filename
            if path.suffix in SOURCE_SUFFIXES and not path.is_symlink():
                scan_credentials(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['manifest', 'credentials'])
    parser.add_argument('path', type=Path)
    args = parser.parse_args()
    try:
        if args.mode == 'manifest':
            for row in get_permission_evidence(args.path):
                print(row)
        else:
            scan_project(args.path)
    except (OSError, ValueError, expat.ExpatError) as error:
        print(f'ERROR: Cannot read {args.mode} evidence from {args.path}: {error}', file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
