{ pkgs
, lib ? pkgs.lib
, ...
}: { config }:
let
  neovimPlugins = pkgs.neovimPlugins;

  neovimUnwrapped = pkgs.neovim-unwrapped;

  vimOptions = lib.evalModules {
    modules = [
      { imports = [ ../modules ]; }
      config
    ];

    specialArgs = {
      inherit pkgs;
    };
  };

  vim = vimOptions.config.vim;
in
pkgs.wrapNeovim neovimUnwrapped {
  viAlias = vim.viAlias;
  vimAlias = vim.vimAlias;
  configure = {
    customRC = vim.configRC;

    packages.vimPackage = with neovimPlugins; {
      start = builtins.filter (f: f != null) vim.startPlugins;
      opt = vim.optPlugins;
    };
  };
}
