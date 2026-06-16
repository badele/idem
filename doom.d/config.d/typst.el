;;; config.d/typst.el -*- lexical-binding: t; -*-

(after! treesit
  (add-to-list
   'treesit-language-source-alist
   '(typst "https://github.com/uben0/tree-sitter-typst"))

  ;; compile the grammar if it is not already installed
  (unless (treesit-language-available-p 'typst)
    (message "Installing tree-sitter grammar for Typst...")
    (treesit-install-language-grammar 'typst)))

(use-package! typst-ts-mode
  :mode "\\.typ\\'"
  :custom
  (typst-ts-watch-options '("--open"))
  (typst-ts-mode-enable-raw-blocks-highlight t)
  :config
  (keymap-set typst-ts-mode-map "C-c C-c" #'typst-ts-tmenu))

(with-eval-after-load 'eglot
  (with-eval-after-load 'typst-ts-mode
    (add-to-list 'eglot-server-programs
                 `((typst-ts-mode) .
                   ,(eglot-alternatives `(,typst-ts-lsp-download-path
                                          "tinymist"
                                          "typst-lsp"))))))
