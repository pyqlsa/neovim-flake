{
  description = "pyqlsa's Neovim Configuration";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    # Langauge server (use master instead of nixpkgs)
    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    # LSP plugins
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    nvim-treesitter-context = {
      url = "github:lewis6991/nvim-treesitter-context";
      flake = false;
    };
    null-ls = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };
    lspkind = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };

    # Autopairs
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };

    crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };

    # Visuals
    nvim-cursorline = {
      url = "github:yamatsum/nvim-cursorline";
      flake = false;
    };
    indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    #gitsigns-nvim = {
    #  url = "github:lewis6991/gitsigns.nvim";
    #  flake = false;
    #};
    vscode-nvim = {
      url = "github:mofiqul/vscode.nvim";
      flake = false;
    };
    nightfox-nvim = {
      url = "github:EdenEast/nightfox.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    catppuccin-nvim = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
    onedark-nvim = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };
    tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    bufferline = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    lualine = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };

    # Navigation
    nvim-tree = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };
    nvim-comment = {
      url = "github:terrortylor/nvim-comment";
      flake = false;
    };

    # Telescope
    telescope = {
      url = "github:nvim-telescope/telescope.nvim/0.1.x";
      flake = false;
    };

    # Markdown
    glow-nvim = {
      # early job SIGTERM bug breaks preview
      #url = "github:ellisonleao/glow.nvim?rev=4e4c6486110d9d9905d2efc5fd2d562212f0d212";
      url = "github:pyqlsa/glow.nvim/blank-preview";
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
        plugins = [
          "nvim-cursorline"
          "indent-blankline"
          "nvim-web-devicons"
          "nvim-treesitter"
          "nvim-treesitter-context"
          "nvim-lspconfig"
          "rnix-lsp"
          "null-ls"
          "crates-nvim"
          "plenary-nvim"
          "nvim-cmp"
          "cmp-buffer"
          "cmp-nvim-lsp"
          "cmp-vsnip"
          "cmp-path"
          "cmp-treesitter"
          "lspkind"
          "nvim-autopairs"
          "nvim-ts-autotag"
          "vim-vsnip"
          "rust-tools"
          "nvim-tree"
          "vscode-nvim"
          "nightfox-nvim"
          "tokyonight-nvim"
          "catppuccin-nvim"
          "onedark-nvim"
          "bufferline"
          "nvim-comment"
          "lualine"
          "telescope"
          "glow-nvim"
        ];

        lib = import ./lib { inherit pkgs inputs plugins; };

        pluginOverlay = lib.buildPluginOverlay;

        externalBitsOverlay = final: prev: {
          rnix-lsp = inputs.rnix-lsp.defaultPackage.${final.system};
        };

        libOverlay = final: prev: {
          lib = prev.lib.extend (_: _: {
            inherit (lib) boolToYesNo withPlugins;
          });
        };

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            libOverlay
            pluginOverlay
            externalBitsOverlay
          ];
        };

        neovimBuilder = lib.neovimBuilder {
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
              terraform = true;
            };
            vim.telescope = {
              enable = true;
            };
            vim.markdown = {
              enable = true;
            };
            vim.theme = {
              enable = true;
              name = "nightfox";
              style = "carbonfox";
            };
            vim.keyMaps = [
              {
                mode = "'n'";
                lhs = "'<C-i>'";
                rhs = "':bprevious<cr>'";
                options = "{ noremap = true, silent = true}";
              }
              {
                mode = "'n'";
                lhs = "'<C-o>'";
                rhs = "':bnext<cr>'";
                options = "{ noremap = true, silent = true}";
              }
            ];
          };
        };
      in
      rec
      {
        apps = rec {
          nvim = {
            type = "app";
            program = "${packages.default}/bin/nvim";
          };
          default = nvim;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.default ];
        };

        overlays.default = final: prev: {
          inherit neovimBuilder;
          neovim = packages.default;
          neovimPlugins = pkgs.neovimPlugins;
        };

        packages = rec {
          default = neovim;
          neovim = neovimBuilder;
        };
      }
    );
}
