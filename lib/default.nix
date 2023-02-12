{ pkgs
, inputs
, plugins
, ...
}: {
  inherit (pkgs.lib);

  # No longer needed for pseudo-formatting, but hard to let it go
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

  # Takes a filename and a string of lua text, and creates a formatted lua file
  # in the store with the given name; use like:
  #   luaFormatted "init.lua" ''<some lua text>''
  # or
  #   luaInit = "${luaFormatted "init.lua" ''<some lua text>''}/init.lua";
  # or
  #   luaFoo = "${luaFormatted "foo/bar.lua" ''<some lua text>''}/foo/bar.lua";
  luaFormatted = import ./luaFormatted.nix {
    inherit pkgs;
    inherit (pkgs) lib stdenv;
  };
}
