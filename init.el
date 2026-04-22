(setq user-full-name "Aspasia Beneti"
      user-mail-address "aspasia.beneti@gmail.com")

(require 'package)
(setq package-enable-at-startup nil)

(when (>= emacs-major-version 24)
  (setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
                           ("gnu" . "http://elpa.gnu.org/packages/")
                           ("melpa-stable" . "http://stable.melpa.org/packages/")
                           ("marmalade" . "http://marmalade-repo.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpy" . "http://jorgenschaefer.github.io/packages/"))))

;; Refresh repos
(unless package-archive-contents
  (package-refresh-contents))

(setq package-load-list '(all))     ;; List of packages to load

(package-initialize)

(unless (package-installed-p 'org)  ;; Make sure the Org package is
  (package-install 'org))           ;; installed, install it if not

;; make sure we can use packages
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(package-initialize)

;; only use use-package.el at compile-time
(eval-when-compile
  (require 'use-package))

;; FIX: Install diminish and bind-key via use-package BEFORE requiring them.
;; Previously these were bare (require ...) calls which fail if the packages
;; aren't already on disk.
(use-package diminish
  :ensure t)

(use-package bind-key
  :ensure t)

(require 'diminish)                ;; if you use :diminish
(require 'bind-key)                ;; if you use any :bind variant

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Color themes

(add-to-list 'custom-theme-load-path "~/.emacs.d/color-themes")
(load-theme 'noctilux t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Functions

(defun my/setup-cider ()
  (lambda ()
    (setq cider-history-file "~/.nrepl-history"
          cider-hide-special-buffers t
          cider-repl-history-size 10000
          cider-prefer-local-resources t
          cider-popup-stacktraces-in-repl t)
    (paredit-mode 1)
    (eldoc-mode 1)))

(defun save-as (new-filename)
 (interactive "FFilename:")
 (write-region (point-min) (point-max) new-filename)
 (find-file-noselect new-filename))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Generic config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files nil)

;; Spaces only (no tab characters at all)!
(setq-default indent-tabs-mode nil)

;; Always show column numbers.
(setq-default column-number-mode t)
;; global-linum-mode was removed in Emacs 29; use display-line-numbers-mode instead
(if (fboundp 'global-display-line-numbers-mode)
    (global-display-line-numbers-mode 1)
  (global-linum-mode 1))

;; highlight matching parens
(show-paren-mode 1)

;; Display full pathname for files.
(add-hook 'find-file-hooks
          '(lambda ()
             (setq mode-line-buffer-identification 'buffer-file-truename)))

;; For easy window scrolling up and down.
(global-set-key "\M-n" 'scroll-up-line)
(global-set-key "\M-p" 'scroll-down-line)
(global-set-key "\M-A" 'indent-for-tab-command)

;; To find lein
(add-to-list 'exec-path "/usr/local/bin")

;; buffer list to appear on active window
(global-set-key "\C-x\C-b" 'buffer-menu)

;; Change the key binding for delete identation
(global-set-key "\M-\\" 'delete-indentation)

;; Quick keybinding to start a Clojure REPL
(global-set-key (kbd "C-c M-j") 'cider-jack-in)

;; ERC
(setq erc-auto-query 'window-noselect)

;; Get rid of "text read only" error when trying to edit with helm
(setq inhibit-read-only t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Use packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package exec-path-from-shell
  :ensure t
  :config
  (push "HISTFILE" exec-path-from-shell-variables)
  (setq exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-initialize))

(use-package recentf
  :config
  (recentf-mode)
  (setq recentf-exclude '(".ido.last")
        recentf-max-saved-items 1000)
  (defun ido-recentf-open ()
    "Use `ido-completing-read' to \\[find-file] a recent file"
    (interactive)
    (if (find-file (ido-completing-read "Find recent file: " recentf-list))
        (message "Opening file...")
      (message "Aborting")))
  :bind (("C-x f" . ido-recentf-open)))

(use-package flycheck-clj-kondo
  :ensure t)

(use-package clojure-mode
  :ensure t
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.cljc\\'" . clojurec-mode)
         ("\\.edn\\'" . clojure-mode)
         ("\\.spec\\'" . clojure-mode))
  :config
  (require 'flycheck-clj-kondo)
  ;; Align arguments under the function name
  (setq clojure-indent-style 'align-arguments)
  ;; Correct indentation for threading macros
  (put-clojure-indent '-> 1)
  (put-clojure-indent '->> 1)
  (put-clojure-indent 'cond-> 1)
  (put-clojure-indent 'cond->> 1)
  (put-clojure-indent 'some-> 1)
  (put-clojure-indent 'some->> 1)
  (put-clojure-indent 'go-loop 1)
  :init
  (add-hook 'clojure-mode-hook #'yas-minor-mode)
  (add-hook 'clojure-mode-hook (if (fboundp 'display-line-numbers-mode)
                                   #'display-line-numbers-mode
                                 #'linum-mode))
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'smartparens-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook #'eldoc-mode)
  (add-hook 'clojure-mode-hook #'aggressive-indent-mode))

;; cljfmt: auto-format Clojure buffers on save
(use-package cljfmt
  :ensure t
  :hook ((clojure-mode . cljfmt-on-save-mode)
         (clojurescript-mode . cljfmt-on-save-mode)
         (clojurec-mode . cljfmt-on-save-mode))
  :config
  (setq cljfmt-show-errors 'buffer))

(setq-default
   evil-want-Y-yank-to-eol nil
   neo-confirm-create-directory (quote off-p)
   neo-confirm-create-file (quote off-p)
   neo-theme (quote nerd))


(use-package paredit
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'lisp-interaction-mode-hook #'paredit-mode)
  (add-hook 'cider-repl-mode-hook #'paredit-mode)
  (add-hook 'lisp-mode-hook #'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'paredit-mode))

(use-package cider
  :ensure cider
  :init
  (progn
    (add-hook 'cider-mode-hook 'my/setup-cider)
    (add-hook 'cider-repl-mode-hook 'my/setup-cider)
    (add-hook 'cider-mode-hook #'eldoc-mode)
    (add-hook 'cider-repl-mode-hook #'eldoc-mode))
  :config
  ;; Override default joke list *after* package loads
  (setq cider-words-of-inspiration '("NREPL is ready!!"))
  :bind (("TAB" . complete-symbol)))

(use-package winner                     ; Undo and redo window configurations
  :init (winner-mode)
  :bind (("C-c b" . winner-undo)
         ("C-c f" . winner-redo)))

(use-package rainbow-delimiters
  :ensure t
  :hook ((clojure-mode       . rainbow-delimiters-mode)
         (clojurescript-mode . rainbow-delimiters-mode)
         (clojurec-mode      . rainbow-delimiters-mode)
         (emacs-lisp-mode    . rainbow-delimiters-mode)
         (lisp-mode          . rainbow-delimiters-mode)
         (cider-repl-mode    . rainbow-delimiters-mode)))

;; highlight, navigate and edit symbols
(use-package auto-highlight-symbol
  :ensure t
  :diminish ""
  :init
  (add-hook 'prog-mode-hook 'auto-highlight-symbol-mode)
  :config
  (progn
    (global-auto-highlight-symbol-mode +1)
    (set-face-attribute 'ahs-face nil
			:bold nil
			:underline t
			:background nil)
    (set-face-attribute 'ahs-definition-face nil
			:underline t
			:bold t
			:background nil)
    (setq ahs-default-range 'ahs-range-whole-buffer
	  ahs-include "^[0-9A-Za-z/_.,:;*+=&%|$#@!^?>-]+$"
	  ahs-select-invisible 'temporary
	  ahs-idle-interval 0.25)
    (bind-keys
     :map auto-highlight-symbol-mode-map
     ("M-<left>" . nil)
     ("M-<right>" . nil)
     ("M-F" . ahs-forward)
     ("M-B" . ahs-backward)
     ("s-e" . ahs-edit-mode)
     ("s-f" . ahs-forward)
     ("s-F" . ahs-forward-definition)
     ("s-b" . ahs-backward)
     ("s-B" . ahs-backward-definition)
     ("M-E" . ahs-edit-mode))))

(use-package helm
  :ensure t
  :bind (("M-y" . helm-show-kill-ring)
	 ("C-x C-b" . helm-buffers-list)
	 ("C-c h o" . helm-occur)
	 ("C-c h f" . helm-find-files)
	 ("C-c h r" . helm-regexp)
	 ("C-c h m" . helm-mark-ring)
	 ("C-c h x" . helm-M-x)
	 ("C-c h a" . helm-ag)
         ("C-c h t" . helm-do-ag)
	 ("C-c h b" . helm-buffers-list)
	 ("C-c h i" . helm-imenu))
  :config
  (progn
    (require 'helm-config)
    (require 'helm-ring)
    (require 'helm-source)
    (require 'helm-adaptive)
    (use-package helm-ag :ensure t)
    (setq helm-split-window-default-side 'below
	  helm-split-window-in-side-p t
	  helm-move-to-line-cycle-in-source t
	  helm-display-header-line nil
	  helm-candidate-separator "ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ")
    (helm-autoresize-mode +1)))

;; TODO Projectile
(use-package magit
  :ensure t)

;;ORG mode
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-switchb)

;; MARKDOWN
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package flycheck-joker
  :ensure t
  :init (global-flycheck-mode))

;; el-get
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

;; --------------- PYTHON STUFFS
(use-package python
  :mode ("\\.py\\'" . python-mode)
  :init
  (setq python-shell-interpreter "/Library/Frameworks/Python.framework/Versions/3.8/bin/python3"))

;; Python editing
(use-package elpy
  :ensure t
  :after python
  :config (elpy-enable))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
