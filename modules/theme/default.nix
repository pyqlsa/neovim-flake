{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.theme;
  enum' = name: flavors: other:
    if (cfg.name == name)
    then types.enum flavors
    else other;
in
{
  options.vim.theme = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Theme";
      default = true;
    };

    name = mkOption {
      type = types.enum [ "nightfox" "onedark" "tokyonight" "catppuccin" "vscode" ];
      description = ''Name of theme to use: "nightfox" "onedark" "tokyonight" "catppuccin" "vscode"'';
      default = "nightfox";
    };

    style = mkOption {
      type =
        let
          nf = enum' "nightfox" [ "nightfox" "carbonfox" "duskfox" "terafox" "nordfox" ];
          od = enum' "onedark" [ "dark" "darker" "cool" "deep" "warm" "warmer" ];
          tn = enum' "tokyonight" [ "day" "night" "storm" "moon" ];
          cp = enum' "catppuccin" [ "frappe" "latte" "macchiato" "mocha" ];
          vs = types.enum [ "dark" "light" ];
        in
        nf (od (tn (cp vs)));
      description = ''Theme style associaed with the chosen theme: "carbonfox", "darker", "night", "mocha", "dark", etc.'';
      default = "carbonfox";
    };

    transparency = mkOption {
      type = types.bool;
      description = "Background transparency";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; (
      (withPlugins (cfg.name == "nightfox") [ nightfox-nvim ])
      ++ (withPlugins (cfg.name == "onedark") [ onedark-nvim ])
      ++ (withPlugins (cfg.name == "tokyonight") [ tokyonight-nvim ])
      ++ (withPlugins (cfg.name == "catppuccin") [ catppuccin-nvim ])
      ++ (withPlugins (cfg.name == "vscode") [ vscode-nvim ])
    );

    vim.luaConfigRC =
      let
        themeConfigs = {
          "nightfox" = ''
            -- Nightfox Theme
            require('${cfg.name}').setup({
              options = {
                style = "${cfg.style}",
                transparent = ${boolToString cfg.transparency},
              }
            })
            vim.cmd("colorscheme ${cfg.style}")
          '';

          "onedark" = ''
            -- OneDark Theme
            require('${cfg.name}').setup({
              style = "${cfg.style}",
              transparent = ${boolToString cfg.transparency},
            })
            require('${cfg.name}').load()
          '';

          "tokyonight" = ''
            -- TokyoNight Theme
            require('${cfg.name}').setup({
              style = "${cfg.style}",
              transparent = ${boolToString cfg.transparency},
            })
            vim.cmd("colorscheme ${cfg.name}")
          '';

          "catppuccin" = ''
            -- Catppuccin Theme
            require("${cfg.name}").setup({
              flavour = "${cfg.style}",
              transparent_background = ${boolToString cfg.transparency},
            })
            vim.cmd("colorscheme ${cgf.name}")
          '';

          "vscode" = ''
            -- VScode Theme
            vim.o.background = "${cfg.style}"
            require('${cfg.name}').setup({
              transparent = ${boolToString cfg.transparency},
            })
          '';
        };
      in
      "${themeConfigs."${cfg.name}"}";
  };
}
