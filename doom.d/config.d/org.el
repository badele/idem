;;; config.d/org.el -*- lexical-binding: t; -*-

(require 'org)
(require 'ol)

(defun my/org-refresh-all ()
  (interactive)
  (org-update-all-dblocks)
  (org-babel-execute-buffer))

(defun my-org-clocktable-strip-stats (ipos tables params)
  (org-clocktable-write-default ipos tables params)
  (save-excursion
    (goto-char ipos)
    (let ((end (save-excursion
                 (re-search-forward "^#\\+END:" nil t))))
      (while (re-search-forward "\\s-*\\(\\[[0-9]+/[0-9]+\\]\\|\\[[0-9]+%\\]\\)" end t)
        (replace-match "")))))

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
  (setq org-habit-graph-column 60)
  (setq org-deadline-warning-days 14)
  (setq org-agenda-deadline-leaders
        '("⚠ Deadline: "
          "⏳ In %2d days: "
          "❌ %2d days late: "))

  ;; indented subtrees in agenda
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-16t%s")
          (todo   . " %i %-12:c%l %s")
          (tags   . " %i %-12:c%l %s")
          (search . " %i %-12:c%l %s")))

  (setq org-directory "~/ghq/github.com/badele/org/")
  (setq org-default-notes-file "~/ghq/github.com/badele/org/notes.org")
  (setq +org-capture-inbox-file "~/ghq/github.com/badele/org/inbox.org")
  (setq +org-capture-job-file "~/ghq/github.com/badele/org/jobs.org")
  (setq +org-capture-journal-file "~/ghq/github.com/badele/org/journal.org")

  (setq org-agenda-files
        (mapcar (lambda (file)
                  (expand-file-name file org-directory))
                '(
                  "birthday.org"
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
                      (org-agenda-overriding-header "Other tasks:")
                      (org-agenda-sorting-strategy '(category-keep))))))


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

  (setq org-agenda-show-outline-path t)

  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  (setq org-capture-templates
        '(
          ("i" "Inbox" entry (file +org-capture-inbox-file)
           "* TODO %? %^{
    Tag|:perso:|:work:|:family:}\n%U\n")

          ("t" "Today Journal" entry (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)

          ("j" "Job application" entry
           (file+headline +org-capture-job-file "Candidatures")
           "* TODO %^{Société} :job:
:PROPERTIES:
:COMPANY: %\\1
:COMPANY_TYPE:
:DOMAIN:
:LOCATION: %^{Lieu|Unknown|Remote|Paris|Hybrid}
:DATE_AJOUT: %U
:END:
*** Annonces :
**** %^{Poste|DevOps|SRE|Platform Engineer}
    :PROPERTIES:
    :ANNONCE: %^{Text ou lien de l'annonce}
    :END:
***** Echanges :
***** Questions à poser :
***** Notes :
      - stack :
      - points positifs :
      - red flags :
          "
           :prepend t)
          )
        )

  ;; Disable hl-line-mode in org-mode and org-agenda-mode (because hide logbook time)
  (add-hook 'org-mode-hook (lambda () (hl-line-mode -1)))
  (add-hook 'org-agenda-mode-hook (lambda () (hl-line-mode -1)))

  (map! :leader
        :desc "Update all org dynamic blocks"
        "m u" #'my/org-refresh-all)
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
      :foreground "#565f89")

    '(org-tag
      :foreground "#bb8af7" )

    '(minibuffer-prompt
      :foreground "#7dcfff" :background unspecified :weight bold)

    '(region :background "#7aa2f7" :foreground "#1a1b26")

    '(secondary-selection :background "#3b4261" :foreground "#c0caf5")

    )
  )
