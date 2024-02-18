{ pkgs
, lib ? pkgs.lib
, ...
}: { config }:
let
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
pkgs.wrapNeovim pkgs.neovim-unwrapped {
  viAlias = vim.viAlias;
  vimAlias = vim.vimAlias;
  configure = {
    customRC = vim.configRC;

    packages.vimPackage = with pkgs.vimPlugins; {
      start = builtins.filter (f: f != null) vim.startPlugins;
      opt = vim.optPlugins;
    };
  };
}
