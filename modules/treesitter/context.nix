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
  options.vim.treesitter.context = {
    enable = mkOption {
      type = types.bool;
      description = "enable function context [nvim-treesitter-context]";
      default = true;
    };
  };

  config =
    mkIf (cfg.enable && cfg.context.enable)
      {
        vim.startPlugins = with pkgs.vimPlugins; [ nvim-treesitter-context ];

        vim.luaConfigRC = ''
          -- Treesitter Context Config
          require('treesitter-context').setup {
            enable = true,
            max_lines = 0
          }
        '';
      };
}
