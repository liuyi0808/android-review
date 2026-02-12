#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
PLUGIN_JSON=".claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# --- Validation -----------------------------------------------------------

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 VERSION  (e.g. 1.1.0)"
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: version must be semver (X.Y.Z), got: $VERSION"
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [[ "$BRANCH" != "main" ]]; then
  echo "Error: must be on main branch (currently on $BRANCH)"
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: working tree is not clean — commit or stash first"
  exit 1
fi

# --- Version bump ---------------------------------------------------------

OLD=$(grep -oE '"version": *"[^"]*"' "$PLUGIN_JSON" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Bumping version: $OLD -> $VERSION"

sed -i '' "s/\"version\": *\"$OLD\"/\"version\": \"$VERSION\"/" "$PLUGIN_JSON"
sed -i '' "s/\"version\": *\"$OLD\"/\"version\": \"$VERSION\"/" "$MARKETPLACE_JSON"

git add "$PLUGIN_JSON" "$MARKETPLACE_JSON"
git commit -m "chore: release v$VERSION"
git tag "v$VERSION"
git push origin main "v$VERSION"

echo ""
echo "Released v$VERSION"
echo "https://github.com/liuyi0808/android-review/releases/tag/v$VERSION"
