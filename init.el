;;; Tune the GC
(setq gc-cons-threshold (* 4 1024 1024))
(setq gc-cons-percentage 0.3)

;;; Initialize package manager
(require 'package)

;;; Standard package repositories
;; org repository
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))

;; melpa repository
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;;; On-demand installation of packages
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (if (boundp 'package-selected-packages)
            ;; Record this as a package the user installed explicitly
            (package-install package nil)
          (package-install package))
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))


(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
      (require-package package min-version no-refresh)
    (error
     (message "Couldn't install optional package `%s': %S" package err)
     nil)))

;;; Fire up package.el
(setq package-enable-at-startup nil)
(package-initialize)


(require-package 'fullframe)
(fullframe list-packages quit-window)

(require-package 'cl-lib)
(require 'cl-lib)

(provide 'init-elpa)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (workgroups2 neotree multiple-cursors smex company-go company flycheck exec-path-from-shell go-mode org sr-speedbar fullframe))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; NEOTREE
(require 'neotree)
(setq neo-window-width 33)
(neotree-show) ;; show on startup
(neotree-dir "/Users/Dima/workspace/go/src/github.com")

;; using shift and arrow keys instead of C-x o
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))
;; Make windmove work in org-mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; SMEX
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


;; SHELL FIXES
(setq shell-file-name "bash")
(setq shell-command-switch "-ic")

;; BETTER INDENTING IN ORG MODE
(setq org-startup-indented t)

;; LINE NUMBERS
(add-hook 'prog-mode-hook 'linum-mode)
(setq linum-format "%d ")

;; GO
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))


; pkg go installation
(setq exec-path (append '("/usr/local/go/bin") exec-path))
(setenv "PATH" (concat "/usr/local/go/bin:" (getenv "PATH")))

; As-you-type error highlighting
(add-hook 'after-init-hook #'global-flycheck-mode)

(defun my-go-mode-hook ()
      (setq tab-width 2 indent-tabs-mode 1)
      (local-set-key (kbd "M-.") #'godef-jump)
      (setq gofmt-command "goimports")
      (add-hook 'before-save-hook 'gofmt-before-save)

      ; extra keybindings from https://github.com/bbatsov/prelude/blob/master/modules/prelude-go.el
      (let ((map go-mode-map))
        (define-key map (kbd "C-c a") 'go-test-current-project) ;; current package, really
        (define-key map (kbd "C-c m") 'go-test-current-file)
        (define-key map (kbd "C-c .") 'go-test-current-test)
        (define-key map (kbd "C-c b") 'go-run)))
(add-hook 'go-mode-hook 'my-go-mode-hook)

;; COMPANY
(require 'company)
(require 'go-mode)
(require 'company-go)
(add-hook 'go-mode-hook (lambda ()
                          (company-mode)
                          (set (make-local-variable 'company-backends) '(company-go))))

;; MULTIPLE CURSORS
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-c .") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c ,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c /") 'mc/mark-all-like-this)

;; WORKGROUPS
(desktop-save-mode 1)
(require 'workgroups2)
(workgroups-mode 1)

;; EMACS UI
(tool-bar-mode -1)
(setq inhibit-startup-message t) ;; disable the splash screen

(provide 'init)
;;; init.el ends here


