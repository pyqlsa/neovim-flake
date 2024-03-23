{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in
{
  options.vim.lsp = {
    enable = mkEnableOption "neovim lsp support";
    formatOnSave = mkEnableOption "Format on save";
    nix = mkEnableOption "Nix LSP";
    rust = {
      enable = mkEnableOption "Rust LSP";
      rustAnalyzerOpts = mkOption {
        type = types.str;
        default = ''
          experimental = {
              procAttrMacros = true,
            }'';
        description = "options to pass to rust analyzer";
      };
    };
    python = mkEnableOption "Python LSP";
    clang = mkEnableOption "C Language LSP";
    sh = mkEnableOption "SH Language LSP";
    go = mkEnableOption "Go language LSP";
    ts = mkEnableOption "TS language LSP";
    terraform = mkEnableOption "Terraform LSP";
    haskell = mkEnableOption "Haskell LSP";
    lua = mkEnableOption "Lua LSP";
    zig = mkEnableOption "Zig LSP";
    toml = mkEnableOption "Toml LSP";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [ nvim-lspconfig efmls-configs-nvim ]
      ++ (optionalItems config.vim.autocomplete.enable [ cmp-nvim-lsp ])
      ++ (optionalItems cfg.rust.enable [ crates-nvim rust-tools-nvim ]);

    vim.additionalPackages = with pkgs; [ efm-langserver ]
      ++ (optionalItems cfg.go [ go-tools gofumpt gopls ])
      ++ (optionalItems cfg.clang [ clang-tools ])
      ++ (optionalItems cfg.nix [ nil nixpkgs-fmt ])
      ++ (optionalItems cfg.python [ nodePackages.pyright ])
      ++ (optionalItems cfg.rust.enable [ cargo rustc rustfmt rust-analyzer ])
      ++ (optionalItems cfg.sh [ shellcheck shfmt ])
      ++ (optionalItems cfg.ts [ nodejs eslint_d prettierd nodePackages.typescript-language-server ])
      ++ (optionalItems cfg.terraform [ terraform-ls ])
      ++ (optionalItems cfg.haskell [ ghc haskellPackages.cabal-fmt haskell-language-server ormolu ])
      ++ (optionalItems cfg.lua [ lua-language-server ])
      ++ (optionalItems cfg.zig [ zls ])
      ++ (optionalItems cfg.toml [ taplo ]);

    vim.luaConfigRC = ''
      ${optionalString cfg.rust.enable ''
        -- LSP Rust
        vim.keymap.set('n', '<leader>ri',
          function() return require('rust-tools.inlay_hints').toggle_inlay_hints() end,
          {silent = true, noremap = true})
        vim.keymap.set('n', '<leader>rr',
          function() return require('rust-tools.runnables').runnables() end,
          {silent = true, noremap = true})
        vim.keymap.set('n', '<leader>re',
          function() return require('rust-tools.expand_macro').expand_macro() end,
          {silent = true, noremap = true})
        vim.keymap.set('n', '<leader>rc',
          function() return require('rust-tools.open_cargo_toml').open_cargo_toml() end,
          {silent = true, noremap = true})
        vim.keymap.set('n', '<leader>rg',
          function() return require('rust-tools.crate_graph').view_create_graph('x11', nil) end,
          {silent = true, noremap = true})''}

      ${optionalString cfg.nix ''
        -- LSP Nix
        local nix_setup = function()
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
        end
        vim.api.nvim_create_autocmd("FileType", { match = nix, callback = nix_setup })''}

      ${optionalString cfg.clang ''
        -- LSP Clang
        vim.g.c_syntax_for_h = 1''}

      -- Mappings.
      -- From: https://github.com/neovim/nvim-lspconfig/blob/master/README.md
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      local opts = { noremap=true, silent=true }
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
      end

      ${optionalString cfg.formatOnSave ''
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function ()
              vim.lsp.buf.format({async = false})
            end,
          })

        local toggle_format_on_save = function()
          local ignoring_buf_write_pre = false

          for _, event in pairs(vim.opt.eventignore:get()) do
            if event == "BufWritePre" then
              ignoring_buf_write_pre = true
            end
          end

          if ignoring_buf_write_pre then
            vim.opt.eventignore:remove({ "BufWritePre" })
            vim.print("enabled format on save")
          else
            vim.opt.eventignore:append({ "BufWritePre" })
            vim.print("disabled format on save")
          end
        end

        vim.api.nvim_create_user_command("ToggleFormatOnSave", toggle_format_on_save, { desc = "Toggle format on save" })
        vim.keymap.set("n", "<leader>t", toggle_format_on_save, { desc = "Toggle format on save" })
      ''}

      default_on_attach = function(client, bufnr)
        on_attach(client, bufnr)
      end

      --- Enable lspconfig
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      ${optionalString config.vim.autocomplete.enable ''
          capablities = require("cmp_nvim_lsp").default_capabilities(capabilities)''}

      --- EFM langserver
      local languages = {
      ${optionalString cfg.ts ''
        typescript = {
          require('efmls-configs.linters.eslint_d'),
          require('efmls-configs.formatters.prettier_d'),
        },''}
      ${optionalString cfg.sh ''
        sh = {
          require('efmls-configs.linters.shellcheck'),
          require('efmls-configs.formatters.shfmt'),
        },''}
      ${optionalString cfg.toml ''
        toml = {
          require('efmls-configs.formatters.taplo'),
        },''}
      }
      local efmls_config = {
        filetypes = vim.tbl_keys(languages),
        settings = {
          rootMarkers = { '.git/' },
          languages = languages,
        },
        init_options = {
          documentFormatting = true,
          documentRangeFormatting = true,
        },
      }

      lspconfig.efm.setup(vim.tbl_extend('force', efmls_config, {
        capabilities = capabilities,
        on_attach = default_on_attach,
        cmd = {"efm-langserver"},
      }))

      ${optionalString cfg.rust.enable ''
        -- Rust Config
        local rustAnalyzerOpts = {
          ${cfg.rust.rustAnalyzerOpts},
        }
        local rustopts = {
          tools = {
            autoSetHints = true,
            hover_with_actions = false,
            inlay_hints = {
              only_current_line = false,
            },
          },
          server = {
            capabilities = capabilities,
            on_attach = default_on_attach,
            cmd = {"rust-analyzer"},
            settings = {
              ["rust-analyzer"] = rustAnalyzerOpts,
            },
          },
        }
        require("crates").setup{}
        require("rust-tools").setup(rustopts)''}

      ${optionalString cfg.python ''
        -- Python Config
        lspconfig.pyright.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"pyright-langserver", "--stdio"},
        }''}

      ${optionalString cfg.nix ''
        -- Nix (nil) Config
        lspconfig.nil_ls.setup{
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = {"nil"},
          settings = {
            ['nil'] = {
              formatting = {
                command = { "nixpkgs-fmt" },
              },
            },
          },
        }''}

      ${optionalString cfg.clang ''
        -- Clang Config
        lspconfig.clangd.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
        }''}

      ${optionalString cfg.go ''
        -- Go Config
        lspconfig.gopls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"gopls", "serve"},
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
            },
          },
        }

        function go_org_imports(wait_ms)
          local params = vim.lsp.util.make_range_params()
          params.context = {only = {"source.organizeImports"}}
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
        end

        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = {"*.go"},
          callback = function ()
            go_org_imports(200)
          end,
        })''}

      ${optionalString cfg.ts ''
        -- TS config
        lspconfig.tsserver.setup {
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = {"typescript-language-server", "--stdio"},
        }''}

      ${optionalString cfg.terraform ''
        -- Terraform config
        lspconfig.terraformls.setup {
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = {"terraform-ls", "serve"},
        }''}

      ${optionalString cfg.haskell ''
        -- Haskell config
        lspconfig.hls.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
        }''}

      ${optionalString cfg.lua ''
        -- Lua config
        lspconfig.lua_ls.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        }''}

      ${optionalString cfg.zig ''
        -- Zig config
        lspconfig.zls.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
        }''}
    '';
  };
}
