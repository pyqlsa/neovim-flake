{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;

  listCharNames = attrNames cfg.indentBlankline.listChars;

  listChars = (
    map
      (name: ''vim.opt.listchars:append({${name} = "${getAttr name cfg.indentBlankline.listChars}"})'')
      listCharNames
  );
in
{
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "visual enhancements";
      default = true;
    };

    nvimWebDevicons.enable = mkOption {
      type = types.bool;
      description = "enable dev icons. required for certain plugins [nvim-web-devicons]";
      default = true;
    };

    lspkind.enable = mkOption {
      type = types.bool;
      description = "enable vscode-like pictograms for lsp [lspkind]";
      default = true;
    };

    cursorWordline = {
      enable = mkOption {
        type = types.bool;
        description = "enable word and delayed line highlight [nvim-cursorline]";
        default = true;
      };

      lineTimeout = mkOption {
        type = types.int;
        description = "time in milliseconds for cursorline to appear";
        default = 500;
      };
    };

    indentBlankline = {
      enable = mkOption {
        type = types.bool;
        description = "enable indentation guides [indent-blankline]";
        default = true;
      };

      indentChar = mkOption {
        type = types.str;
        description = "character for indentation line";
        default = "│";
      };

      listChars = mkOption {
        type = types.attrs;
        description = "Attribute set of characters to use for Vim's listchars option";
        default = {
          tab = "› ";
          eol = "¬";
          trail = "⋅";
        };
      };

      showScope = mkOption {
        type = types.bool;
        description = "Highlight scope; requires treesitter";
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [ ]
      ++ (optionalItems cfg.nvimWebDevicons.enable [ nvim-web-devicons ])
      ++ (optionalItems cfg.lspkind.enable [ lspkind-nvim ])
      ++ (optionalItems cfg.cursorWordline.enable [ nvim-cursorline ])
      ++ (optionalItems cfg.indentBlankline.enable [ indent-blankline-nvim ]);

    vim.luaConfigRC = ''
      -- Visuals
      ${optionalString cfg.lspkind.enable ''
          require('lspkind').init()''}
      ${optionalString cfg.indentBlankline.enable ''
        vim.opt.list = true

        ${concatStringsSep "\n" listChars}

        require("ibl").setup {
          enabled = true,
          indent = { char = "${cfg.indentBlankline.indentChar}" },
          scope = { enabled = ${boolToString cfg.indentBlankline.showScope} },
        }''}
      ${optionalString cfg.cursorWordline.enable ''
          vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}''}
    '';
  };
}
