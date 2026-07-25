{ pkgs, ... }:

let
  qbAdd = pkgs.writeShellApplication {
    name = "qb-add";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      pass
    ];

    text = ''
      set -euo pipefail

      base_url="http://127.0.0.1:8080"
      password_path="Services/qbittorrent/webui"

      if [ "$#" -lt 1 ]; then
        echo "Usage: qb-add <magnet-url-or-torrent-file>"
        exit 1
      fi

      target="$1"
      cookie="$(mktemp)"
      trap 'rm -f "$cookie"' EXIT

      password="$(pass show "$password_path" | head -n1)"

      login_result="$(
        curl -fsS \
          -c "$cookie" \
          -b "$cookie" \
          --data-urlencode "username=admin" \
          --data-urlencode "password=$password" \
          "$base_url/api/v2/auth/login"
      )"

      if [ "$login_result" != "Ok." ]; then
        echo "qBittorrent login failed: $login_result"
        exit 1
      fi

      case "$target" in
        magnet:*)
          curl -fsS \
            -b "$cookie" \
            --form-string "urls=$target" \
            "$base_url/api/v2/torrents/add"
          ;;
        *)
          curl -fsS \
            -b "$cookie" \
            -F "torrents=@$target" \
            "$base_url/api/v2/torrents/add"
          ;;
      esac

      echo "Added to qBittorrent service"
    '';
  };
in
{
  users = {
    groups.qbittorrent = { };
    users.qbittorrent = {
      isSystemUser = true;
      group = "qbittorrent";
    };

    users.vova.extraGroups = [ "qbittorrent" ];
  };

  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    webuiPort = 8080;
    openFirewall = false;
  };

  systemd.tmpfiles.rules = [
    "d /srv/torrents 0775 qbittorrent qbittorrent - -"
    "d /srv/torrents/downloads 0775 qbittorrent qbittorrent - -"
    "d /srv/torrents/incomplete 0775 qbittorrent qbittorrent - -"
    "d /srv/torrents/watch 0775 qbittorrent qbittorrent - -"
  ];

  systemd.services.qbittorrent = {
    after = [
      "mullvad-daemon.service"
      "mullvad-apply-settings.service"
    ];
    wants = [
      "mullvad-daemon.service"
      "mullvad-apply-settings.service"
    ];
  };

  environment.systemPackages = [
    qbAdd
  ];
}
