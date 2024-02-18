{ pkgs
, lib
, config
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
in
{
  options.vim = {
    autocomplete = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Neovim Autocompletion module";
      };
    };
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = with pkgs.vimPlugins; [
      nvim-cmp
      cmp-buffer
      cmp-vsnip
      cmp-path
      cmp-treesitter
    ];
    vim.luaConfigRC = ''
      --- nvim-cmp settings
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },

        sources = {
          ${optionalString (config.vim.lsp.enable) "{ name = 'nvim_lsp' },"}
          ${optionalString (config.vim.lsp.rust.enable) "{ name = 'crates' },"}
          { name = 'vsnip' },
          { name = 'treesitter' },
          { name = 'path' },
          { name = 'buffer' },
        },

        mapping = {
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
          ['<C-space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn['vsnip#available'](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, {'i', 's'}),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn['vsnip#available'](-1) == 1 then
              feedkeys("<Plug>(vsnip-jump-prev)", "")
            end
          end, {'i', 's'})
        },

        completion = {
          completeopt = 'menu,menuone,noinsert',
        },

        formatting = {
          format = function(entry, vim_item)
            ${optionalString (config.vim.visuals.lspkind.enable) ''
        --type of kind
        local k = require('lspkind').presets.default[vim_item.kind]
        if k ~= nil and k ~= "" then
          vim_item.kind = k .. ' ' .. vim_item.kind
        else
        end''}

            --name of each source
            vim_item.menu = ({
              buffer   = "[Buffer]",
              nvim_lsp = "[LSP]",
              vsnip    = "[VSnip]",
              crates   = "[Crates]",
              path     = "[Path]",
            })[entry.source.name]

            return vim_item
          end,
        }
      })

      ${optionalString config.vim.autopairs.enable ''
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { text = "" } }))''}
    '';

    vim.snippets.vsnip.enable = true;
  };
}
