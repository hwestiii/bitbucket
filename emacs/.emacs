;;
;; start server process
;; 
(server-start)

;;
;; enable package management 
;;
(require 'package)
(let ((default-directory "~/.emacs.d/elpa/")) (normal-top-level-add-subdirs-to-load-path))
(when (> emacs-major-version 23)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives 
	       '("melpa" . "http://melpa.milkbox.net/packages/")
	       'APPEND))

(setq viper-mode t)
(require 'viper)
(set-variable 'viper-want-ctl-h-help t)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(setq w32-get-true-file-attributes nil)
;;;;
;;;; mail stuff
;;;;
(setq smtpmail-mail-function 'smtpmail-send-it)
(setq smtpmail-smtp-server "smtp.gmail.com")
(setq smtpmail-smtp-service 993)
(setq smtpmail-auth-credentials '(("smtp.gmail.com" 993 "hwestiii@gmail.com" "B1rthday")))

;;
;; set up new mode for log files
;;
(defun log-mode-hook ()
  (set-variable viper-case-fold-search t)
  )

(define-derived-mode log-mode text-mode "log" "Major mode for log files"
  (auto-revert-tail-mode 1)
  (set-variable 'truncate-lines t))

(add-to-list 'auto-mode-alist (cons "\\.log\\|\\.LOG" 'log-mode))

(eshell)
(ido-mode t)

(set-variable 'dired-ls-sorting-switches "alt")

;;
;; turn on syntax coloring
;;
(global-font-lock-mode 1)

(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 )


;; set C-x C-b to electric buffer list
(global-set-key "\C-x\C-b" 'electric-buffer-list)

;; 
;; stuff for org-mode
;;
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;;
;; copy entire current buffer to kill ring and clipboard
;;
(defun copy-all ()
  (interactive)
    (copy-region-as-kill (point-min) (point-max)))

(defun clear-buffer () 
  (interactive)
  (delete-region (point-min) (point-max)))

(defun open-.emacs ()
  (interactive)
  (find-file "~/.emacs"))

;; (global-set-key "\C-xe" 'open-.emacs)
;;
;; revert current buffer and scroll to bottom
;; mapped to f12 key
;;
(progn
  (defun revert-me-now ()
    (interactive)
    (revert-buffer t t t)
    (goto-char (point-max)))
  (global-set-key (kbd "<f12>") 'revert-me-now)
  )

(defun toggle-lines ()
(interactive)
  (set-variable 'truncate-lines (not truncate-lines)))

(defun indent-buffer ()
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max))
    )
  )

;;
;; replace selected html entity strings in current buffer with actual characters
;;
(defun unentity-fy ()
  (interactive)
  (setq ents '(("&#x9;" "	") ("&gt;" ">") ("&lt;" "<") ("&#xA;" "
")("&amp;" "&")))
  (save-excursion
    (dolist (pair ents)
    (goto-char (point-min))
    (while (re-search-forward (car pair) nil t)
      (replace-match (cadr pair))))))


;;
;;
;;
(defun strip-cr ()
  (interactive)
  
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\C-m" nil t)
      (replace-match "")))
)

;;
;;
;;
;;
(defun file-save-as ()
  ;;
  ;; save current buffer to new file name
  ;; close existing buffer
  ;; open new file to edit
  ;;
)

(defun my-revert-buffer ()
  (interactive)
  (if (buffer-file-name)
  (let ((revert-without-query (list (buffer-file-name))))
    (revert-buffer t t))))

(global-set-key (kbd "<f12>") 'my-revert-buffer)

;;
;; remove all blank lines in current document
;;
(defun del-blank-lines ()
  (interactive)
  (save-excursion
  (goto-char (point-min))
  (while (< (line-end-position) (point-max))
    (delete-blank-lines)
    (forward-line))))


(defun next-long-line (line-length)
  (interactive "nEnter desired line length: \n")
  (while (< (- (line-end-position) (line-beginning-position)) 20)
    (forward-line)
    )
)

(defun long-lines (line-length)
  (interactive "nEnter desired line length: \n")
  (setq source-buffer (current-buffer))
  (while (< (line-end-position) (point-max))
    (next-long-line line-length)
    (setq long-line (buffer-substring (line-beginning-position) (line-end-position)))
    (set-buffer (get-buffer-create "long-lines"))
    (insert long-line)
    (insert "
")
     (set-buffer source-buffer)
     (forward-line)))
	

(defun how-many (ppoint mmark)
  (interactive "r")
  (save-excursion 
    (let ((what (buffer-substring-no-properties ppoint mmark))(how-many-this 0))
      (message "%s\n" what)
      (goto-char (point-min))
      (while (and (< (line-end-position) (point-max))(re-search-forward what nil t))
	(setq how-many-this (1+ how-many-this)))
      (if (> how-many-this 0)
	  (message "Found %d instances of %s.\n" how-many-this what)
	(message "Found no instances of %s." what))
      )
    ))

(defun format-bookmarklet ()
  (interactive)
  (javascript-mode)
  ;;
  ;; add carriage returns around brackets
  ;;
  (goto-char (point-min))
  (while (re-search-forward "[{}]" nil t)
    (replace-match "
\\&
" t nil))
  ;;
  ;; add carriage returns after semi-colons
  ;;
  (goto-char (point-min))
  (while (re-search-forward ";" nil t)
    (replace-match "\\&
" t nil))
  (indent-region (point-min) (point-max))    
    )


(defun on-last-line ()
  (= (line-end-position) (point-max)))

(defun reverse-string (astring)
  (if (= 1 (length astring))
      (substring astring 0)
    (concat (reverse-string (substring astring 1)) (substring astring 0 1))))

(put 'narrow-to-region 'disabled nil)

(defun clean-xml-ids ()
  (interactive)
  (save-excursion
    (let ((id-regexp " ?\\(id\\|created\\|modified\\)=\"[[:alnum:]]+\""))
      (goto-char (point-min))
      (while (re-search-forward id-regexp nil t)
	(replace-match ""))
      )
    )
  )

(defun clean-all-files (dir)
  (interactive "DDirectory name: ")
  (let ((change-buff)(full-path))
    (debug)
    (dolist (file (directory-files dir))
      (setq full-path (concat dir file))
      (if (file-regular-p full-path)
	  (progn
	    (setq change-buff (find-file full-path))
	    (clean-xml-ids)
	    (if (buffer-modified-p change-buff)
		(save-buffer))
	    (kill-buffer change-buff))
	)
      )
    )
  )



(defun remove-blank-areas ()
  (interactive)
  (while (re-search-forward "^$" nil t)
    (delete-blank-lines)
    (when (= (line-beginning-position)(line-end-position))
      (delete-region (line-beginning-position) (1+ (line-end-position))))))
      
(defun yesterday ()
  (interactive)
  (insert (current-time-string (time-subtract (current-time) (seconds-to-time (* 60 60 24))))))

(defun empty-import ()
  (interactive)
  (insert "<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n")
  (insert "<!DOCTYPE sailpoint PUBLIC \"sailpoint.dtd\" \"sailpoint.dtd\">\n")
  (insert "<sailpoint>\n")
  ("<ImportAction name=\'include\' value=\'\'/>\n")
  (insert "</sailpoint>\n"))

(defun initialize-import-file ()
  (interactive)
  (save-excursion
    (insert "<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n")
    (insert "<!DOCTYPE sailpoint PUBLIC \"sailpoint.dtd\" \"sailpoint.dtd\">\n")
    (insert "<sailpoint>\n")
 ;;   (debug)
    (mapcar (lambda (fname) (unless (or  (not (file-name-extension fname)) (not fname) (not (string= (downcase (file-name-extension fname)) "xml")) (string= (file-name-nondirectory fname) (file-name-nondirectory (buffer-file-name))))(insert "<ImportAction name=\'include\' value=\'" fname "\'/>\n"))) (flatten (recursive-relative-file-names (file-name-directory (buffer-file-name (current-buffer))))))
    (insert "</sailpoint>\n")
    (indent-region (point-min) (point-max))))
  
 

(defun recursive-relative-file-names (dir)
  "returns a list containing the relative names of the files below the directory specified by the dir input argument"
  (defvar topdir dir)
  (print topdir)
  (mapcar (lambda (finfo)(unless (member (car finfo)(list "." ".."))(let ((fname (concat dir "/" (car finfo))))(if (nth 1 finfo) (recursive-relative-file-names fname)(substring fname (+ 1(length topdir))))))) (directory-files-and-attributes dir)))

;; (defun flatten (alist)
;; "returns a single level list constructed by flattening an arbitrarily deep input list"
;;   (interactive)
;;   (when alist
;;     (if (listp (car alist))
;; 	(append (flatten (car alist)) (flatten (cdr alist)))
;;       (append (list (car alist)) (flatten (cdr alist))))))

(defun flatten (alist)
"returns a single level list constructed by flattening an arbitrarily deep input list"
  (interactive)
  (when alist
	(append (if (listp (car alist)) (flatten (car alist))(list (car alist))) (flatten (cdr alist)))))

(defun current-tomcat-log ()
  (interactive)
  (find-file (car (car (sort (directory-files-and-attributes "D:\\Program Files\\apache-tomcat-6.0.32\\logs" t "tomcat6-stdout.+") (lambda (a b) (> (float-time (nth 6 a))(float-time (nth 6 b)))))))))

(defun find-orphan-steps ()
  (interactive)
  (save-excursion
  (let ((step-regex "<Step.+name=\"\\([- [:alnum:]]+\\)")(orphans nil))
    (goto-char (point-min))
    (while (re-search-forward step-regex nil t)
      (let ((found (match-string-no-properties 1)))
	(unless (string= (downcase found) "start")
	  (unless (find-start found)
	    (print (concat found " is unreachable from start")))))))))



    ;; 	(unless (string= (downcase found) "start")
    ;; 	  (print (concat "current found is " found))
    ;; 	  (save-excursion
    ;; 	    (goto-char (point-min))
    ;; 	    (unless (re-search-forward (concat "<Transition.+to=\"" found) nil t)
    ;; 	      (setq orphans (cons found orphans)))
	    
    ;; 	    ))))
    ;; (unless (not orphans)
    ;;   (mapcar (lambda (orphan) (print (concat "Step " orphan " is an orphan"))) orphans))
    ;; )))


(defun find-start (step-name)
  (save-excursion
  (let ((transition (concat "<Transition.+to=\"" step-name))
	(step-regex "<Step.+name=\"\\([- [:alnum:]]+\\)"))
    (goto-char (point-min))
    (if (re-search-forward transition nil t)
	(if (re-search-backward step-regex nil t)
	    (if (string= (downcase (match-string-no-properties 1)) "start")
		t
	      (find-start (match-string-no-properties 1)))
	  nil )))))
	
(defun kill-buffer-or-server-edit ()
  (interactive)
  (if server-buffer-clients
      (server-edit)
      (kill-buffer)))

(global-set-key "\C-xk" 'kill-buffer-or-server-edit)

(fset 'pol
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([58 37 115 47 92 32 46 43 36 47 47 103 return 58 37 115 47 94 47 100 101 108 101 116 101 32 80 111 108 105 99 121 86 105 111 108 97 116 105 111 110 32 47 103 return 134217848 99 111 112 121 32 97 108 108 return] 0 "%d")) arg)))


(defun tss-update()
  (interactive)
  (save-excursion
  (let ((s1 "    ")(s2 " º  ")(s3 " §  ")(s4 " {  ")(s5 " &  "))
    (goto-char (point-min))
    (while (not (= (line-end-position) (point-max)))
      (beginning-of-line)
      (cond
       ((string= (current-word) "0001")(insert s2))
       ((or (string= (current-word) "0300")(string= (current-word) "0400")(string= (current-word) "0450")(string= (current-word) "3501"))(insert s3))
       ((string= (current-word) "2021")(insert s4))
       ((string= (current-word) "3000")(insert s5))
       (t (insert s1)))
      (forward-line))
    )))
(put 'scroll-left 'disabled nil)


(defun indent-sp-source(save-now)
;;
;; non-nil universal-argument automatically saves current document after reformatting
;;
  (interactive "P")
  (save-excursion
    (nxml-mode)
    (indent-region (point-min) (point-max))
    (let ((startstr "<Source>\\(.?<!\\[CDATA\\[\\)?") (endstr "\\(\\]\\]>\\)?.?</Source>")(start)(end))
      (goto-char (point-min))
      (while (re-search-forward startstr nil t)
	(setq start (point))
	(when (re-search-forward endstr nil t)
	  (setq end (point))
	  (java-mode)
	  (indent-region start end)
	  (nxml-mode)
	  ))
      (if save-now
	  (save-buffer))
      ))) 

(defun pad-for-ibm ()
  (interactive)
  (save-excursion
    (debug)
    (goto-char (point-min)) 
    (unless (= (line-end-position)(point-max))
	   (end-of-line)
	   (insert (make-string (- 80 (- (line-end-position) (line-beginning-position))) ? )))
	   
    (end-of-line)
    (insert (make-string (- (- 80 (line-end-position) (line-beginning-position))) ? ))))

(defun add-cdata-tags ()
  (interactive)
  (end-of-line)
  (insert "\n<![CDATA[\n\n]]>"))

(defun break-down ()
  (interactive)
    (goto-char (point-min))
    (let ((ous (make-hash-table :test 'equal))(debug 'error)(pos)(cn)(ou))
      (while
	  (progn
	    (condition-case nil
		(progn
		  (setq currstr (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
		  (setq pos (string-match "OU=" currstr))
		  (setq cn (substring currstr 0 (1- pos)))
		  (setq ou (substring currstr pos))
		  (if (gethash ou ous)
		      (puthash ou (vconcat (gethash ou ous) (list cn)) ous)
		    (puthash ou (vector cn) ous))))
	    (forward-line 1)
	    (/= (point)(point-max))))
      (maphash (lambda (k v) (insert (concat (number-to-string (length v)) " -- " k "\n"))) ous)))

