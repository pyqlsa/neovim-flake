{ pkgs
, lib ? pkgs.lib
, ...
}: { config }:
with lib;
with builtins;
let
  vimOptions = evalModules {
    modules = [
      { imports = [ ../modules ]; }
      config
    ];

    specialArgs = {
      inherit pkgs;
    };
  };

  vim = vimOptions.config.vim;

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    inherit (vim) viAlias vimAlias;
    customRC = vim.configRC;
    plugins = (map (plugin: { inherit plugin; optional = false; }) (filter (f: f != null) vim.startPlugins))
      ++ (map (plugin: { inherit plugin; optional = true; }) (filter (f: f != null) vim.optPlugins));
  };
in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
  withNodeJs = vim.lsp.ts;
  wrapperArgs = neovimConfig.wrapperArgs ++ (
    let
      binPath = with pkgs; makeBinPath ([ git ]
        ++ (filter (f: f != null) vim.additionalPackages));
    in
    [ "--prefix" "PATH" ":" binPath ]
  );
})
