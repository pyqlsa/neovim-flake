{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./autocomp
    ./autopairs
    ./basic
    ./bufferline
    ./comment
    ./core
    ./lsp
    ./markdown
    ./snippets
    ./statusline
    ./telescope
    ./theme
    ./tree
    ./treesitter
    ./visuals
  ];
}
