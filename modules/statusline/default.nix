{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.statusline.lualine;
in
{
  options.vim.statusline.lualine = {
    enable = mkOption {
      type = types.bool;
      description = "Enable lualine";
      default = true;
    };

    icons = mkOption {
      type = types.bool;
      description = "Enable icons for lualine";
      default = true;
    };

    theme = mkOption {
      type = types.str;
      description = "Theme for lualine";
      default = "auto";
    };

    sectionSeparator = {
      left = mkOption {
        type = types.str;
        description = "Section separator for left side";
        default = "";
      };

      right = mkOption {
        type = types.str;
        description = "Section separator for right side";
        default = "";
      };
    };

    componentSeparator = {
      left = mkOption {
        type = types.str;
        description = "Component separator for left side";
        default = "⏽";
      };

      right = mkOption {
        type = types.str;
        description = "Component separator for right side";
        default = "⏽";
      };
    };

    activeSection = {
      a = mkOption {
        type = types.str;
        description = "active config for: | (A) | B | C       X | Y | Z |";
        default = "{'mode'}";
      };

      b = mkOption {
        type = types.str;
        description = "active config for: | A | (B) | C       X | Y | Z |";
        default = ''
          {
            {
              "branch",
              separator = '',
            },
            "diff",
          }'';
      };

      c = mkOption {
        type = types.str;
        description = "active config for: | A | B | (C)       X | Y | Z |";
        default = "{'filename'}";
      };

      x = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       (X) | Y | Z |";
        default = ''
          {
            {
              "diagnostics",
              sources = {'nvim_lsp'},
              separator = '',
              symbols = {error = '', warn = '', info = '', hint = ''},
            },
            {
              "filetype",
            },
            "fileformat",
            "encoding",
          }'';
      };

      y = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       X | (Y) | Z |";
        default = "{'progress'}";
      };

      z = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       X | Y | (Z) |";
        default = "{'location'}";
      };
    };

    inactiveSection = {
      a = mkOption {
        type = types.str;
        description = "inactive config for: | (A) | B | C       X | Y | Z |";
        default = "{}";
      };

      b = mkOption {
        type = types.str;
        description = "inactive config for: | A | (B) | C       X | Y | Z |";
        default = "{}";
      };

      c = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | (C)       X | Y | Z |";
        default = "{'filename'}";
      };

      x = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       (X) | Y | Z |";
        default = "{'location'}";
      };

      y = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       X | (Y) | Z |";
        default = "{}";
      };

      z = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       X | Y | (Z) |";
        default = "{}";
      };
    };
  };

  config =
    mkIf cfg.enable
      {
        vim.startPlugins = with pkgs.vimPlugins; [ lualine ];

        vim.luaConfigRC = ''
          -- Lualine Config
          require('lualine').setup({
            options = {
              icons_enabled = ${boolToString cfg.icons},
              theme = "${cfg.theme}",
              component_separators = {"${cfg.componentSeparator.left}","${cfg.componentSeparator.right}"},
              section_separators = {"${cfg.sectionSeparator.left}","${cfg.sectionSeparator.right}"},
              disabled_filetypes = {},
            },
            sections = {
              lualine_a = ${cfg.activeSection.a},
              lualine_b = ${cfg.activeSection.b},
              lualine_c = ${cfg.activeSection.c},
              lualine_x = ${cfg.activeSection.x},
              lualine_y = ${cfg.activeSection.y},
              lualine_z = ${cfg.activeSection.z},
            },
            inactive_sections = {
              lualine_a = ${cfg.inactiveSection.a},
              lualine_b = ${cfg.inactiveSection.b},
              lualine_c = ${cfg.inactiveSection.c},
              lualine_x = ${cfg.inactiveSection.x},
              lualine_y = ${cfg.inactiveSection.y},
              lualine_z = ${cfg.inactiveSection.z},
            },
            tabline = {},
            extensions = {"${optionalString config.vim.nvimTree.enable "nvim-tree"}"},
          })
        '';
      };
}
