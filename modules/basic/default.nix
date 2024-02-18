{ pkgs
, lib
, config
, ...
}:
with lib;
with builtins; let
  cfg = config.vim;
in
{
  options.vim = {
    autoread = mkOption {
      type = types.bool;
      description = "Enable vm autoread";
      default = true;
    };

    colourTerm = mkOption {
      type = types.bool;
      description = "Set terminal up for 256 colours";
      default = true;
    };

    disableArrows = mkOption {
      type = types.bool;
      description = "Set to prevent arrow keys from moving cursor";
      default = false;
    };

    hideSearchHighlight = mkOption {
      type = types.bool;
      description = "Hide search highlight so it doesn't stay highlighted";
      default = false;
    };

    scrollOffset = mkOption {
      type = types.int;
      description = "Start scrolling this number of lines from the top or bottom of the page.";
      default = 999;
    };

    wordWrap = mkOption {
      type = types.bool;
      description = "Enable word wrapping.";
      default = true;
    };

    syntaxHighlighting = mkOption {
      type = types.bool;
      description = "Enable syntax highlighting";
      default = true;
    };

    mapLeaderSpace = mkOption {
      type = types.bool;
      description = "Map the space key to leader key";
      default = true;
    };

    useSystemClipboard = mkOption {
      type = types.bool;
      description = "Make use of the clipboard for default yank and paste operations. Don't use * and +";
      default = true;
    };

    mouseSupport = mkOption {
      type = with types; enum [ "a" "n" "v" "i" "c" ];
      description = "Set modes for mouse support. a - all, n - normal, v - visual, i - insert, c - command";
      default = "a";
    };

    lineNumberMode = mkOption {
      type = with types; enum [ "relative" "number" "none" ];
      description = "How line numbers are displayed. none, relative, number";
      default = "number";
    };

    preventJunkFiles = mkOption {
      type = types.bool;
      description = "Prevent swapfile, backupfile from being created";
      default = false;
    };

    tabWidth = mkOption {
      type = types.int;
      description = "Set the width of tabs";
      default = 2;
    };

    autoIndent = mkOption {
      type = types.bool;
      description = "Enable auto indent";
      default = true;
    };

    cmdHeight = mkOption {
      type = types.int;
      description = "Height of the command pane";
      default = 1;
    };

    updateTime = mkOption {
      type = types.int;
      description = "The number of milliseconds till Cursor Hold event is fired";
      default = 300;
    };

    showSignColumn = mkOption {
      type = types.bool;
      description = "Show the sign column";
      default = true;
    };

    bell = mkOption {
      type = types.enum [ "none" "visual" "on" ];
      description = "Set how bells are handled. Options: on, visual or none";
      default = "none";
    };

    mapTimeout = mkOption {
      type = types.int;
      description = "Timeout in ms that neovim will wait for mapped action to complete";
      default = 500;
    };

    splitBelow = mkOption {
      type = types.bool;
      description = "New splits will open below instead of on top";
      default = true;
    };

    splitRight = mkOption {
      type = types.bool;
      description = "New splits will open to the right";
      default = true;
    };

    hlSearch = mkOption {
      type = types.bool;
      description = "Enable search highlighting";
      default = true;
    };

    ignoreCase = mkOption {
      type = types.bool;
      description = "Ignore case during search";
      default = true;
    };

    incSearch = mkOption {
      type = types.bool;
      description = "Enable search while typing";
      default = true;
    };

    smartCase = mkOption {
      type = types.bool;
      description = "Enable smartcase searching when ignorecase is true";
      default = true;
    };

    showMode = mkOption {
      type = types.bool;
      description = "Enable showmode";
      default = true;
    };

    showMatch = mkOption {
      type = types.bool;
      description = "Enable showmatch";
      default = true;
    };

    backspace = mkOption {
      type = types.str;
      description = "Configure backspace behavior";
      default = "indent,eol,start";
    };
  };

  config = {
    vim.startPlugins = with pkgs.vimPlugins; [ plenary-nvim ];

    vim.startLuaConfigRC = ''
      ${optionalString cfg.mapLeaderSpace ''
        --- Map leader to space
        vim.g.mapleader = " "''}
    '';

    vim.luaConfigRC =
      let
        lineNumberModeConfigs = {
          "relative" = "vim.opt.relativenumber = true";
          "number" = "vim.opt.number         = true";
          "none" = "";
        };
      in
      ''
        -- Basic Vim Configurations
        --- Whitespace Cleanup
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
          pattern = { "*" },
          command = [[%s/\s\+$//e]],
        })
        ${optionalString cfg.disableArrows ''
          --- Disable arrow mappings
          vim.keymap.set({'n', 'i'}, '<up>', '<nop>')
          vim.keymap.set({'n', 'i'}, '<down>', '<nop>')
          vim.keymap.set({'n', 'i'}, '<left>', '<nop>')
          vim.keymap.set({'n', 'i'}, '<right>', '<nop>')''}

        --- Vim Options
        vim.opt.autoread       = ${boolToString cfg.autoread}
        vim.opt.hlsearch       = ${boolToString cfg.hlSearch}
        vim.opt.ignorecase     = ${boolToString cfg.ignoreCase}
        vim.opt.incsearch      = ${boolToString cfg.incSearch}
        vim.opt.smartcase      = ${boolToString cfg.smartCase}
        vim.opt.backspace      = "${cfg.backspace}"
        vim.opt.encoding       = "utf-8"
        vim.opt.mouse          = "${cfg.mouseSupport}"
        vim.opt.shiftwidth     = ${toString cfg.tabWidth}
        vim.opt.tabstop        = ${toString cfg.tabWidth}
        vim.opt.softtabstop    = ${toString cfg.tabWidth}
        vim.opt.expandtab      = true
        vim.opt.cmdheight      = ${toString cfg.cmdHeight}
        vim.opt.updatetime     = ${toString cfg.updateTime}
        vim.opt.shortmess      = vim.opt.shortmess + 'c'
        vim.opt.tm             = ${toString cfg.mapTimeout}
        vim.opt.hidden         = true
        vim.opt.splitbelow     = ${boolToString cfg.splitBelow}
        vim.opt.splitright     = ${boolToString cfg.splitRight}
        vim.opt.autoindent     = ${boolToString cfg.autoIndent}
        vim.opt.scrolloff      = ${toString cfg.scrollOffset}
        vim.opt.showmatch      = ${boolToString cfg.showMatch}
        vim.opt.showmode       = ${boolToString cfg.showMode}
        vim.opt.signcolumn     = "${boolToYesNo cfg.showSignColumn}"
        vim.opt.swapfile       = ${boolToString (! cfg.preventJunkFiles)}
        vim.opt.backup         = ${boolToString (! cfg.preventJunkFiles)}
        vim.opt.writebackup    = ${boolToString (! cfg.preventJunkFiles)}
        vim.opt.errorbells     = ${boolToString (cfg.bell == "on")}
        vim.opt.visualbell     = ${boolToString (cfg.bell == "visual")}
        vim.opt.wrap           = ${boolToString cfg.wordWrap}
        vim.opt.hlsearch       = ${boolToString (! cfg.hideSearchHighlight)}
        vim.opt.incsearch      = ${boolToString (! cfg.hideSearchHighlight)}
        vim.opt.termguicolors  = ${boolToString cfg.colourTerm}
        ${lineNumberModeConfigs."${cfg.lineNumberMode}"}
        ${optionalString cfg.useSystemClipboard ''
            vim.opt.clipboard      = vim.opt.clipboard + "unnamedplus"''}
        ${optionalString cfg.syntaxHighlighting ''
            vim.cmd('syntax on')''}

        --- Transparency
        vim.api.nvim_command("highlight Normal ctermbg=none")
        vim.api.nvim_command("highlight NormalNC ctermbg=none")
        vim.api.nvim_command("highlight Comment ctermbg=none")
        vim.api.nvim_command("highlight Constant ctermbg=none")
        vim.api.nvim_command("highlight Special ctermbg=none")
        vim.api.nvim_command("highlight Identifier ctermbg=none")
        vim.api.nvim_command("highlight Statement ctermbg=none")
        vim.api.nvim_command("highlight PreProc ctermbg=none")
        vim.api.nvim_command("highlight Type ctermbg=none")
        vim.api.nvim_command("highlight Underlined ctermbg=none")
        vim.api.nvim_command("highlight Todo ctermbg=none")
        vim.api.nvim_command("highlight String ctermbg=none")
        vim.api.nvim_command("highlight Function ctermbg=none")
        vim.api.nvim_command("highlight Conditional ctermbg=none")
        vim.api.nvim_command("highlight Repeat ctermbg=none")
        vim.api.nvim_command("highlight Operator ctermbg=none")
        vim.api.nvim_command("highlight Structure ctermbg=none")
        vim.api.nvim_command("highlight LineNr ctermbg=none")
        vim.api.nvim_command("highlight NonText ctermbg=none")
        vim.api.nvim_command("highlight SignColumn ctermbg=none")
        vim.api.nvim_command("highlight CursorLineNr ctermbg=none")
        vim.api.nvim_command("highlight EndOfBuffer ctermbg=none")
        vim.api.nvim_command("highlight NvimTreeNormal ctermbg=none")

        vim.api.nvim_command("highlight Normal guibg=none")
        vim.api.nvim_command("highlight NormalNC guibg=none")
        vim.api.nvim_command("highlight Comment guibg=none")
        vim.api.nvim_command("highlight Constant guibg=none")
        vim.api.nvim_command("highlight Special guibg=none")
        vim.api.nvim_command("highlight Identifier guibg=none")
        vim.api.nvim_command("highlight Statement guibg=none")
        vim.api.nvim_command("highlight PreProc guibg=none")
        vim.api.nvim_command("highlight Type guibg=none")
        vim.api.nvim_command("highlight Underlined guibg=none")
        vim.api.nvim_command("highlight Todo guibg=none")
        vim.api.nvim_command("highlight String guibg=none")
        vim.api.nvim_command("highlight Function guibg=none")
        vim.api.nvim_command("highlight Conditional guibg=none")
        vim.api.nvim_command("highlight Repeat guibg=none")
        vim.api.nvim_command("highlight Operator guibg=none")
        vim.api.nvim_command("highlight Structure guibg=none")
        vim.api.nvim_command("highlight LineNr guibg=none")
        vim.api.nvim_command("highlight NonText guibg=none")
        vim.api.nvim_command("highlight SignColumn guibg=none")
        vim.api.nvim_command("highlight CursorLineNr guibg=none")
        vim.api.nvim_command("highlight EndOfBuffer guibg=none")
        vim.api.nvim_command("highlight NvimTreeNormal guibg=none")

        --- Windows resize bindings
        vim.keymap.set('n', '<C-w>-', ':resize -5<CR>',  { noremap = true, silent = true})
        vim.keymap.set('n', '<C-w>+', ':resize +5<CR>',  { noremap = true, silent = true})
        vim.keymap.set('n', '<C-w><', ':vertical:resize -5<CR>',  { noremap = true, silent = true})
        vim.keymap.set('n', '<C-w>>', ':vertical:resize +5<CR>',  { noremap = true, silent = true})

        --- Backup, Swap and Undo directory configuration
        local data_path = vim.fn.stdpath('data')
        for index, directory in pairs({'backup', 'swap', 'undo'})
        do
            local path = data_path .. '/' .. directory
            if vim.fn.isdirectory(path) == 0 then
               vim.fn.mkdir(path, "p", "0700")
            end
        end
        vim.opt.backupdir = data_path .. '/backup'
        vim.opt.directory = data_path .. '/swap'
        vim.opt.undodir = data_path .. '/undo'
      '';
  };
}
