{ config, pkgs, ... }:
{ 
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  networking.hostName = "nixos"; # Define your hostname.
  
  system.stateVersion = "25.11";
}
