{ pkgs, ... }:

let
  qbitBaseUrl = "http://127.0.0.1:8080";
  qbitPasswordPath = "Services/qbittorrent/webui";

  qbAdd = pkgs.writeShellApplication {
    name = "qb-add";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      pass
      python3Minimal
    ];

    text = ''
            set -euo pipefail

            base_url="${qbitBaseUrl}"
            password_path="${qbitPasswordPath}"

            if [ "$#" -lt 1 ]; then
              echo "Usage: qb-add <magnet-url-or-torrent-file>"
              exit 1
            fi

            normalize_target() {
              case "$1" in
                file://*)
                  python3 - "$1" <<'PY'
      import sys
      import urllib.parse

      url = urllib.parse.urlparse(sys.argv[1])
      print(urllib.parse.unquote(url.path))
      PY
                  ;;
                *)
                  printf '%s\n' "$1"
                  ;;
              esac
            }

            target="$(normalize_target "$1")"

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
                if [ ! -f "$target" ]; then
                  echo "Torrent file not found: $target"
                  exit 1
                fi

                curl -fsS \
                  -b "$cookie" \
                  -F "torrents=@$target" \
                  "$base_url/api/v2/torrents/add"
                ;;
            esac

            echo "Added to qBittorrent service"
    '';
  };

  qbittorrentApplySettings = pkgs.writeShellApplication {
    name = "qbittorrent-apply-settings";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      gnugrep
      gnused
      iproute2
      mullvad-vpn
      pass
    ];

    text = ''
      set -euo pipefail

      base_url="${qbitBaseUrl}"
      password_path="${qbitPasswordPath}"

      if ! mullvad status | grep -qi "connected"; then
        echo "Mullvad is not connected; refusing to configure qBittorrent"
        mullvad status || true
        exit 1
      fi

      iface="$(
        ip route get 1.1.1.1 \
          | sed -n 's/.* dev \([^ ]*\).*/\1/p' \
          | head -n1
      )"

      if [ -z "$iface" ]; then
        echo "Could not detect active Mullvad network interface"
        exit 1
      fi

      for _ in $(seq 1 30); do
        if curl -fsS "$base_url" >/dev/null 2>&1; then
          break
        fi

        sleep 1
      done

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

      prefs="$(
        cat <<JSON
      {
        "web_ui_address": "127.0.0.1",
        "web_ui_port": 8080,
        "web_ui_upnp": false,
        "bypass_local_auth": false,

        "upnp": false,
        "dht": false,
        "pex": false,
        "lsd": false,
        "anonymous_mode": true,

        "current_network_interface": "$iface",
        "current_interface_address": "",

        "save_path": "/srv/torrents/downloads",
        "temp_path_enabled": true,
        "temp_path": "/srv/torrents/incomplete"
      }
      JSON
      )"

      curl -fsS \
        -b "$cookie" \
        --data-urlencode "json=$prefs" \
        "$base_url/api/v2/app/setPreferences"

      echo "qBittorrent safe settings applied"
      echo "Bound to interface: $iface"
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
    "d /srv/torrents 2775 qbittorrent qbittorrent - -"
    "d /srv/torrents/downloads 2775 qbittorrent qbittorrent - -"
    "d /srv/torrents/incomplete 2775 qbittorrent qbittorrent - -"
    "d /srv/torrents/watch 2775 qbittorrent qbittorrent - -"
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

    serviceConfig = {
      UMask = "0002";
    };
  };

  environment.systemPackages = [
    qbAdd
    qbittorrentApplySettings
  ];
}
