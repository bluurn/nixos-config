# NixOS T480 Config

## Useful commands

```shell
sudo nixos-rebuild switch --flake .#t480
nix fmt
nix flake check
nvidia-offload glxinfo -B
sudo nix-collect-garbage --delete-older-than 14d
```

