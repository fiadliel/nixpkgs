{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.vector;
  vectorConfig = pkgs.writeText "vector.conf" ''
    [sources.in]
      type = "journald"

    [transforms.ec2_metadata]
      type = "aws_ec2_metadata"
      inputs = ["in"]

    [sinks.out]
      encoding.codec = "json"
      inputs = ["ec2_metadata"]

      type = "aws_cloudwatch_logs"
      create_missing_group = false
      create_missing_stream = true
      group_name = "vector"
      region = "us-east-1"
      stream_name = "{{ host }}"
  '';
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
      type = with types;  uniq string;
      description = "Group under which vector runs";
      default = "vector";
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
      script        = "${cfg.package}/bin/vector --config ${vectorConfig}";

      serviceConfig = {
        User = cfg.user;
	Group = cfg.group;
	Restart = "no";
      };
    };
  };
}
