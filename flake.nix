{
  description = "pyqlsa's Neovim Configuration";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    plugin-plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    # LSP plugins
    plugin-nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    plugin-efmls-configs-nvim = {
      url = "github:creativenull/efmls-configs-nvim";
      flake = false;
    };
    plugin-nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter/v0.9.1";
      #url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    plgin-nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    plugin-nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    plugin-cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    plugin-cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    plugin-cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    plugin-cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    plugin-cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    plugin-vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };
    plugin-lspkind-nvim = {
      url = "github:onsails/lspkind.nvim";
      flake = false;
    };

    # Autopairs
    plugin-nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    plugin-nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };

    # Rust
    plugin-crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    plugin-rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };

    # Visuals
    plugin-nvim-cursorline = {
      url = "github:yamatsum/nvim-cursorline";
      flake = false;
    };
    plugin-indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    plugin-nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    #gitsigns-nvim = {
    #  url = "github:lewis6991/gitsigns.nvim";
    #  flake = false;
    #};
    plugin-vscode-nvim = {
      url = "github:mofiqul/vscode.nvim";
      flake = false;
    };
    plugin-nightfox-nvim = {
      url = "github:EdenEast/nightfox.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    plugin-catppuccin-nvim = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
    plugin-onedark-nvim = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };
    plugin-tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    plugin-bufferline = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    plugin-lualine = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };

    # Navigation
    plugin-nvim-tree = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };

    # Comment toggle
    plugin-nvim-comment = {
      url = "github:terrortylor/nvim-comment";
      flake = false;
    };

    # Telescope
    plugin-telescope = {
      url = "github:nvim-telescope/telescope.nvim/0.1.x";
      flake = false;
    };

    # Markdown preview
    plugin-glow-nvim = {
      url = "github:ellisonleao/glow.nvim";
      flake = false;
    };
  };

  outputs =
    { nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        _lib = import ./lib { inherit pkgs inputs; };

        pluginOverlay = _lib.buildPluginOverlay;

        #externalPkgsOverlay = final: prev: {
        #  <some-pkg> = inputs.<some-pkg>.defaultPackage.${final.system};
        #};

        libOverlay = final: prev: {
          lib = prev.lib.extend (_: _: {
            inherit (_lib) boolToYesNo withPlugins luaFormatted;
          });
        };

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            libOverlay
            pluginOverlay
            #externalPkgsOverlay
          ];
        };

        machinery = {
          config = {
            vim.autocomplete.enable = true;
            vim.autopairs.enable = true;
            vim.lsp = {
              enable = true;
              formatOnSave = true;
              nix = true;
              rust.enable = true;
              go = true;
              python = true;
              sh = true;
              terraform = true;
            };
            vim.telescope = {
              enable = true;
            };
            vim.markdown = {
              enable = true;
            };
            vim.keyMaps = [
              {
                mode = "'n'";
                lhs = "'<C-i>'";
                rhs = "':bprevious<cr>'";
                options = "{ noremap = true, silent = true }";
              }
              {
                mode = "'n'";
                lhs = "'<C-o>'";
                rhs = "':bnext<cr>'";
                options = "{ noremap = true, silent = true }";
              }
            ];
          };
        };

        neovimBuilder = theme: _lib.neovimBuilder (pkgs.lib.recursiveUpdate machinery theme);
      in
      rec
      {
        apps =
          rec {
            default = nvim;
            nvim = {
              type = "app";
              program = "${packages.default}/bin/nvim";
            };
          }
          // _lib.allThemedApps "nvim" neovimBuilder;

        devShells =
          rec {
            default = neovim;
            neovim = pkgs.mkShell {
              buildInputs = [ packages.default ];
            };
          }
          // _lib.allThemedShells "neovim" neovimBuilder;

        overlays = rec {
          default = neovim;
          neovim = final: prev:
            {
              vimPlugins = pkgs.vimPlugins;
              neovimPQ = packages.default;
            }
            // _lib.allThemedPackages "neovimPQ" neovimBuilder;
        };

        packages =
          rec {
            default = neovim;
            neovim = neovimBuilder _lib.defaultTheme;
          }
          // _lib.allThemedPackages "neovim" neovimBuilder;
      }
    );
}
