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
