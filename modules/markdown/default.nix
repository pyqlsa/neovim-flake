{ config
, lib
, pkgs
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.markdown;
in
{
  options.vim.markdown = {
    enable = mkEnableOption "markdown tools and plugins";
    glow.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable markdown preview in neovim with glow";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [ glow-nvim ];

    vim.luaConfigRC = optionalString cfg.glow.enable ''
      -- Glow config
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow",
        border = "shadow",
        pager = false,
        width = 120,
      })

      vim.api.nvim_create_autocmd("FileType", { match = markdown, command = [[nnoremap <leader>p :Glow<CR>]] })
    '';
  };
}
