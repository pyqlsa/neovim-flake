{ pkgs
, lib
, config
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.autopairs;
in
{
  options.vim = {
    autopairs = {
      enable = mkOption {
        type = types.bool;
        description = "enable autopairs";
        default = false;
      };

      checkTS = mkOption {
        type = types.bool;
        description = "Whether to check treesitter for a pair";
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [
      nvim-autopairs
    ];

    vim.luaConfigRC = ''
      -- Autopairs Config
      require("nvim-autopairs").setup({
        check_ts = ${boolToString cfg.checkTS},
      })'';
  };
}
