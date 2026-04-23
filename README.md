# idem

Welcome to my personalized Doom Emacs configuration! This configuration is
tailored primarily for DevOps tasks but can also be utilized by developers
working with languages like Go, Python, Rust, Nix, Scala, Terraform,
TypeScript, and more.

I've aimed to streamline the installation process by creating a bootstrap script
and a `flake.nix` for Nix-based dependency management.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

**Table of Contents**

- [idem](#idem)
  - [Features](#features)
  - [Modules](#modules)
  - [Language support](#language-support)
    - [Fully supported](#fully-supported)
    - [Not tested](#not-tested)
    - [Partially supported](#partially-supported)
  - [Keybinding](#keybinding)
  - [Installation](#installation)
    - [Quick install](#quick-install)
    - [Overrides](#overrides)
    - [Multiple profiles](#multiple-profiles)
    - [Pins and lockfile](#pins-and-lockfile)
  - [Layout](#layout)
  - [TODO](#todo)
  - [Credits](#credits)

<!-- markdown-toc end -->

## Features

- **DevOps-Centric:** This Doom Emacs setup is optimized for DevOps workflows,
  enhancing your efficiency in tasks related to infrastructure (Terraform,
  Docker, Ansible), automation, and more.
- **Developer-Friendly:** Even if you're a developer working with various
  programming languages such as Go, Haskell, JavaScript, JSON, LaTeX, Lua, Nix,
  Python, Rust, Scala, Shell, TypeScript, YAML, etc., this configuration has you
  covered.

## Modules

- **Completion**
  - Completion engine [corfu](https://github.com/minad/corfu) (+orderless)
  - Incremental narrowing [vertico](https://github.com/minad/vertico)
- **Appearance**
  - A clean, dark colorscheme
    [doom-tokyo-night](https://github.com/doomemacs/themes)
  - A custom ANSI dashboard with
    [emacs-dashboard](https://github.com/emacs-dashboard/emacs-dashboard)
  - Status line [doom-modeline](https://github.com/seagle0128/doom-modeline)
  - Tab bar [centaur-tabs](https://github.com/ema2159/centaur-tabs)
  - Project drawer [treemacs](https://github.com/Alexander-Miller/treemacs)
    (+lsp)
  - Indent guides
    [indent-bars](https://github.com/jdtsmith/indent-bars)
  - VCS diff in the fringe [vc-gutter](https://github.com/doomemacs/doomemacs)
    (+pretty)
  - Color preview
    [colorful-mode](https://github.com/DevelopmentCool2449/colorful-mode)
- **Editor**
  - Vim emulation [evil](https://github.com/emacs-evil/evil) (+everywhere)
  - Format on save [format](https://github.com/doomemacs/doomemacs) (+onsave)
  - Code folding, file templates, snippets
  - Whitespace management (+guess +trim)
- **IDE**
  - Git porcelain [magit](https://github.com/magit/magit) (+forge)
  - LSP via [eglot](https://github.com/joaotavora/eglot)
  - Syntax highlighting
    [tree-sitter](https://github.com/emacs-tree-sitter/elisp-tree-sitter)
  - Syntax checker [flycheck](https://github.com/flycheck/flycheck)
  - Debugger [dap-mode](https://github.com/emacs-lsp/dap-mode)
  - AI [GitHub Copilot](https://github.com/copilot-emacs/copilot.el)
  - Search [deadgrep](https://github.com/Wilfred/deadgrep),
    [wgrep](https://github.com/mhayashi1120/Emacs-wgrep)
  - Terminal [vterm](https://github.com/akermu/emacs-libvterm)
- **Tools**
  - Ansible, Docker (+lsp +tree-sitter), Terraform (+lsp)
  - direnv, editorconfig, pass
  - make (run make tasks from Emacs)
- **Emacs**
  - dired, tramp, undo, vc
  - Clipboard support
    [clipetty](https://github.com/spudlyo/clipetty)

## Language support

To add or remove a language, you need to modify the following files:

- `./flake.nix`
- `./doom.d/init.el`
- `./doom.d/config.el` (for language-specific formatting/settings)

Doom module reference:

- [Doom Modules Index](https://github.com/doomemacs/doomemacs/blob/master/docs/modules.org)

The below table shows the languages fully supported (LSP, highlighting, format,
lint/diagnostic, completion, action).

### Fully supported

<!-- markdownlint-disable MD013 -->

| Language   | LSP | HL  | FO  | Lint | cmp | CA  | Doom module                                       |
| ---------- | :-: | :-: | :-: | :--: | :-: | :-: | ------------------------------------------------- |
| emacs-lisp | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `emacs-lisp` (native)                             |
| markdown   | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(markdown +tree-sitter +grip)`, prettier, pandoc |
| nix        | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(nix +lsp +tree-sitter)`                         |
| python     | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(python +lsp +tree-sitter +poetry +pyright +uv)` |
| yaml       | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(yaml +lsp +tree-sitter)`                        |

<!-- markdownlint-enable MD013 -->

### Not tested

<!-- markdownlint-disable MD013 -->

| Language   | LSP | HL  | FO  | Lint | cmp | CA  | Doom module                                   |
| ---------- | :-: | :-: | :-: | :--: | :-: | :-: | --------------------------------------------- |
| docker     | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `docker (+lsp +tree-sitter)`                  |
| go         | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(go +lsp +tree-sitter)`                      |
| graphql    | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(graphql +lsp +tree-sitter)`                 |
| haskell    | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(haskell +lsp +tree-sitter)`                 |
| javascript | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(javascript +lsp +tree-sitter)`              |
| json       | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(json +lsp +tree-sitter)`                    |
| latex      | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(latex +cdlatex +fold +lsp)`                 |
| lua        | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(lua +lsp +tree-sitter +fennel +moonscript)` |
| rust       | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(rust +lsp +tree-sitter)`                    |
| scala      | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(scala +lsp +tree-sitter)`                   |
| shell      | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(sh +fish +lsp)`                             |
| terraform  | ✅  | ✅  | ✅  |  ✅  | ✅  | ✅  | `(terraform +lsp)`                            |

<!-- markdownlint-enable MD013 -->

### Partially supported

<!-- markdownlint-disable MD013 -->

| Language | LSP | HL  | FO  | Lint | cmp | CA  | Doom module                                                                       |
| -------- | :-: | :-: | :-: | :--: | :-: | :-: | --------------------------------------------------------------------------------- |
| ansible  | ✅  | ✅  | ❌  |  ✅  | ✅  | ❌  | `ansible`                                                                         |
| data     | ❌  | ✅  | ❌  |  ❌  | ❌  | ❌  | `data` (config/data formats)                                                      |
| graphviz | ❌  | ✅  | ❌  |  ❌  | ❌  | ❌  | `graphviz`                                                                        |
| ledger   | ❌  | ✅  | ❌  |  ❌  | ❌  | ❌  | `ledger`                                                                          |
| neotex   | ❌  | ❌  | ❌  |  ❌  | ❌  | ❌  | `neo-mode` (custom text-mode in config.el)                                        |
| org      | ✅  | ✅  | ✅  |  ❌  | ✅  | ✅  | `(org +dragndrop +crypt +gnuplot +journal +jupyter +noter +pandoc +pretty +roam)` |

<!-- markdownlint-enable MD013 -->

**Legend:**
`LSP` - Language Server Protocol
`HL` - Highlighting
`FO` - Format
`Lint` - Linting
`cmp` - Completion
`CA` - Code Action

## Keybinding

Main keybinding with `SPC` (leader key, Evil mode):

| Key       | Category                         |
| --------- | -------------------------------- |
| `SPC t h` | Toggle Eglot inlay hints         |
| `SPC p f` | Find file with fd (consult-fd)   |
| `C-s`     | Save buffer (+ exit insert mode) |

Copilot bindings (in `prog-mode`):

| Key     | Action                    |
| ------- | ------------------------- |
| `TAB`   | Accept completion         |
| `C-TAB` | Accept completion by word |
| `C-n`   | Next completion           |
| `C-p`   | Previous completion       |

## Installation

### Quick install

1. [OPTIONAL] `nix develop`
2. Set your Doom pin in `doom-version.txt`
3. Run the bootstrap script: `./bootstrap/doom-install.sh`
4. Check requirements: `./check.sh`
5. Check Emacs configuration: `doom doctor`

### Overrides

```shell
DOOMDIR=/path/to/doomdir EMACSDIR=/path/to/emacs.d ./bootstrap/doom-install.sh
```

Defaults:

- `DOOMDIR: $HOME/.config/doom`
- `EMACSDIR: $HOME/.config/emacs`

### Multiple profiles

```shell
DOOMDIR="$HOME/.config/doom-kickstart" emacs
DOOMDIR="$HOME/.config/doom-kickstart" "$HOME/.emacs.d/bin/doom" sync
```

### Pins and lockfile

- `doom-version.txt`: Doom core ref (commit, tag, or branch).

## Layout

```text
bootstrap/doom-install.sh   Bootstrap Doom core and sync
doom.d/                     Doom configuration directory
  init.el                   Module declarations
  config.el                 User configuration
  packages.el               Extra package declarations
doom-version.txt            Pinned Doom core ref
flake.nix                   Nix flake for dependencies
check.sh                    Requirements checker
```

**Notes:**

- The bootstrap script links DOOMDIR to this repo's `doom.d/`.
- If DOOMDIR exists as a directory, it is renamed to
  `DOOMDIR-YYYYmmdd-HHMMSS.bak`.
- Re-run `doom sync` after changing `doom.d/init.el` or `doom.d/packages.el`.

## TODO

- [ ] org
- [ ] plantuml support
- [ ] calendar integration
- [ ] everywhere (edit anywhere with Emacs)
- [ ] irc client
- [ ] rss reader (+org)

## Credits

Many configuration patterns come from the following projects, thanks to the
contributors:

- [Doom Emacs](https://github.com/doomemacs/doomemacs)
