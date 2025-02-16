{ mode, soxin, options, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.rofi;

  modi = concatStringsSep ","
    (mapAttrsToList (n: v: if v == null then n else "${n}:${v}") cfg.modi);
in
{
  options = {
    soxin.programs.rofi = soxin.lib.mkSoxinModule {
      inherit config;
      name = "rofi";
      includeTheme = true;

      extraOptions = {
        modi = mkOption {
          type = with types; attrsOf (nullOr str);
          default = { };
          description = ''
            rofi.modi configuration option. The attribute name is used as the
            modi name. If the attribute value is not null, its path is given to
            rofi.
          '';
          example = {
            custom = "/some/custom/script.sh";
          };
        };

        i3 = {
          enable = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = ''
              Whether to enable i3 support for rofi.

              When enabled, you can set i3 bindings to the following commands:
              exec ''${pkgs.rofi}/bin/rofi -show i3Workspaces
              exec ''${pkgs.rofi}/bin/rofi -show i3RenameWorkspace
              exec ''${pkgs.rofi}/bin/rofi -show i3MoveContainer
            '';
          };
        };

        dpi = mkOption {
          type = with types; nullOr ints.positive;
          default = null;
          description = "The DPI of the rofi.";
          apply = value: toString value;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.programs.rofi.modi = mkIf (cfg.i3.enable) {
        i3Workspaces = "${pkgs.rofi-i3-support}/bin/i3-switch-workspaces";
        i3RenameWorkspace = "${pkgs.rofi-i3-support}/bin/i3-rename-workspace";
        i3MoveContainer = "${pkgs.rofi-i3-support}/bin/i3-move-container";
      };
    }

    (optionalAttrs (mode == "home-manager") {
      programs.rofi = {
        enable = true;

        theme = cfg.theme.name;

        extraConfig = ''
          rofi.modi: ${modi}
        '' + (optionalString (cfg.dpi != null) ''
          rofi.dpi: ${cfg.dpi}
        '');

        font = "Source Code Pro for Powerline 9";
      };
    })
  ]);
}
