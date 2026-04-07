#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Params
################################################################################

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOOM_REPO="${DOOM_REPO:-https://github.com/doomemacs/doomemacs}"

EMACSDIR="${EMACSDIR:-$HOME/.config/emacs}"
DOOMDIR="${DOOMDIR:-$HOME/.config/doom}"

PIN_FILE="$REPO_ROOT/doom-version.txt"
LOCK_FILE="$REPO_ROOT/default.el"

################################################################################
# Bootstrap code
################################################################################

if [ ! -d "$EMACSDIR" ]; then
    git clone --depth 1 "$DOOM_REPO" "$EMACSDIR"
fi

git -C "$EMACSDIR" fetch --all --tags

if [ -f "$PIN_FILE" ]; then
    DOOM_REF="$(cat "$PIN_FILE")"
    if [ -n "$DOOM_REF" ]; then
        git -C "$EMACSDIR" checkout "$DOOM_REF"
    fi
fi

mkdir -p "$(dirname "$DOOMDIR")"
rm -rf "$DOOMDIR"
cp -a "$REPO_ROOT/doom.d" "$DOOMDIR"

if [ -f "$LOCK_FILE" ]; then
    mkdir -p "$EMACSDIR/.local/straight/versions"
    cp "$LOCK_FILE" "$EMACSDIR/.local/straight/versions/default.el"
fi

export DOOMDIR
"$EMACSDIR/bin/doom" install --force
"$EMACSDIR/bin/doom" sync -u
"$EMACSDIR/bin/doom" doctor
