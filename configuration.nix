{ config, pkgs, ... }:
{ 
  imports =
    [ 
      ./hosts/t480/hardware-configuration.nix
    ];

  networking.hostName = "nixos"; # Define your hostname.

  system.stateVersion = "25.11";

  users.users.vova = {
    isNormalUser = true;
    home = "/home/vova";
    extraGroups = [ "wheel" ];
  };
}
