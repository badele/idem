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
  (set-mouse-color "white"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define editor UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq doom-theme 'doom-tokyo-night)

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

;; enable undo on multiple sessions
;; (use-package! undo-fu-session
;;   :hook ((prog-mode text-mode conf-mode) . undo-fu-session-mode))

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

;; org mode ====================================================================
;; Compute age from BIRTHDAY property and display it in agenda if today is the birthday
(defun my/org-anniversary-from-prop ()
  (let* ((bday (org-entry-get nil "BIRTHDAY"))
         (parts (and bday (parse-time-string bday)))
         (y (nth 5 parts))
         (m (nth 4 parts))
         (d (nth 3 parts))
         (today date) ;; variable fournie par diary: (month day year)
         (tm (calendar-extract-month today))
         (td (calendar-extract-day today))
         (ty (calendar-extract-year today))
         (name (org-get-heading t t t t)))
    (when (and y m d (= tm m) (= td d))
      (format "%s a %d ans" name (- ty y)))))

(after! org
  (setq org-directory "~/ghq/github.com/badele/org/")
  (setq org-default-notes-file "~/ghq/github.com/badele/org/notes.org")
  (setq +org-capture-inbox-file "~/ghq/github.com/badele/org/inbox.org")
  (setq +org-capture-job-file "~/ghq/github.com/badele/org/jobs.org")
  (setq +org-capture-journal-file "~/ghq/github.com/badele/org/journal.org")

  (setq org-agenda-files
        (mapcar (lambda (file)
                  (expand-file-name file org-directory))
                '(
                  "contacts.org"
                  "inbox.org"
                  "jobs.org"
                  "perso.org"
                  "projects.org"
                  )))

  (setq org-refile-targets
        '(
          ("jobs.org" :maxlevel . 2)
          ("perso.org" :maxlevel . 2)
          ("projects.org" :maxlevel . 4)
          )
        )
  ;; (setq org-agenda-sorting-strategy
  ;;       '((agenda habit-down time-up priority-down category-keep)
  ;;         (todo todo-state-up priority-down)
  ;;         (tags todo-state-up priority-down)
  ;;         (search category-keep)))

  ;; Align category and time in agenda view
  (setq org-agenda-prefix-format
        '((agenda . " %25:c %12t ")
          (todo   . " %25:c ")
          (tags   . " %25:c ")
          (search . " %25:c ")))

  ;; Global TODO keywords
  (setq org-todo-keywords
        '((sequence
           "IN-PROGRESS(i)"
           "WAIT(w)"
           "INTERVIEW(I)"
           "EXCHANGE(x)"
           "SEND(s)"
           "TODO(t)"
           "WATCH(W)"
           "SOMEDAY(S)"
           "|"
           "DONE(d)"
           "REFUSED(r)"
           "CANCELLED(c)"
           "KILL(k)")))

  (setq org-todo-keyword-faces
        '(("TODO"         . (:foreground "#ff9e64" :weight bold))
          ("IN-PROGRESS"  . (:foreground "#9ece6a" :weight bold))
          ("WAIT"         . (:foreground "#e0af68" :weight bold))
          ("WATCH"        . (:foreground "#7dcfff" :weight bold))
          ("SEND"         . (:foreground "#9ece6a" :weight bold))
          ("EXCHANGE"     . (:foreground "#bb9af7" :weight bold))
          ("INTERVIEW"    . (:foreground "#f7768e" :weight bold))
          ("REFUSED"      . (:foreground "#565f89" :weight bold))
          ("CANCELLED"    . (:foreground "#414868" :weight bold))))

  (setq org-agenda-sorting-strategy
        '((agenda habit-down time-up priority-down category-keep)
          (todo todo-state-up priority-down category-keep)
          (tags todo-state-up priority-down category-keep)
          (search category-keep)))


  (defun air-org-skip-subtree-if-priority (priority)
    "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY may be one of the characters ?A, ?B, or ?C."
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (pri-value (* 1000 (- org-lowest-priority priority)))
          (pri-current (org-get-priority (thing-at-point 'line t))))
      (if (= pri-value pri-current)
          subtree-end
        nil)))


  (defun air-org-skip-subtree-if-habit ()
    "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (if (string= (org-entry-get nil "STYLE") "habit")
          subtree-end
        nil)))

  (setq org-agenda-custom-commands
        '(("d" "What am I doing today?"
           ((tags "PRIORITY=\"A\""
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'todo 'done))
                   (org-agenda-overriding-header "High-priority tasks:")))

            (agenda "" ((org-agenda-ndays 1)))

            (alltodo ""
                     ((org-agenda-skip-function
                       '(or (air-org-skip-subtree-if-habit)
                            (air-org-skip-subtree-if-priority ?A)
                            (org-agenda-skip-if nil '(scheduled deadline))))
                      (org-agenda-overriding-header "Other tasks:")))))

          ("j" "Job status"
           ((todo "TODO")
            (todo "WATCH")
            (todo "SEND")
            (todo "EXCHANGE")
            (todo "INTERVIEW")
            (todo "REFUSED")
            (todo "CANCELLED"))
           ((org-agenda-files '("jobs.org"))
            (org-agenda-overriding-header "Job status")))

          ("i" "Inbox"
           tags "LEVEL=1"
           ((org-agenda-files (list +org-capture-inbox-file))))))
  ;; (setq org-agenda-custom-commands
  ;;       '(("d" "What am I doing today?"
  ;;          ((tags "PRIORITY=\"A\""
  ;;                 ((org-agenda-skip-function
  ;;                   '(org-agenda-skip-entry-if 'todo 'done))
  ;;                  (org-agenda-overriding-header "High-priority tasks:")
  ;;                  (org-agenda-sorting-strategy '(todo-state-down priority-down))
  ;;                  ))

  ;;           (agenda "" ((org-agenda-ndays 1)))

  ;;           (alltodo ""
  ;;                    ((org-agenda-skip-function
  ;;                      '(or (air-org-skip-subtree-if-habit)
  ;;                           (air-org-skip-subtree-if-priority ?A)
  ;;                           (org-agenda-skip-if nil '(scheduled deadline))))
  ;;                     (org-agenda-overriding-header "Other tasks:")
  ;;                     (org-agenda-sorting-strategy '(todo-state-down priority-down))
  ;;                     ))
  ;;           ))

  ;;         ("j" "Job status"
  ;;          ((todo "TODO")
  ;;           (todo "WATCH")
  ;;           (todo "SEND")
  ;;           (todo "EXCHANGE")
  ;;           (todo "INTERVIEW")
  ;;           (todo "REFUSED")
  ;;           (todo "CANCELLED"))
  ;;          ((org-agenda-files '("jobs.org"))
  ;;           (org-agenda-overriding-header "Job status")))

  ;;         ("i" "Inbox"
  ;;          tags "LEVEL=1"
  ;;          ((org-agenda-files (list +org-capture-inbox-file))))))

  (setq org-refile-targets
        '(("projects.org" :maxlevel . 2)
          ("perso.org" :maxlevel . 2)
          ("inbox.org" :maxlevel . 2)))

  (setq org-agenda-show-outline-path t)

  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  (setq org-capture-templates
        '(
          ("i" "Inbox" entry (file +org-capture-inbox-file)
           "* TODO %? %^{
Tag|:perso:|:work:|:family:}\n%U\n")

          ;; ("n" "Personal notes" entry (file+headline +org-capture-notes-file "Inbox")
          ;;  "* %u %?\n%i\n%a" :prepend t)
          ("t" "Today Journal" entry (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)
          ;; ("p" "Templates for projects")
          ;; ("pt" "Project-local todo" entry
          ;;  (file+headline +org-capture-project-todo-file "Inbox") "* TODO %?\n%i\n%a"
          ;;  :prepend t)
          ;; ("pn" "Project-local notes" entry
          ;;  (file+headline +org-capture-project-notes-file "Inbox") "* %U %?\n%i\n%a"
          ;;  :prepend t)
          ;; ("pc" "Project-local changelog" entry
          ;;  (file+headline +org-capture-project-changelog-file "Unreleased")
          ;;  "* %U %?\n%i\n%a" :prepend t)

          ;; ("o" "Centralized templates for projects")
          ;; ("ot" "Project todo" entry #'+org-capture-central-project-todo-file
          ;;  "* TODO %?\n %i\n %a" :heading "Tasks" :prepend nil)
          ;; ("on" "Project notes" entry #'+org-capture-central-project-notes-file
          ;;  "* %U %?\n %i\n %a" :heading "Notes" :prepend t)
          ;; ("oc" "Project changelog" entry #'+org-capture-central-project-changelog-file
          ;;  "* %U %?\n %i\n %a" :heading "Changelog" :prepend t)

          ("j" "Job application" entry
           (file+headline +org-capture-job-file "Candidatures")
           "* TODO %^{Société}
:PROPERTIES:
:COMPANY: %\\1
:ROLE: %^{Poste}
:LOCATION: %^{Lieu|Remote|Paris|Hybrid|Unknown}
:SOURCE: %^{Source|LinkedIn|Welcome to the Jungle|Indeed|Spontanée|Réseau|Autre}
:URL: %^{URL}
:CONTACT: %^{Contact}
:EMAIL: %^{Email}
:APPLIED_ON: %U
:END:

** Poste
%?

** Notes

** Échanges

** Prochaines actions
"
           :prepend t)

          ;; ("J" "Job application" entry
          ;;  (file +org-capture-job-file)
          ;;  "* TODO %^{Société}\n:PROPERTIES:\n:COMPANY: %\\1\n:ROLE: %^{Poste}\n:LOCATION: %^{Lieu|Remote|Paris|Hybrid|Unknown}\n:SOURCE: %^{Source|LinkedIn|Welcome to the Jungle|Indeed|Spontanée|Réseau|Autre}\n:URL: %^{URL}\n:CONTACT: %^{Contact}\n:EMAIL: %^{Email}\n:APPLIED_ON: %U\n:END:\n\n** Poste\n%?\n\n** Notes\n\n** Échanges\n\n** Prochaines actions\n"
          ;;  :prepend t)

          )
        )



  ;; (setq org-capture-templates
  ;;       (quote (("t" "todo" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
  ;;               ("r" "respond" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* IN-PROGRESS Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
  ;;               ("n" "note" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
  ;;               ("j" "Journal" entry (file+datetree "~/ghq/github.com/badele/org/diary.org")
  ;;                "* %?\n%U\n" :clock-in t :clock-resume t)
  ;;               ("w" "org-protocol" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* TODO Review %c\n%U\n" :immediate-finish t)
  ;;               ("m" "Meeting" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
  ;;               ("p" "Phone call" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
  ;;               ("h" "Habit" entry (file "~/ghq/github.com/badele/org/inbox.org")
  ;;                "* IN-PROGRESS %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

  ;; Disable hl-line-mode in org-mode and org-agenda-mode (because hide logbook time)
  (add-hook 'org-mode-hook (lambda () (hl-line-mode -1)))
  (add-hook 'org-agenda-mode-hook (lambda () (hl-line-mode -1)))

  ;; disable org-modern-mode in terminal
  (unless (display-graphic-p)
    (when (bound-and-true-p global-org-modern-mode)
      (global-org-modern-mode -1))
    (remove-hook 'org-mode-hook #'org-modern-mode)
    (remove-hook 'org-agenda-finalize-hook #'org-modern-agenda))
  )

(after! org-agenda
  (custom-set-faces!
    '(org-agenda-structure
      :foreground "#7dcfff" :weight bold :height 1.2)

    '(org-agenda-date
      :foreground "#7dcfff" :weight bold)

    '(org-agenda-date-today
      :foreground "#f7768e" :weight bold :slant italic)

    '(org-agenda-date-weekend
      :foreground "#bb9af7" :weight bold)

    '(org-scheduled
      :foreground "#9ece6a" :weight bold)

    '(org-scheduled-today
      :foreground "#9ece6a" :weight bold)

    '(org-scheduled-previously
      :foreground "#e0af68" :weight bold)

    '(org-upcoming-deadline
      :foreground "#e0af68" :weight bold)

    '(org-warning
      :foreground "#f7768e" :weight bold)

    '(org-agenda-done
      :foreground "#565f89"))
  )


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

;; Markdown ====================================================================
(after! grip-mode
  (setq grip-command 'go-grip))

(after! apheleia
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'gfm-mode apheleia-mode-alist) 'prettier))

(after! markdown-mode
  (setq markdown-command '("pandoc" "--from=gfm" "--to=html5"))
  (map! :map markdown-mode-map
        :localleader
        (:prefix ("i" . "insert")
         :desc "Refresh TOC"
         "R" #'markdown-toc-refresh-toc))
  )
;; Python ======================================================================
(setq-hook! 'python-ts-mode-hook fill-column 88)
(after! apheleia
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(isort black)))
