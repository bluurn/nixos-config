{
  pkgs,
  ...
}:

let
  mullvadApplySettings = pkgs.writeShellApplication {
    name = "mullvad-apply-settings";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.mullvad-vpn
    ];

    text = ''
      set -euo pipefail

      for _ in $(seq 1 30); do
        if mullvad status >/dev/null 2>&1; then
          break
        fi

        sleep 1
      done

      mullvad relay set tunnel-protocol wireguard
      mullvad relay set location rs
      mullvad auto-connect set on
    '';
  };
in
{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  environment.systemPackages = with pkgs; [
    mullvad-vpn
    mullvadApplySettings
  ];

  systemd.services.mullvad-apply-settings = {
    description = "Apply Mullvad VPN settings";

    after = [ "mullvad-daemon.service" ];
    requires = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${mullvadApplySettings}/bin/mullvad-apply-settings";
    };
  };
}
