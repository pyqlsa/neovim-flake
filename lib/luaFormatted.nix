{ pkgs
, lib
, stdenv
, ...
}: file: text:
with pkgs;
stdenv.mkDerivation {
  name = file;
  nativeBuildInputs = [ stylua ];
  passAsFile = [ "luaData" ];
  luaData = text;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    cat "$luaDataPath" | ${stylua}/bin/stylua \
      --verify \
      --column-width 120 \
      --line-endings Unix \
      --indent-type Spaces \
      --indent-width 2 \
      --quote-style AutoPreferDouble \
      --call-parentheses Always \
      - > tmp.lua
  '';
  installPhase = ''
    target=$out/${lib.escapeShellArg file}
    mkdir -p "$(dirname "$target")"
    mv tmp.lua "$target"
  '';
}
