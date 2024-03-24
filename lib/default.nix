{ lib
, inputs
, ...
}:
with builtins; rec {
  # No longer needed for pseudo-formatting, but hard to let it go
  #smushString = val: lib.concatStringsSep " " (lib.remove "" (lib.splitString " " (builtins.replaceStrings [ "\n" ] [ " " ] val)));

  boolToYesNo = cond:
    if cond
    then "yes"
    else "no";

  optionalItems = cond: items:
    if cond
    then items
    else [ ];

  neovimBuilder = import ./neovimBuilder.nix;

  pluginOverlayBuilder = import ./pluginOverlayBuilder.nix { inherit lib inputs; };

  # Takes a filename and a string of lua text, and creates a formatted lua file
  # in the store with the given name; use like:
  #   luaFormatted "init.lua" ''<some lua text>''
  # or
  #   luaInit = "${luaFormatted "init.lua" ''<some lua text>''}/init.lua";
  # or
  #   luaFoo = "${luaFormatted "foo/bar.lua" ''<some lua text>''}/foo/bar.lua";
  luaFormatted = import ./luaFormatted.nix;

  allThemes = import ./themes.nix;
  defaultTheme = allThemes.default;

  # helper for generating flake outputs
  themedPackages = themes: wrapper: key: ps: builder:
    foldl'
      (cur: nxt:
        let
          chunk = wrapper ps (builder ps themes."${nxt}");
          ret =
            if ("${nxt}" == "default")
            then {
              "${key}" = chunk;
            }
            else {
              "${key}-${nxt}" = chunk;
            };
        in
        cur // ret)
      { }
      (attrNames
        themes);

  # package-specific wrapper for flake output generator
  packageWrapper = _: p: p;

  # generate package outputs for all supported themes, just pass a key and a builder
  allThemedPackages = themedPackages allThemes packageWrapper;

  # app-specific wrapper for flake output generator
  appWrapper = _: p: {
    type = "app";
    program = "${p}/bin/nvim";
  };

  # generate app outputs for all supported themes, just pass a key and a builder
  allThemedApps = themedPackages allThemes appWrapper;

  # devShell-specific wrapper for flake output generator
  devShellWrapper = ps: p:
    ps.mkShell {
      buildInputs = [ p ];
    };

  # generate devShell outputs for all supported themes, just pass a key and a builder
  allThemedShells = themedPackages allThemes devShellWrapper;
}
