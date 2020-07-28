{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.honeytail;
  honeytailConf = pkgs.writeText "honeytail.conf" ''
    ParserName = ${cfg.ParserName}
    WriteKey = ${cfg.WriteKey}
    LogFiles = ${cfg.LogFiles}
    Dataset = ${cfg.Dataset}
    ${cfg.extraConfig}
  '';

in
{
  options = {
    services.honeytail = {
      enable = mkEnableOption "honeytail";

      # Required options
      ParserName = mkOption {
        description = "Parser module to use.";
        type = types.str;
        default = "json";
      };

      WriteKey = mkOption {
        description = "Team write key";
        type = types.str;
        default = null;
      };

      LogFiles = mkOption {
        description = "Log file(s) to parse. Use '-' for STDIN, use this flag multiple times to tail multiple files, or use a glob (/path/to/foo-*.log)";
        type = with types; either (nonEmptyListOf str) str;
        default = [ ];
      };

      Dataset = mkOption {
        description = "Name of the dataset";
        type = types.str;
        default = "";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = null;
        description = "Additonal Honeytail configuration options.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.honeytail = {
      Description = "Honeycomb log tailer honeytail";
      After = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.honeytail}/bin/honeytail --config \"${honeytailConf}\"";
        User = "honeycomb";
        Group = "honeycomb";
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitInterval = 0;
      };
    };
  };
}
