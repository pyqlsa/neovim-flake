{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./autopairs
    ./basic
    ./bufferline
    ./comment
    ./core
    ./autocomp
    ./treesitter
    ./tree
    ./lsp
    ./snippets
    ./statusline
    ./theme
    ./telescope
    ./visuals
  ];
}
