{ config
, lib
, pkgs
, ...
}:
with lib;
with builtins; let
  cfg = config.vim;
in
{
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = false;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = types.bool;
      default = true;
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = types.lines;
      default = "";
    };

    startLuaConfigRC = mkOption {
      description = "start of the vim lua config";
      type = types.lines;
      default = "";
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = types.lines;
      default = "";
    };

    startPlugins = mkOption {
      description = "List of plugins to startup";
      default = [ ];
      type = with types; listOf (nullOr package);
    };

    optPlugins = mkOption {
      description = "List of plugins to optionally load";
      default = [ ];
      type = with types; listOf package;
    };

    globals = mkOption {
      description = "Set containing global variable values";
      default = { };
      type = types.attrs;
    };

    keyMaps = mkOption {
      description = "Key bindings map in lua";
      default = [ ];
      type = with types; listOf attrs;
    };
  };

  config =
    let
      filterNonNull = mappings: filterAttrs (name: value: value != null) mappings;
      globalSettings =
        mapAttrsFlatten (name: value: "vim.g.${name} = ${value}")
          (filterNonNull cfg.globals);

      keyboardBindings = (
        builtins.map
          (
            binding: "vim.keymap.set(${binding.mode}, ${binding.lhs}, ${binding.rhs}, ${binding.options})"
          )
          cfg.keyMaps
      );
    in
    {
      vim.configRC = ''
        " Lua config from vim.luaConfigRC
        lua <<EOF
        --- Configuration that needs to be loaded early
        ${cfg.startLuaConfigRC}

        --- Globals
        ${builtins.concatStringsSep "\n" globalSettings}

        --- Key Bindings
        ${builtins.concatStringsSep "\n" keyboardBindings}

        --- Generated module configs
        ${cfg.luaConfigRC}
        EOF
      '';
    };
}
