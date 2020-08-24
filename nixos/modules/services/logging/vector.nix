{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.vector;
in
{
  options.services.vector = {
    enable = mkEnableOption "Vector Observability Pipeline";

    package = mkOption {
      type = types.path;
      description = "The Vector package to use";
      default = pkgs.vector;
      defaultText = "pkgs.vector";
    };

    user = mkOption {
      type = with types; uniq string;
      description = "User account under which vector runs";
      default = "vector";
    };

    group = mkOption {
      type = with types; uniq string;
      description = "Group under which vector runs";
      default = "vector";
    };

    configDir = mkOption {
      type = types.path;
      description = "Vector configuration directory";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.vector = {
      inherit (cfg.package.meta) description;
      documentation = [ "https://vector.dev/" ];
      after         = [ "network-online.target" ];
      requires      = [ "network-online.target" ];
      wantedBy      = [ "multi-user.target" ];
      reload        = "kill -HUP $MAINPID";
      script        = "${cfg.package}/bin/vector --config ${cfg.configDir}";

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
	Restart = "no";
      };
    };
  };
}
