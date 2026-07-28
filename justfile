default:
    just --list

fmt:
    nix fmt

check:
    nix flake check

test:
    sudo nixos-rebuild test --flake .#t480

switch:
    sudo nixos-rebuild switch --flake .#t480

update:
    nix flake update
    just check
    just test

gc:
    sudo nix-collect-garbage --delete-older-than 14d
    sudo nixos-rebuild switch --flake .#t480

generations:
    sudo nix-env --profile /nix/var/nix/profiles/system --list-generations

nvidia:
    nvidia-smi
    nvidia-offload glxinfo -B

cmdline:
    cat /proc/cmdline

install-hooks:
    git config core.hooksPath .githooks

hooks:
    git config --get core.hooksPath
power:
    systemctl is-enabled power-profiles-daemon.service tlp.service 2>/dev/null || true
    systemctl status tlp --no-pager
    tlp-stat -s

battery:
    sudo tlp-stat -b

cpu:
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || true

sleep-info:
    cat /sys/power/mem_sleep
    cat /proc/cmdline | grep -o "i915.enable_[a-z]*=[0-9]" || true

power-full:
    just power
    just battery
    just cpu
    just nvidia
    just sleep-info

vpn:
    systemctl status mullvad-daemon --no-pager
    mullvad status

vpn-apply secret="Personal/Mullvad":
    mullvad account login "$(pass show "{{secret}}" | head -n1)"
    mullvad connect

torrent:
    systemctl status qbittorrent --no-pager
    ss -ltnp | grep 8080 || true
    mullvad status

torrent-open:
    xdg-open http://127.0.0.1:8080

torrent-add target:
    qb-add "{{target}}"

torrent-apply:
    qbittorrent-apply-settings

torrent-test:
    qb-add ~/Downloads/test.torrent

torrent-check:
    torrent-check

torrent-recover:
    mullvad connect
    sleep 5
    just torrent-check || (just torrent-apply && just torrent-check)

browser-check:
    xdg-mime query default x-scheme-handler/http
    xdg-mime query default x-scheme-handler/https
    xdg-settings get default-web-browser || true

applypilot-install:
    applypilot-install

applypilot-doctor:
    applypilot doctor

applypilot-dry-run:
    applypilot apply --dry-run
