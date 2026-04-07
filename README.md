kickstart.doom

Minimal Doom Emacs kickstart layout. This repository keeps your private DOOMDIR
small and reproducible, and bootstraps Doom core separately.

Layout

- bootstrap/doom-install.sh - Bootstrap Doom core and sync
- doom.d/ - Doom configuration (init.el, config.el, packages.el)
- doom-version.txt - pinned Doom core ref

Quick start

1. Set your Doom pin in doom-version.txt.
2. Run the bootstrap script: ./bootstrap/doom-install.sh

Defaults

- DOOMDIR: $HOME/.config/doom
- EMACSDIR: $HOME/.config/emacs

Overrides

- DOOMDIR=/path/to/doomdir EMACSDIR=/path/to/emacs.d ./bootstrap/doom-install.sh

Multiple profiles

- DOOMDIR="$HOME/.config/doom-kickstart" emacs
- DOOMDIR="$HOME/.config/doom-kickstart" "$HOME/.emacs.d/bin/doom" sync

Pins and lockfile

- doom-version.txt: Doom core ref (commit, tag, or branch).

Notes

- The bootstrap script replaces the DOOMDIR contents.
- Re-run ./bootstrap/doom-install.sh after changing files in doom.d/.
