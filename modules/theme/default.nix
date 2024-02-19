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
    name = mkOption {
      type = types.enum [ "nightfox" "onedark" "tokyonight" "catppuccin" "rose-pine" "none" ];
      description = ''Name of theme to use: "nightfox" "onedark" "tokyonight" "catppuccin" "rose-pine" "none"'';
      default = "none";
    };

    style = mkOption {
      type =
        let
          nf = enum' "nightfox" [ "nightfox" "carbonfox" "duskfox" "terafox" "nordfox" ];
          od = enum' "onedark" [ "dark" "darker" "cool" "deep" "warm" "warmer" ];
          tn = enum' "tokyonight" [ "day" "night" "storm" "moon" ];
          cp = enum' "catppuccin" [ "frappe" "latte" "macchiato" "mocha" ];
          rp = enum' "rose-pine" [ "main" "moon" "dawn" ];
          none = types.enum [ "none" ];
        in
        nf (od (tn (cp (rp none))));
      description = ''Theme style associaed with the chosen theme: "carbonfox", "darker", "night", "mocha", "dark", etc.'';
      default = "none";
    };

    transparency = mkOption {
      type = types.bool;
      description = "Background transparency";
      default = false;
    };
  };

  config = {
    vim.startPlugins = with pkgs.vimPlugins; (
      (optionalItems (cfg.name == "nightfox") [ nightfox-nvim ])
      ++ (optionalItems (cfg.name == "onedark") [ onedark-nvim ])
      ++ (optionalItems (cfg.name == "tokyonight") [ tokyonight-nvim ])
      ++ (optionalItems (cfg.name == "catppuccin") [ catppuccin-nvim ])
      ++ (optionalItems (cfg.name == "rose-pine") [ rose-pine ])
    );

    vim.luaConfigRC =
      let
        themeConfigs = {
          "none" = ''
            -- No Theme (use a tolerable builtin instead)
            vim.cmd("set background=dark")
            vim.cmd("colorscheme lunaperche")
          '';

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
            vim.cmd("colorscheme ${cfg.name}")
          '';

          "rose-pine" = ''
            -- Rose-Pine Theme
            require('${cfg.name}').setup({
              variant = "${cfg.style}",
              styles = {
                transparency = ${boolToString cfg.transparency},
              },
            })
            vim.cmd("colorscheme ${cfg.name}")
          '';
        };
      in
      "${themeConfigs."${cfg.name}"}";
  };
}
