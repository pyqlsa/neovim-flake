{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.bufferline;
in
{
  options.vim.bufferline = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Bufferline";
      default = true;
    };

    numbers = mkOption {
      type = types.enum [ "ordinal" "buffer_id" ];
      description = "Set the source value for tab numbers";
      default = "ordinal";
    };

    offsets = mkOption {
      type = types.str;
      description = "Set the bufferline offsets to prevent drawing of the bufferline";
      default = ''{{filetype = "NvimTree", text = "File Explorer"}}'';
    };

    showCloseIcon = mkOption {
      type = types.bool;
      description = "Render the Close icon on each bufferline tab";
      default = false;
    };
  };

  config =
    mkIf cfg.enable
      {
        vim.startPlugins = with pkgs.vimPlugins; [ bufferline ];

        vim.luaConfigRC = ''
          -- Bufferline Configuration with buffer navigation bindings
          require('bufferline').setup{
            options = {
              numbers = "${cfg.numbers}",
              diagnostics = "nvim_lsp",
              offsets = ${cfg.offsets},
              show_close_icon = ${boolToString cfg.showCloseIcon},
            },
          }
          vim.keymap.set('n', 'bn', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'bp', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'mn', ':BufferLineMoveNext<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'mp', ':BufferLineMovePrev<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'Bp', ':BufferLinePick<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'Bc', ':BufferLinePickClose<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'Br', ':BufferLineCloseRight<CR>', { noremap = true, silent = true })
          vim.keymap.set('n', 'Bl', ':BufferLineCloseLeft<CR>', { noremap = true, silent = true })
        '';
      };
}
