{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.ngrok;

in {

  options.services.ngrok = {
    enable = mkEnableOption "Ngrok tls service";

    authtoken = mkOption {
      type = types.str;
      default = "";
      defaultText = literalExample "<your-ngrok-token>";
      description = "The ngrok auth token to use.";
    };

    loglevel = mkOption {
      type = types.str;
      default = "debug";
      defaultText = literalExample "debug";
      description = "The log level to use.";
    };

    tunnels = mkOption {
      type = types.attrs;
      default = { };
      defaultText = literalExample ''
        {
          ssh = {
            proto = "tcp";
            addr = 22;
          };
        }
      '';
      description = "Which tunnels to make available.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.ngrok;
      defaultText = literalExample "pkgs.ngrok";
      description = "Which ngrok package to install.";
    };

  };

  config = let
    ngrok-config = pkgs.writeText "ngrok.yml" (builtins.toJSON {
      tunnels = cfg.tunnels;
      authtoken = cfg.authtoken;
    });
  in mkIf cfg.enable {

    home.packages = [ cfg.package ];

    systemd.user = {
      services.ngrok = {
        Unit = {
          Description = "Ngrok services";
          After = "network.target";
        };

        Service = {
          ExecStart =
            "${cfg.package}/bin/ngrok start --log stdout --log-level ${cfg.loglevel} --all --config ${ngrok-config}";
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          ExecReload = "/bin/kill -HUP $MAINPID";
          KillMode = "process";
          IgnoreSIGPIPE = "true";
          Restart = "always";
          RestartSec = "3";
          Type = "simple";
        };

        Install = { WantedBy = [ "multi-user.target" ]; };
      };
    };
  };
}
