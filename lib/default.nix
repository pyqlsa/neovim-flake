{ pkgs
, inputs
, plugins
, ...
}: {
  inherit (pkgs.lib);

  # no longer needed for pseudo-formatting, but hard to let it go
  #smushString = val: pkgs.lib.concatStringsSep " " (pkgs.lib.remove "" (pkgs.lib.splitString " " (builtins.replaceStrings [ "\n" ] [ " " ] val)));

  boolToYesNo = cond:
    if cond
    then "yes"
    else "no";

  withPlugins = cond: plugs:
    if cond
    then plugs
    else [ ];

  neovimBuilder = import ./neovimBuilder.nix { inherit pkgs; };

  buildPluginOverlay = import ./buildPlugin.nix { inherit pkgs inputs plugins; };
}
