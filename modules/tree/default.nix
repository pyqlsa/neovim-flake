{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.nvimTree;
in
{
  options.vim.nvimTree = {
    enable = mkOption {
      type = types.bool;
      description = "Enable nvim-tree-lua";
      default = true;
    };

    treeSide = mkOption {
      type = types.enum [ "left" "right" ];
      description = "Side to anchor the tree window to";
      default = "left";
    };

    treeWidth = mkOption {
      type = types.int;
      description = "The width of the tree window";
      default = 30;
    };

    hideFiles = mkOption {
      type = with types; listOf str;
      description = "A list of files to hide in file view";
      default = [ "node_modules" ".cache" ];
    };

    hideIgnoreGitFiles = mkOption {
      type = types.bool;
      description = "Hide files ignored by git";
      default = false;
    };

    openOnSetup = mkOption {
      type = types.bool;
      description = "Open the window when Vim is started on a directory";
      default = false;
    };

    ignoreFileTypes = mkOption {
      type = with types; listOf str;
      description = "File types to ignore";
      default = [ ];
    };

    closeOnFileOpen = mkOption {
      type = types.bool;
      description = "Close the tree view when a file is opened";
      default = true;
    };

    resizeOnFileOpen = mkOption {
      type = types.bool;
      description = "Resize the tree when a file is opened";
      default = false;
    };

    followBufferFile = mkOption {
      type = types.bool;
      description = "Follow the file that is in the current buffer";
      default = true;
    };

    indentMarkers = mkOption {
      type = types.bool;
      description = "Show indent markers";
      default = true;
    };

    hideDotFiles = mkOption {
      type = types.bool;
      description = "Hide dot files";
      default = false;
    };

    openTreeOnNewTab = mkOption {
      type = types.bool;
      description = "Opens the tree view when opening a new tab";
      default = true;
    };

    disableNetRW = mkOption {
      type = types.bool;
      description = "Disables netrw and replace it with tree";
      default = true;
    };

    hijackNetRW = mkOption {
      type = types.bool;
      description = "Prevents netrw from automatically opening when opening directories";
      default = true;
    };

    trailingSlash = mkOption {
      type = types.bool;
      description = "Add a trailing slash to all folders";
      default = false;
    };

    groupEmptyFolders = mkOption {
      type = types.bool;
      description = "Compact empty folder trees into a single item";
      default = false;
    };

    lspDiagnostics = mkOption {
      type = types.bool;
      description = "Shows lsp diagnostics in the tree";
      default = true;
    };

    systemOpenCmd = mkOption {
      type = types.str;
      description = "The command used to open a file with the associated default program";
      default = "${pkgs.xdg-utils}/bin/xdg-open";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [
      nvim-tree
    ];

    vim.luaConfigRC = ''
      -- Nvim Tree Config
      require('nvim-tree').setup({
        disable_netrw = ${boolToString cfg.disableNetRW},
        hijack_netrw = ${boolToString cfg.hijackNetRW},
        open_on_tab = ${boolToString cfg.openTreeOnNewTab},
        open_on_setup = ${boolToString cfg.openOnSetup},
        open_on_setup_file = ${boolToString cfg.openOnSetup},
        system_open = {
          cmd = "${cfg.systemOpenCmd}",
        },
        diagnostics = {
          enable = ${boolToString cfg.lspDiagnostics},
        },
        view = {
          width = ${toString cfg.treeWidth},
          side = "${cfg.treeSide}",
        },
        renderer = {
          indent_markers = {
            enable = ${boolToString cfg.indentMarkers},
          },
          add_trailing = ${boolToString cfg.trailingSlash},
          group_empty = ${boolToString cfg.groupEmptyFolders},
        },
        actions = {
          open_file = {
            quit_on_open = ${boolToString cfg.closeOnFileOpen},
            resize_window = ${boolToString cfg.resizeOnFileOpen},
          },
        },
        git = {
          enable = true,
          ignore = ${boolToString cfg.hideIgnoreGitFiles},
        },
        filters = {
          dotfiles = ${boolToString cfg.hideDotFiles},
          custom = {
            ${builtins.concatStringsSep "\n      " (builtins.map (s: "'${s}',") cfg.hideFiles)}
          },
        },
      })

      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
      vim.keymap.set('n', '<leader>r', ':NvimTreeRefresh<CR>', {noremap = true, silent = true})
      vim.keymap.set('n', '<leader>n', ':NvimTreeFindFile<CR>', {noremap = true, silent = true})
    '';
  };
}
