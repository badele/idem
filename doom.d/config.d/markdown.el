;; I don't use grip-mode, because it doen't work well with go-grip,
;; I just use go-grip directly to preview markdown files in browser.
(defun my/go-grip-preview ()
  "Launch go-grip on current markdown file and open in browser."
  (interactive)
  (unless buffer-file-name
    (error "Buffer is not visiting a file"))

  (let* ((file (expand-file-name buffer-file-name))
         (port 19434)
         (cmd (format "go-grip --port %d %s" port (shell-quote-argument file)))
         (buffer "*go-grip*"))

    ;; kill previous process if exists
    (when (get-buffer-process buffer)
      (kill-process (get-buffer-process buffer)))

    ;; start process
    (start-process-shell-command "go-grip" buffer cmd)

    (message "[go-grip] %s" cmd)

    ;; wait a bit and open browser
    (run-at-time
     "1 sec" nil
     (lambda ()
       (browse-url (format "http://localhost:%d/%s"
                           port
                           (file-name-nondirectory file)))))))

;; (map! :leader
;;       :desc "Go Grip preview"
;;       "m p" #'my/go-grip-preview)

;; I remap SPC m p to go-grip preview, because grip-mode doesn't work well with go-grip.

(after! markdown-mode
  (setq markdown-command '("pandoc" "--from=gfm" "--to=html5"))
  (map! :map markdown-mode-map
        :localleader
        (:prefix ("i" . "insert")
         :desc "Refresh TOC"
         "R" #'markdown-toc-refresh-toc))

  (map! :map markdown-mode-map
        :localleader
        :desc "Go Grip preview"
        "p" #'my/go-grip-preview)

  )

(after! grip-mode
  (setq grip-command 'go-grip))
