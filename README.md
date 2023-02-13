# neovim-flake
A nix flake for neovim with with my personal configuration.

It is bound to change, so a fork is recommended over pointing to it directly.

## Take it for a spin
Clone the repo and run the following from the root of the project:
```bash
nix run .#
```
or
```bash
nix run github:pyqlsa/neovim-flake
```

Taking the default package means taking the default theme.  This flake outputs neovim variants for each theme that it supports.  To see all the themes that this flake supports:
```bash
nix flake show .#
```
or
```bash
nix flake show github:pyqlsa/neovim-flake
```

To see what this flake would look like in it's non-default theme (`onedark` `warmer`, for example):
```bash
nix run github:pyqlsa/neovim-flake#nvim-odWarmer
```

## Update plugins
```bash
nix flake update
```

## Credit
Originally based on input and references from:
- https://github.com/nickryand
- https://github.com/wiltaylor/neovim-flake
- https://github.com/jordanisaacs/neovim-flake
- https://github.com/gvolpe/neovim-flake

