{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
in
{
  options.vim.treesitter = {
    enable = mkOption {
      type = types.bool;
      description = "enable the tree-sitter plugin [nvim-treesitter]";
      default = true;
    };

    fold = mkOption {
      type = types.bool;
      description = "enable tree-sitter folding support";
      default = false;
    };

    autotagHtml = mkOption {
      type = types.bool;
      description = "enable autoclose and rename html tag [nvim-ts-autotag]";
      default = false;
    };
  };

  config =
    mkIf cfg.enable
      {
        vim.startPlugins = with pkgs.neovimPlugins; [
          nvim-treesitter
          (
            if cfg.autotagHtml
            then nvim-ts-autotag
            else null
          )
        ];

        vim.startLuaConfigRC = ''
          -- Fix up the built-in Terraform detection
          vim.filetype.add({
            pattern = {
              ['.*tf'] = { 'terraform', { priority = 10 } },
            }
          })
        '';

        vim.luaConfigRC = ''
          ${optionalString cfg.fold ''
            -- Treesitter based folding
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
          ''}
          -- Treesitter config
          require('nvim-treesitter.configs').setup {
            highlight = {
                enable = true,
                disable = {},
            },

            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "gnn",
                node_incremental = "grn",
                scope_incremental = "grc",
                node_decremental = "grm",
              },
            },

            ${optionalString cfg.autotagHtml ''
            autotag = {
              enable = true,
            },
          ''}
          }
        '';
      };
}
