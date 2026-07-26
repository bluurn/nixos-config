{ pkgs, ... }:

let
  qbitUid = 991;
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
      jq
      mullvad-vpn
      pass
    ];

    text = ''
      set -euo pipefail

      base_url="${qbitBaseUrl}"
      password_path="${qbitPasswordPath}"

      fail() {
        echo "FAIL: $*" >&2
        exit 1
      }

      mullvad_status="$(mullvad status || true)"

      printf '%s\n' "$mullvad_status" | grep -Eiq '^Connected\b' \
        || fail "Mullvad is not connected; refusing to configure qBittorrent: $mullvad_status"

      mullvad_json="$(
        curl -fsS https://am.i.mullvad.net/json
      )" || fail "Could not query Mullvad IP check endpoint"

      is_mullvad_exit="$(
        printf '%s' "$mullvad_json" | jq -r '.mullvad_exit_ip // false'
      )"

      current_ip="$(
        printf '%s' "$mullvad_json" | jq -r '.ip // empty'
      )"

      [ "$is_mullvad_exit" = "true" ] \
        || fail "Current external IP is not a Mullvad exit IP: $current_ip"

      iface="$(
        ip route get 1.1.1.1 \
          | sed -n 's/.* dev \([^ ]*\).*/\1/p' \
          | head -n1
      )"

      [ -n "$iface" ] \
        || fail "Could not detect active Mullvad network interface"

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

      [ "$login_result" = "Ok." ] \
        || fail "qBittorrent login failed: $login_result"

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
      echo "Mullvad exit IP: $current_ip"
    '';
  };

  torrentCheck = pkgs.writeShellApplication {
    name = "torrent-check";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      gnugrep
      gnused
      iproute2
      jq
      mullvad-vpn
      pass
    ];

    text = ''
      set -euo pipefail

      base_url="${qbitBaseUrl}"
      password_path="${qbitPasswordPath}"

      fail() {
        echo "FAIL: $*" >&2
        exit 1
      }

      ok() {
        echo "OK: $*"
      }

      mullvad_status="$(mullvad status || true)"

      printf '%s\n' "$mullvad_status" | grep -Eiq '^Connected\b' \
        || fail "Mullvad CLI says VPN is not connected: $mullvad_status"

      ok "Mullvad CLI reports connected"

      mullvad_json="$(
        curl -fsS https://am.i.mullvad.net/json
      )" || fail "Could not query Mullvad IP check endpoint"

      is_mullvad_exit="$(
        printf '%s' "$mullvad_json" | jq -r '.mullvad_exit_ip // false'
      )"

      current_ip="$(
        printf '%s' "$mullvad_json" | jq -r '.ip // empty'
      )"

      [ "$is_mullvad_exit" = "true" ] \
        || fail "Current external IP is not a Mullvad exit IP: $current_ip"

      ok "Mullvad exit IP: $current_ip"

      listen="$(
        ss -ltnp | grep ':8080' || true
      )"

      [ -n "$listen" ] \
        || fail "Nothing listens on port 8080"

      echo "$listen" | grep -q '127\.0\.0\.1:8080' \
        || fail "qBittorrent Web UI is not bound to 127.0.0.1: $listen"

      if echo "$listen" | grep -Eq '0\.0\.0\.0:8080|\[::\]:8080'; then
        fail "qBittorrent Web UI is listening publicly: $listen"
      fi

      ok "qBittorrent Web UI listens on localhost only"

      iface="$(
        ip route get 1.1.1.1 \
          | sed -n 's/.* dev \([^ ]*\).*/\1/p' \
          | head -n1
      )"

      [ -n "$iface" ] \
        || fail "Could not detect active route interface"

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

      [ "$login_result" = "Ok." ] \
        || fail "qBittorrent API login failed: $login_result"

      prefs="$(
        curl -fsS \
          -b "$cookie" \
          "$base_url/api/v2/app/preferences"
      )"

      q_iface="$(printf '%s' "$prefs" | jq -r '.current_network_interface // ""')"
      web_addr="$(printf '%s' "$prefs" | jq -r '.web_ui_address // ""')"

      [ "$web_addr" = "127.0.0.1" ] \
        || fail "qBittorrent web_ui_address is '$web_addr', expected 127.0.0.1"

      [ -n "$q_iface" ] \
        || fail "qBittorrent current_network_interface is empty"

      [ "$q_iface" = "$iface" ] \
        || fail "qBittorrent interface '$q_iface' differs from current route interface '$iface'"

      ok "qBittorrent is bound to active Mullvad interface: $q_iface"

      for key in web_ui_upnp bypass_local_auth upnp dht pex lsd; do
        value="$(printf '%s' "$prefs" | jq -r ".\"$key\"")"

        [ "$value" = "false" ] \
          || fail "qBittorrent preference '$key' is '$value', expected false"

        ok "$key = false"
      done

      anonymous_mode="$(printf '%s' "$prefs" | jq -r '.anonymous_mode')"

      [ "$anonymous_mode" = "true" ] \
        || fail "anonymous_mode is '$anonymous_mode', expected true"

      ok "anonymous_mode = true"

      echo
      echo "Torrent safety check passed."
      echo "Still do a real tracker test with IPLeak once after major changes."
    '';
  };
in
{
  users = {
    groups.qbittorrent = { };

    users.qbittorrent = {
      isSystemUser = true;
      uid = qbitUid;
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

  networking.nftables = {
    enable = true;

    ruleset = ''
      table inet qbit_killswitch {
        chain output {
          type filter hook output priority filter; policy accept;

          # qBittorrent Web UI / local API
          meta skuid ${toString qbitUid} oifname "lo" accept

          # Torrent traffic through Mullvad only
          meta skuid ${toString qbitUid} oifname "wg0-mullvad" accept

          # Anything else from qBittorrent is forbidden
          meta skuid ${toString qbitUid} reject with icmpx type admin-prohibited
        }
      }
    '';
  };
  environment.systemPackages = [
    qbAdd
    qbittorrentApplySettings
    torrentCheck
  ];
}
