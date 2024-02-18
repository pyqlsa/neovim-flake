{ lib
, inputs
, ...
}: final: prev:
with lib;
with builtins;
let
  inherit (prev.vimUtils) buildVimPlugin;

  fromInputs = inputs: prefix:
    mapAttrs'
      (n: v: nameValuePair (removePrefix prefix n) { src = v; })
      (filterAttrs (n: _: hasPrefix prefix n) inputs);

  pluginsFromInputs = fromInputs inputs "plugin-";

  # in case we need to build treesitter grammars in the future:
  # https://github.com/jordanisaacs/neovim-flake/blob/7bcc215d38226892849411721cfbc096fd7e4d2d/modules/build/default.nix#L109
  buildPlug = name:
    buildVimPlugin {
      pname = name;
      version = "master";
      src =
        assert asserts.assertMsg (name != "nvim-treesitter")
          "'buildPlug' can't build nvim-treesitter; use nvim-treesitter.withAllGrammars, or build a different way.";
        pluginsFromInputs.${name}.src;
      postPatch = "";
    };

  neovimPlugins =
    listToAttrs
      (map
        (name: {
          inherit name;
          value = buildPlug name;
        })
        (attrNames pluginsFromInputs));
in
{
  vimPlugins = prev.vimPlugins // neovimPlugins;
}
