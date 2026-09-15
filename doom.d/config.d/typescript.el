;;; config.d/typescript.el -*- lexical-binding: t; -*-

(after! typescript-ts-mode
  (setq-hook! 'typescript-ts-mode-hook fill-column 100)
  (setq-hook! 'tsx-ts-mode-hook fill-column 100))

(after! apheleia
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) 'prettier))

(with-eval-after-load 'eglot
  (with-eval-after-load 'typescript-ts-mode
    (add-to-list 'eglot-server-programs
                 '((typescript-ts-mode tsx-ts-mode js-ts-mode)
                   . ("typescript-language-server" "--stdio")))
    (add-to-list 'eglot-server-programs
                 '((typescript-ts-mode tsx-ts-mode js-ts-mode)
                   . ("vscode-eslint-language-server" "--stdio"
                      :initializationOptions (:nodePath ""))))))
