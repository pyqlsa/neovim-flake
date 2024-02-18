{ lib
, inputs
, ...
}: final: prev:
let
  inherit (prev.vimUtils) buildVimPlugin;

  treesitterGrammers = prev.tree-sitter.withPlugins (p: [
    p.tree-sitter-c
    p.tree-sitter-nix
    p.tree-sitter-python
    p.tree-sitter-rust
    p.tree-sitter-markdown
    p.tree-sitter-toml
    p.tree-sitter-make
    p.tree-sitter-html
    p.tree-sitter-go
    p.tree-sitter-json
    p.tree-sitter-javascript
    p.tree-sitter-css
    p.tree-sitter-hcl
    p.tree-sitter-lua
    p.tree-sitter-regex
    p.tree-sitter-yaml
  ]);

  fromInputs = with lib; inputs: prefix:
    mapAttrs'
      (n: v: nameValuePair (removePrefix prefix n) { src = v; })
      (filterAttrs (n: _: hasPrefix prefix n) inputs);

  rawPlugins = fromInputs inputs "plugin-";

  buildPlug = name:
    buildVimPlugin {
      pname = name;
      version = "master";
      src = rawPlugins.${name}.src;
      postPatch =
        if (name == "nvim-treesitter")
        then ''
          rm -r parser
          ln -s ${treesitterGrammers} parser
        ''
        else "";
    };

  neovimPlugins =
    builtins.listToAttrs
      (map
        (name: {
          inherit name;
          value = buildPlug name;
        })
        (builtins.attrNames rawPlugins));
in
{
  vimPlugins = prev.vimPlugins // neovimPlugins;
}
