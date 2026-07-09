#!/usr/bin/env bash
set -euo pipefail

# Install the android-review skills into Codex CLI.
#
# Codex CLI discovers skills from ~/.codex/skills/<name>/SKILL.md. This script
# links each skill folder from this repo into that directory so the six review
# skills become available. skills/ stays the single source of truth — links mean
# a `git pull` here updates Codex with no reinstall.
#
# Usage:
#   scripts/install-codex.sh            # symlink (default)
#   scripts/install-codex.sh --copy     # copy instead of symlink
#   CODEX_HOME=/custom scripts/install-codex.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

MODE="symlink"
if [[ "${1:-}" == "--copy" ]]; then
  MODE="copy"
elif [[ -n "${1:-}" ]]; then
  echo "Error: unknown argument '$1' (expected --copy or nothing)"
  exit 1
fi

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "Error: skills directory not found at $SKILLS_SRC"
  exit 1
fi

mkdir -p "$CODEX_SKILLS_DIR"

installed=0
for skill_dir in "$SKILLS_SRC"/*/; do
  [[ -f "${skill_dir}SKILL.md" ]] || continue
  name="$(basename "$skill_dir")"
  target="$CODEX_SKILLS_DIR/$name"

  # Remove any prior install (link or directory) so re-runs are clean.
  if [[ -L "$target" || -e "$target" ]]; then
    rm -rf "$target"
  fi

  if [[ "$MODE" == "copy" ]]; then
    cp -R "${skill_dir%/}" "$target"
    echo "copied  $name -> $target"
  else
    ln -s "${skill_dir%/}" "$target"
    echo "linked  $name -> $target"
  fi
  installed=$((installed + 1))
done

echo ""
echo "Installed $installed skill(s) into $CODEX_SKILLS_DIR"
echo "Restart Codex CLI, then confirm the skills appear in its available-skills list."
