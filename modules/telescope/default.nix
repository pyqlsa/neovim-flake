{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.telescope;
in
{
  options.vim.telescope = {
    enable = mkEnableOption "enable telescope";
  };

  config =
    mkIf cfg.enable
      {
        vim.startPlugins = with pkgs.vimPlugins; [ telescope-nvim ];

        vim.luaConfigRC = ''
          -- Telescope Config
          require("telescope").setup {
            defaults = {
              vimgrep_arguments = {
                "${pkgs.ripgrep}/bin/rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case"
              },
              pickers = {
                find_command = {
                  "${pkgs.fd}/bin/fd",
                },
              },
            }
          }

          local builtin = require('telescope.builtin')
          vim.keymap.set('n', "<leader>ff", builtin.find_files, {})
          vim.keymap.set('n', "<leader>fg", builtin.live_grep, {})
          vim.keymap.set('n', "<leader>fb", builtin.buffers, {})
          vim.keymap.set('n', "<leader>fh", builtin.help_tags, {})
          vim.keymap.set('n', "<leader>fvcw", builtin.git_commits, {})
          vim.keymap.set('n', "<leader>fvcb", builtin.git_bcommits, {})
          vim.keymap.set('n', "<leader>fvb", builtin.git_branches, {})
          vim.keymap.set('n', "<leader>fvs", builtin.git_status, {})
          vim.keymap.set('n', "<leader>fvx", builtin.git_stash, {})
          ${optionalString config.vim.lsp.enable ''
            vim.keymap.set('n', "<leader>flsb", builtin.lsp_document_symbols, {})
            vim.keymap.set('n', "<leader>flsw", builtin.lsp_workspace_symbols, {})
            vim.keymap.set('n', "<leader>flr", builtin.lsp_references, {})
            vim.keymap.set('n', "<leader>fli", builtin.lsp_implementations, {})
            vim.keymap.set('n', "<leader>flD", builtin.lsp_definitions, {})
            vim.keymap.set('n', "<leader>flt", builtin.lsp_type_definitions, {})
            vim.keymap.set('n', "<leader>fld", builtin.diagnostics, {})''}
          ${optionalString config.vim.treesitter.enable ''
              vim.keymap.set('n', "<leader>fs", builtin.treesitter, {})''}
        '';
      };
}
