{ config, pkgs, ... }:
{ 
  imports =
    [ 
      ./hosts/t480/hardware-configuration.nix
    ];

  networking.hostName = "nixos"; # Define your hostname.

    boot.loader.grub = {
      enable = true;
      devices = [ "/dev/nvme0n1" ];
    };
  system.stateVersion = "25.11";
}
