{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.comment;
in
{
  options.vim.comment = {
    enable = mkOption {
      type = types.bool;
      description = "Enable nvim-comment";
      default = true;
    };

    markerPadding = mkOption {
      type = types.bool;
      description = "Linters prefer comment and line to have a space in between markers; enable this behavior";
      default = true;
    };

    commentEmpty = mkOption {
      type = types.bool;
      description = "Enable commenting empty lines";
      default = false;
    };

    commentEmptyTrimWhitespace = mkOption {
      type = types.bool;
      description = "Trim empty comment whitespace";
      default = true;
    };

    createMappings = mkOption {
      type = types.bool;
      description = "Create key mappings";
      default = true;
    };

    lineMapping = mkOption {
      type = types.str;
      description = "Normal mode mapping left hand side";
      default = "gcc";
    };

    operatorMapping = mkOption {
      type = types.str;
      description = "Visual/Operator mapping left hand side";
      default = "gc";
    };

    commentChunkTextObject = mkOption {
      type = types.str;
      description = "Text object mapping, comment chunk";
      default = "ic";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [ nvim-comment ];

    vim.luaConfigRC = ''
      -- Comment setup and bindings
      require('nvim_comment').setup({
        marker_padding = ${boolToString cfg.markerPadding},
        comment_empty = ${boolToString cfg.commentEmpty},
        comment_empty_trim_whitespace = ${boolToString cfg.commentEmptyTrimWhitespace},
        create_mappings = ${boolToString cfg.createMappings},
        line_mapping = "${cfg.lineMapping}",
        operator_mapping = "${cfg.operatorMapping}",
        comment_chunkTextObject = "${cfg.commentChunkTextObject}",
      })
    '';
  };
}
