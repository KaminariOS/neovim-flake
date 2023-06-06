{
  lib,
  config,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (lib) optionalString mkIf nvim;

  cfg = config.vim;
in {
  config = {
    vim.startPlugins = ["plenary-nvim"] ++ lib.optionals (cfg.spellChecking.enableProgrammingWordList) ["vim-dirtytalk"];

    vim.nmap = mkIf cfg.disableArrows {
      "<up>" = "<nop>";
      "<down>" = "<nop>";
      "<left>" = "<nop>";
      "<right>" = "<nop>";
    };

    vim.imap = mkIf cfg.disableArrows {
      "<up>" = "<nop>";
      "<down>" = "<nop>";
      "<left>" = "<nop>";
      "<right>" = "<nop>";
    };

    vim.nnoremap = mkIf cfg.mapLeaderSpace {
    "<space>" = "<nop>";
    "<leader><leader>" = "<cmd>bn<cr>";
    "<leader>bd" = "<cmd>bd<cr>";
    };

    vim.vnoremap = mkIf cfg.mapLeaderSpace {
    "<space>" = "<nop>";
    "<leader><leader>" = "<cmd>bn<cr>";
    "<leader>bd" = "<cmd>bd<cr>";
    };
    vim.tnoremap = mkIf cfg.mapLeaderSpace {
    "<space>" = "<nop>";
    "<leader><leader>" = "<cmd>bn<cr>";
    "<leader>bd" = "<cmd>bd<cr>";
    };
    vim.configRC.basic = nvim.dag.entryAfter ["globalsScript"] ''
      ${optionalString cfg.debugMode.enable ''
        " Debug mode settings
        set verbose=${toString cfg.debugMode.level}
        set verbosefile=${cfg.debugMode.logFile}
      ''}

      " Settings that are set for everything
      set encoding=utf-8

      nnoremap <C-j> <Esc>
      inoremap <C-j> <Esc>
      vnoremap <C-j> <Esc>
      snoremap <C-j> <Esc>
      xnoremap <C-j> <Esc>
      cnoremap <C-j> <Esc>
      onoremap <C-j> <Esc>
      lnoremap <C-j> <Esc>
      tnoremap <C-j> <C-\><C-n>

      " Remap splits navigation to just CTRL + hjkl
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      cnoremap <C-a> <Home> cnoremap <C-e> <End>
      cnoremap <C-p> <Up>
      cnoremap <C-n> <Down>
      cnoremap <C-b> <Left>
      cnoremap <C-f> <Right>

      " Make adjusing split sizes a bit more friendly
      noremap <C-Left> <cmd>vertical resize +3<CR>
      noremap <C-Right> <cmd>vertical resize -3<CR>
      noremap <C-Up> <cmd>resize +3<CR>
      noremap <C-Down> <cmd>resize -3<CR>

      imap <C-e> <cmd>:wq<cr> 
      nmap <C-e> <cmd>:wq<cr> 

      set mouse=${cfg.mouseSupport}
      set tabstop=${toString cfg.tabWidth}
      set shiftwidth=${toString cfg.tabWidth}
      set softtabstop=${toString cfg.tabWidth}
      set expandtab
      set cmdheight=${toString cfg.cmdHeight}
      set updatetime=${toString cfg.updateTime}
      set shortmess+=c
      set tm=${toString cfg.mapTimeout}
      set hidden
      set cursorlineopt=${toString cfg.cursorlineOpt}
      set scrolloff=${toString cfg.scrollOffset}

      ${optionalString cfg.splitBelow ''
        set splitbelow
      ''}
      ${optionalString cfg.splitRight ''
        set splitright
      ''}
      ${optionalString cfg.showSignColumn ''
        set signcolumn=yes
      ''}
      ${optionalString cfg.autoIndent ''
        set autoindent
      ''}

      ${optionalString cfg.preventJunkFiles ''
        set noswapfile
        set nobackup
        set nowritebackup
      ''}
      ${optionalString (cfg.bell == "none") ''
        set noerrorbells
        set novisualbell
      ''}
      ${optionalString (cfg.bell == "on") ''
        set novisualbell
      ''}
      ${optionalString (cfg.bell == "visual") ''
        set noerrorbells
      ''}
      ${optionalString (cfg.lineNumberMode == "relative") ''
        set relativenumber
      ''}
      ${optionalString (cfg.lineNumberMode == "number") ''
        set number
      ''}
      ${optionalString (cfg.lineNumberMode == "relNumber") ''
        set number relativenumber
      ''}
      ${optionalString cfg.useSystemClipboard ''
        set clipboard+=unnamedplus
      ''}
      ${optionalString cfg.mapLeaderSpace ''
        let mapleader=" "
        let maplocalleader=" "
      ''}
      ${optionalString cfg.syntaxHighlighting ''
        syntax on
      ''}
      ${optionalString (!cfg.wordWrap) ''
        set nowrap
      ''}
      ${optionalString cfg.hideSearchHighlight ''
        set nohlsearch
        set incsearch
      ''}
      ${optionalString cfg.colourTerm ''
        set termguicolors
        set t_Co=256
      ''}
      ${optionalString (!cfg.enableEditorconfig) ''
        let g:editorconfig = v:false
      ''}
      ${optionalString cfg.spellChecking.enable ''
        set spell
        set spelllang=${concatStringsSep "," cfg.spellChecking.languages}${optionalString cfg.spellChecking.enableProgrammingWordList ",programming"}
      ''}
      ${optionalString (cfg.leaderKey != null) ''
        let mapleader = "${toString cfg.leaderKey}"
      ''}
      ${optionalString (cfg.searchCase == "ignore") ''
        set nosmartcase
        set ignorecase
      ''}
      ${optionalString (cfg.searchCase == "smart") ''
        set noignorecase
        set smartcase
      ''}
      ${optionalString (cfg.searchCase == "sensitive") ''
        set noignorecase
        set nosmartcase
      ''}
    '';
  };
}
