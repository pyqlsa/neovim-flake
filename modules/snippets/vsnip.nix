{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.snippets.vsnip;
in
{
  options.vim.snippets.vsnip = {
    enable = mkEnableOption "Enable nvim-vsnip";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [ vim-vsnip ];
  };
}
