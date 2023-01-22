{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;
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

      listChars = mkOption {
        type = types.attrs;
        description = "Attribute set of characters to use for Vim's listchars option";
        default = {
          tab = "› ";
          eol = "¬";
          trail = "⋅";
        };
      };

      showCurrContext = mkOption {
        type = types.bool;
        description = "Highlight current context from treesitter";
        default = true;
      };
    };
  };

  config =
    let
      listCharNames = attrNames cfg.indentBlankline.listChars;
      listChars = (
        map
          (name: ''vim.opt.listchars:append({${name} = "${getAttr name cfg.indentBlankline.listChars}"})'')
          listCharNames
      );
    in
    {
      vim.startPlugins = with pkgs.neovimPlugins; [
        (
          if cfg.nvimWebDevicons.enable
          then nvim-web-devicons
          else null
        )
        (
          if cfg.lspkind.enable
          then pkgs.neovimPlugins.lspkind
          else null
        )
        (
          if cfg.cursorWordline.enable
          then nvim-cursorline
          else null
        )
        (
          if cfg.indentBlankline.enable
          then indent-blankline
          else null
        )
      ];

      vim.luaConfigRC = ''
        -- Visuals
        ${optionalString cfg.lspkind.enable ''
            require('lspkind').init()''}
        ${optionalString cfg.indentBlankline.enable ''
          --- highlight error: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
          vim.wo.colorcolumn = "99999"
          vim.opt.list = true

          ${concatStringsSep "\n" listChars}

          require("indent_blankline").setup {
            show_current_context = ${boolToString cfg.indentBlankline.showCurrContext},
            show_end_of_line = true,
          }''}
        ${optionalString cfg.cursorWordline.enable ''
            vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}''}
      '';
    };
}
