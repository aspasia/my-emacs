(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; only use use-package.el at compile-time
(eval-when-compile
  (require 'use-package))
(require 'diminish)                ;; if you use :diminish
(require 'bind-key)                ;; if you use any :bind variant

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Color themes

(add-to-list 'custom-theme-load-path "~/.emacs.d/color-themes")
(load-theme 'noctilux t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Generic config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uncomment the next line if you'd like to stop Emacs from
;; automatically creating and leaving "foo~" backup files
;; all over the place.
(setq make-backup-files nil)

;; Spaces only (no tab characters at all)!
(setq-default indent-tabs-mode nil)

;; Always show column numbers.
(setq-default column-number-mode t)

;; Display full pathname for files.
(add-hook 'find-file-hooks
          '(lambda ()
             (setq mode-line-buffer-identification 'buffer-file-truename)))

;; For easy window scrolling up and down.
(global-set-key "\M-n" 'scroll-up-line)
(global-set-key "\M-p" 'scroll-down-line)

;; To find lein
;; http://stackoverflow.com/questions/13671839/cant-launch-lein-repl-in-emacs
(add-to-list 'exec-path "/usr/local/bin")

;; buffer list to appear on active window
;; http://stackoverflow.com/questions/1231188/emacs-list-buffers-behavior
(global-set-key "\C-x\C-b" 'buffer-menu)

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

(use-package clojure-mode
  :ensure t
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.edn\\'" . clojure-mode))
  :init
  (add-hook 'clojure-mode-hook #'yas-minor-mode)         
  (add-hook 'clojure-mode-hook #'linum-mode)             
  (add-hook 'clojure-mode-hook #'subword-mode)           
  (add-hook 'clojure-mode-hook #'smartparens-mode)       
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook #'eldoc-mode)             
  (add-hook 'clojure-mode-hook #'idle-highlight-mode))

(use-package paredit
  :init
  (progn
    (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
    (add-hook 'clojure-mode-hook 'paredit-mode)
    (add-hook 'cider-repl-mode-hook 'paredit-mode)))

(use-package cider
  :ensure cider
  :init
  (setq cider-words-of-inspiration '("NREPL is ready!!"))
  (progn
    (add-hook 'cider-mode-hook 'my/setup-cider)
    (add-hook 'cider-repl-mode-hook 'my/setup-cider)))

(use-package winner                     ; Undo and redo window configurations
  :init (winner-mode)
  :bind (("C-c b" . winner-undo)
         ("C-c f" . winner-redo)))

;; Autocomplete
(use-package ido
  :init (progn (ido-mode 1)
               (ido-everywhere 1))
  :config
  (icomplete-mode +1)
  (progn
    (setq ido-case-fold t)
    (setq ido-everywhere t)
    (setq ido-enable-prefix nil)
    (setq ido-enable-flex-matching t)
    (setq ido-create-new-buffer 'always)
    (setq ido-max-prospects 10)
    (setq ido-use-faces nil)
    (setq ido-default-file-method 'selected-window)
    ;(setq ido-file-extensions-order '(".rb" ".el" ".coffee" ".js"))
    (add-to-list 'ido-ignore-files "\\.DS_Store")))
