{pkgs, ...}: let
  vale-fly-check = ''
    (flycheck-define-checker vale
      "A checker for prose"
      :command ("vale" "--output" "line"
              source)
      :standard-input nil
      :error-patterns
      ((error line-start (file-name) ":" line ":" column ":"
        (id (one-or-more (not (any ":")))) ":" (message) line-end))
        :modes (markdown-mode org-mode text-mode)
       )
     (add-to-list 'flycheck-checkers 'vale 'append)
  '';
  emacs-backup-config = ''
    ;; Store all backup files in a specific directory
    (setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
       backup-by-copying t    ; Don't delink hardlinks
       version-control t      ; Use version numbers on backups
       delete-old-versions t  ; Automatically delete excess backups
       kept-new-versions 20   ; how many of the newest versions to keep
       kept-old-versions 5    ; and how many of the old
    )

    ;; Create the backup directory if it doesn't exist
    (make-directory "~/.emacs.d/backup" t)
  '';
  vertico-setup = ''
    (vertico-mode)
  
    ;; Different scroll margin
    (setq vertico-scroll-margin 0)

    ;; Show more candidates
    (setq vertico-count 20)

    ;; Grow and shrink the Vertico minibuffer
    (setq vertico-resize t)

    ;; Enable cycling through candidates
    (setq vertico-cycle t)
  '';
  orderless-setup = ''
    (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion)))))
  '';

  fzf-setup = ''
    (require 'fzf)
    (global-set-key (kbd "C-c f") 'fzf) 
  '';
  exec-path-from-shell-setup = ''
    (when (memq window-system '(mac ns x))
      (exec-path-from-shell-initialize))
  '';
  in {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
    extraPackages = epkgs:
      with epkgs; [
        rustic
        vertico
        marginalia
        consult
        treesit-auto
        which-key
        magit
        nix-mode
        undo-tree
        # Completion
        company
        orderless

        # Navigation/Search
        projectile
        ripgrep

        # Git
        git-timemachine
        diff-hl

        # Editing
        smartparens
        rainbow-delimiters

        # Themes
        solarized-theme

        chatgpt-shell

        flycheck
        orderless
        fzf
        exec-path-from-shell
      ];

    extraConfig = ''
      ;; Basic settings for Emacs 30
      (setq inhibit-startup-message t)
      (setq use-short-answers t)  ; y/n instead of yes/no
      (setq native-comp-async-report-warnings-errors nil)

      ;; UI improvements
      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (scroll-bar-mode -1)
      (global-display-line-numbers-mode 1)
      (column-number-mode 1)

      ;; Store backup files in temporary directory
      (setq backup-directory-alist
        ((".*" . ,temporary-file-directory)))

      ;; Store auto-save files in temporary directory
      (setq auto-save-file-name-transforms
      ` ((".*" ,temporary-file-directory t)))

      ;; Disable undo-tree auto-save
      (setq undo-tree-auto-save-history nil)


      ;; Eglot setup
      (use-package eglot
        :ensure nil  ; it's built-in
        :hook ((python-mode . eglot-ensure)
               (python-ts-mode . eglot-ensure)
               (js-mode . eglot-ensure)
               (typescript-mode . eglot-ensure)
               (rust-mode . eglot-ensure)))

      ;; Autosave settings
      (setq auto-save-default t)                  ; Enable autosave
      (setq auto-save-interval 200)               ; Characters between autosaves
      (setq auto-save-timeout 30)                 ; Seconds of idle time before autosave
      (global-auto-revert-mode 1)

      ;; Undo changes
      (global-undo-tree-mode)

      ;; Completion
      (setq completion-styles '(orderless basic))
      (global-company-mode)

      ;; Project management
      (projectile-mode +1)
      (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

      ;; Editing
      (show-paren-mode 1)
      (electric-pair-mode 1)
      (global-diff-hl-mode)

      (marginalia-mode)

      (load-theme 'solarized-dark t)

      (setq chatgpt-shell-openai-key (getenv "OPENAI_API_KEY"))
      (setq chatgpt-shell-anthropic-key (getenv "ANTHROPIC_API_KEY"))

      (global-flycheck-mode)

      ;; Some useful customizations
      (setq flycheck-check-syntax-automatically '(save mode-enabled)) ;; only check on save
      (setq flycheck-indication-mode 'left-fringe)  ;; Show errors in the left fringe

      ${vale-fly-check}
      ${emacs-backup-config}
      ${vertico-setup}
      ${orderless-setup}
      ${fzf-setup}
      ${exec-path-from-shell-setup}
    '';
  };
}
