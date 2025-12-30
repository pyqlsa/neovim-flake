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
    rust = mkEnableOption "Rust LSP";
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
      ++ (optionalItems cfg.rust [ crates-nvim ]);

    vim.additionalPackages = with pkgs; [ efm-langserver ]
      ++ (optionalItems cfg.go [ go-tools gofumpt gopls ])
      ++ (optionalItems cfg.clang [ clang-tools ])
      ++ (optionalItems cfg.nix [ nil nixpkgs-fmt ])
      ++ (optionalItems cfg.python [ nodejs pyright ruff ])
      ++ (optionalItems cfg.rust [ cargo rustc rustfmt rust-analyzer ])
      ++ (optionalItems cfg.sh [ shellcheck shfmt ])
      ++ (optionalItems cfg.ts [ nodejs eslint_d prettierd nodePackages.typescript-language-server ])
      ++ (optionalItems cfg.terraform [ terraform-ls ])
      ++ (optionalItems cfg.haskell [ ghc haskellPackages.cabal-fmt haskell-language-server ormolu ])
      ++ (optionalItems cfg.lua [ lua-language-server ])
      ++ (optionalItems cfg.zig [ zls ])
      ++ (optionalItems cfg.toml [ taplo ]);

    vim.luaConfigRC = ''
      ${optionalString cfg.rust ''
        -- LSP Rust: XXX: TODO: rustaceanvim???
        --vim.keymap.set('n', '<leader>ri',
        --  function() return require('rust-tools.inlay_hints').toggle_inlay_hints() end,
        --  {silent = true, noremap = true})
        --vim.keymap.set('n', '<leader>rr',
        --  function() return require('rust-tools.runnables').runnables() end,
        --  {silent = true, noremap = true})
        --vim.keymap.set('n', '<leader>re',
        --  function() return require('rust-tools.expand_macro').expand_macro() end,
        --  {silent = true, noremap = true})
        --vim.keymap.set('n', '<leader>rc',
        --  function() return require('rust-tools.open_cargo_toml').open_cargo_toml() end,
        --  {silent = true, noremap = true})
        --vim.keymap.set('n', '<leader>rg',
        --  function() return require('rust-tools.crate_graph').view_create_graph('x11', nil) end,
        --  {silent = true, noremap = true})''}

      ${optionalString cfg.nix ''
        -- LSP Nix
        local nix_setup = function()
          vim.bo.tabstop = ${toString config.vim.tabWidth}
          vim.bo.shiftwidth = ${toString config.vim.tabWidth}
          vim.bo.softtabstop = ${toString config.vim.tabWidth}
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

      vim.diagnostic.config({
        underline = true,
        signs = true,
        virtual_text = true,
        virtual_lines = false
      })

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

        -- Inlay Hints
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
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
      --- [XXX: TODO] local lspconfig = require("lspconfig")
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
          { formatCommand = "shfmt -ci -s -bn -i ${toString config.vim.tabWidth}", formatStdin = true },
        },''}
      ${optionalString cfg.python ''
        python = {
          require('efmls-configs.linters.ruff'),
          require('efmls-configs.formatters.ruff'),
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

      vim.lsp.config('efm', vim.tbl_extend('force', efmls_config, {
        capabilities = capabilities,
        on_attach = default_on_attach,
        cmd = {"efm-langserver"},
      }))
      vim.lsp.enable('efm')

      ${optionalString cfg.rust ''
        -- Rust Config
        local rustAnalyzerConfig = {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"rust-analyzer"},
          filetypes = { 'rust' },
          root_markers = {"Config.toml", ".git"},
          single_file_support = true,
          settings = {
            ['rust-analyzer'] = {
              experimental = {
                procAttrMacros = true,
              },
              inlayHints = {
                enable = true,
              },
            },
          },
          before_init = function(init_params, config)
            -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
            if config.settings and config.settings['rust-analyzer'] then
              init_params.initializationOptions = config.settings['rust-analyzer']
            end
          end,
        }
        -- XXX: TODO: not using; possible future move to rustaceanvim
        local rustToolsConfig = {
          tools = {
            autoSetHints = true,
            hover_with_actions = false,
            inlay_hints = {
              only_current_line = false,
            },
          },
          server = rustAnalyzerConfig,
        }
        vim.lsp.config('rust-analyzer', rustAnalyzerConfig)
        vim.lsp.enable('rust-analyzer')
        require("crates").setup{}''}

      ${optionalString cfg.python ''
        -- Python Config
        vim.lsp.config('pyright', {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"pyright-langserver", "--stdio"},
        })
        vim.lsp.enable('pyright')''}

      --- XXX: TODO
      ${optionalString cfg.nix ''
        -- Nix (nil) Config
        vim.lsp.config('nil_ls', {
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = { "nil" },
          filetypes = { "nix" },
          settings = {
            ['nil'] = {
              nix = {
                flake = {
                  autoArchive = false,
                },
              },
              formatting = {
                command = { "nixpkgs-fmt" },
              },
            },
          },
        })
        vim.lsp.enable('nil_ls')''}

      ${optionalString cfg.clang ''
        -- Clang Config
        vim.lsp.config('clangd', {
          capabilities = capabilities,
          on_attach = default_on_attach,
        })
        vim.lsp.enable('clangd')''}

      ${optionalString cfg.go ''
        -- Go Config
        vim.lsp.config('gopls', {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"gopls", "serve"},
          settings = {
            ['gopls'] = {
              gofumpt = true,
              staticcheck = true,
            },
          },
        })
        vim.lsp.enable('gopls')

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
        vim.lsp.config('ts_ls', {
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = {"typescript-language-server", "--stdio"},
        })
        vim.lsp.enable('ts_ls')''}

      ${optionalString cfg.terraform ''
        -- Terraform config
        vim.lsp.config('terraformls', {
          capabilities = capabilities,
          on_attach = on_attach,
          cmd = {"terraform-ls", "serve"},
        })
        vim.lsp.enable('terraformls')''}

      ${optionalString cfg.haskell ''
        -- Haskell config
        vim.lsp.config('hls', {
          capabilities = capabilities,
          on_attach = default_on_attach,
        })
        vim.lsp.enable('hls')''}

      ${optionalString cfg.lua ''
        -- Lua config
        vim.lsp.config('lua_ls', {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        })
        vim.lsp.enable('lua_ls')''}

      ${optionalString cfg.zig ''
        -- Zig config
        vim.lsp.config('zls', {
          capabilities = capabilities,
          on_attach = default_on_attach,
        })
        vim.lsp.enable('zls')''}
    '';
  };
}
