{ pkgs
, inputs
, plugins
, ...
}: {
  inherit (pkgs.lib);

  smushString = val: pkgs.lib.concatStringsSep " " (pkgs.lib.remove "" (pkgs.lib.splitString " " (builtins.replaceStrings [ "\n" ] [ " " ] val)));

  boolToYesNo = cond:
    if cond
    then "yes"
    else "no";

  withPlugins = cond: plugins:
    if cond
    then plugins
    else [ ];

  neovimBuilder = import ./neovimBuilder.nix { inherit pkgs; };

  buildPluginOverlay = import ./buildPlugin.nix { inherit pkgs inputs plugins; };
}
