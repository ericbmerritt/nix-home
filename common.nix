{ pkgs, ... }:
let glab = (pkgs.callPackage ./glab { });
in {
  home.packages = [
    pkgs.cachix
    pkgs.xclip
    pkgs.killall
    pkgs.tmux
    pkgs.emacs
    pkgs.par
    pkgs.jq
    pkgs.moreutils
    glab
    pkgs.gitAndTools.gh
    pkgs.ngrok
    pkgs.nixFlakes
    pkgs.cachix
    pkgs.nodejs
  ];
  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "bira";
    };
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      ZSH_DISABLE_COMPFIX = "true";
    };
  };

  programs.command-not-found.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Eric B. Merritt";
    userEmail = "eric@merritt.tech";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand =
      "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  };
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      haskell-vim
      fzf-vim
      ghcid
      gruvbox
      vim-gitgutter
      vim-airline
      vim-tmux-focus-events
      vim-auto-save
      vimagit
      coc-nvim
      vim-nix
      typescript-vim
      vim-jsx-typescript
      vim-graphql
      vim-better-whitespace
    ];
    extraConfig = ''

                " par setup
                set textwidth=80
                set formatprg=par\ -w80req
                set formatoptions+=t

                syntax on
                set updatetime=300

                filetype plugin indent on

                " Gruvbox Setup
                colorscheme gruvbox
                set background=light

                " Autosave setup
                let g:auto_save = 1
                let g:auto_save_events = ["InsertLeave", "TextChanged",  "TextChangedI", "CursorHold", "CursorHoldI", "CompleteDone"]
                augroup magit
                  au!
                  au FileType magit let b:auto_save = 0
                augroup END

                set autoread
                set noswapfile

                " Line number management
                set number relativenumber

                " General setup
                set number
                set showmode
                set smartindent
                set autoindent
                set expandtab
                set shiftwidth=2
                set softtabstop=2
                set signcolumn=yes

                " Maintain undo history between sessions
                set undodir=~/.vim/undodir
                set undofile

                " Filetype specific setups
                autocmd FileType asciidoc setlocal formatoptions-=t

                " Use the system clipboard for copy/past
                set clipboard=unnamed

                " Coc Setup
                " Use tab for trigger completion with characters ahead and navigate.
                " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
                " other plugin before putting this into your config.
                inoremap <silent><expr> <TAB>
                      \ pumvisible() ? "\<C-n>" :
                      \ <SID>check_back_space() ? "\<TAB>" :
                      \ coc#refresh()
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

                function! s:check_back_space() abort
                  let col = col('.') - 1
                  return !col || getline('.')[col - 1]  =~# '\s'
                endfunction

                let g:coc_user_config = {
      	          \ 'rust-client.disableRustup': v:true,
                  \ 'rust.clippy_preference': 'on'
                \ }

                let g:coc_global_extensions = [
                  \ 'coc-tsserver',
                  \ 'coc-prettier',
                  \ 'coc-eslint'
                \ ]

                " Use K to show documentation in preview window.
                nnoremap <silent> K :call <SID>show_documentation()<CR>

                function! s:show_documentation()
                  if (index(['vim','help'], &filetype) >= 0)
                    execute 'h '.expand('<cword>')
                  else
                    call CocAction('doHover')
                  endif
                endfunction


                " Add `:Format` command to format current buffer.
                command! -nargs=0 Format :call CocAction('format')

                " Add `:OR` command for organize imports of the current buffer.
                command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

                " Add `:Next` and `:Previous` commands for errors
                command! -nargs=0 CNext :call CocAction('diagnosticNext')<CR>
                command! -nargs=0 CPrev :call CocAction('diagnosticPrevious')<CR>

                " JS/TS commands
                autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
                autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

                " Rust commands
                autocmd filetype rust setlocal makeprg=cargo\ build

                " Trailing Whitespace Management
                fun! TrimWhitespace()
                  let l:save = winsaveview()
                  keeppatterns %s/\s\+$//e
                  call winrestview(l:save)
                endfun

                command! TrimWhitespace call TrimWhitespace()

                set spell spelllang=en_us
              '';

  };

  home.file = { ".tmux.conf" = { source = ./tmux.conf; }; };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    grabKeyboardAndMouse = true;
    pinentryFlavor = "curses";
    defaultCacheTtl = 10800;
    maxCacheTtl = 10800;
  };
}
