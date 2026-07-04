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
