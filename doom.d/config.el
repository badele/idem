;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define font and mouse cursor (must load first)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq doom-font
      (cond
       ((find-font (font-spec :family "Fira Mono"))
        (font-spec :family "Fira Mono" :size 14))
       ((find-font (font-spec :family "JetBrains Mono"))
        (font-spec :family "JetBrains Mono" :size 14))
       (t
        (font-spec :family "monospace" :size 14))))

(when (display-graphic-p)
  (setq x-pointer-shape 132)
  (set-mouse-color "white")
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define editor UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq doom-theme 'doom-tokyo-night)

;; disable perspective auto-restore (because I use it with emacsclient and it causes issues
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;; define french locale
;; (set-locale-environment "fr_FR.UTF-8")
(setq system-time-locale "fr_FR.UTF-8")

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; save cursor position in file
(save-place-mode +1)

(setq-default tab-width 2)
(setq-default standard-indent 2)

;; Show color for the hexadecimal or color name
(use-package! colorful-mode
  :hook ((prog-mode text-mode conf-mode) . colorful-mode))

;; display line number
(setq display-line-numbers-type t)

;; display vertical indentation bar
(use-package! indent-bars
  :hook (prog-mode . indent-bars-mode)
  :config
  (setq indent-bars-prefer-character t)
  (setq indent-bars-no-stipple-char ?│)

  ;; for terminal
  (setq indent-bars-unspecified-bg-color "#000000")
  (setq indent-bars-unspecified-fg-color "#c0c0c0")

  ;; barres normales
  (setq indent-bars-color '(highlight :face-bg t :blend 0.25))

  ;; highlight depth
  (setq indent-bars-highlight-current-depth
        '(:face default  :blend 1.0))

  (setq indent-bars-highlight-selection-method 'context))

(use-package copilot
  :ensure t
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion)
              ("C-<tab>" . copilot-accept-completion-by-word)
              ("C-TAB" . copilot-accept-completion-by-word)
              ("C-n" . copilot-next-completion)
              ("C-p" . copilot-previous-completion)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dahsboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(after! recentf
  (add-to-list 'recentf-exclude "/\\.local/"))

(defun my/center-ansi-line (line width)
  "Centre une ligne ANSI dans WIDTH colonnes."
  (let* ((clean (replace-regexp-in-string "\x1b\\[[0-9;]*m" "" line))
         (len (string-width clean))
         (padding (/ (max 0 (- width len)) 2)))
    (concat (make-string padding ?\s) line)))

(defun my/insert-centered-ansi-banner (file)
  (require 'ansi-color)
  (let ((width (window-width))
        (start (point)))
    (dolist (line (split-string
                   (with-temp-buffer
                     (insert-file-contents file)
                     (buffer-string))
                   "\n"))
      (insert (my/center-ansi-line line width) "\n"))
    (ansi-color-apply-on-region start (point))))

(use-package! dashboard
  :config
  (setq dashboard-startup-banner 'ascii
        dashboard-banner-ascii " "
        dashboard-items
        '((recents  . 5)
          (projects . 5)
          (agenda   . 5)))


  (advice-add 'dashboard-insert-banner :override
              (lambda ()
                (my/insert-centered-ansi-banner
                 "~/.config/doom/logo.ans")))

  (dashboard-setup-startup-hook))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; On Terminal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; clipboard
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File & Folders
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq locate-command "plocate %s %s")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rebinding
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Save file with CTRL+S
(defun my/save-buffer-and-exit-insert ()
  "Save current buffer, then leave insert mode."
  (interactive)
  (save-buffer)
  (when (and (bound-and-true-p evil-local-mode)
             (evil-insert-state-p))
    (evil-normal-state)))

(map! :n "C-s" #'save-buffer
      :i "C-s" #'my/save-buffer-and-exit-insert
      :v "C-s" #'save-buffer)

;; confirm kill emacs (only if file not saved)
(defun my-confirm-kill-emacs (_prompt)
  (not (cl-some
        (lambda (buf)
          (and (buffer-file-name buf)
               (buffer-modified-p buf)))
        (buffer-list))))

(setq confirm-kill-emacs #'my-confirm-kill-emacs)

;; Toggle inlay hint (show function parameter names)
(after! eglot
  (map! :map eglot-mode-map
        :leader
        :desc "Toggle Eglot inlay hints"
        "t h" #'eglot-inlay-hints-mode))

(map! :leader
      :desc "Find file with fd"
      "p f" #'consult-fd)

(map! :leader
      :desc "Find file with fd"
      "SPC" #'consult-fd)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; neotex mode =================================================================
(define-derived-mode neo-mode text-mode "Neotex"
  "Major mode for .neo files.")
(add-to-list 'auto-mode-alist '("\\.neo\\'" . neo-mode))

(defconst my/neo--whitespace-fns
  '(delete-trailing-whitespace
    whitespace-cleanup
    whitespace-cleanup-region
    ws-butler-before-save))

(defun my/neo--skip-whitespace-cleanup (orig &rest args)
  (unless (derived-mode-p 'neo-mode)
    (apply orig args)))

(dolist (fn '(delete-trailing-whitespace
              whitespace-cleanup
              whitespace-cleanup-region))
  (advice-add fn :around #'my/neo--skip-whitespace-cleanup))

(after! ws-butler
  (advice-add 'ws-butler-before-save :around #'my/neo--skip-whitespace-cleanup)
  (add-to-list 'ws-butler-global-exempt-modes 'neo-mode))

(defun my/neo--setup ()
  (setq-local +format-inhibit t)
  (setq-local show-trailing-whitespace t)
  (when (bound-and-true-p whitespace-mode)
    (whitespace-mode -1))
  (when (bound-and-true-p ws-butler-mode)
    (ws-butler-mode -1))
  (remove-hook 'write-file-functions #'whitespace-write-file-hook t)
  (let ((hook (copy-sequence before-save-hook)))
    (dolist (fn my/neo--whitespace-fns)
      (setq hook (delq fn hook)))
    (setq-local before-save-hook hook)))

(add-hook 'neo-mode-hook #'my/neo--setup)

(load! "config.d/markdown")
(load! "config.d/org")
(load! "config.d/typst")

(after! apheleia
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'gfm-mode apheleia-mode-alist) 'prettier))

;; Python ======================================================================
(setq-hook! 'python-ts-mode-hook fill-column 88)
(after! apheleia
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(isort black)))
