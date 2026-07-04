{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gaming.nix
    ../../modules/desktop.nix
    ../../modules/development.nix
    ../../modules/system.nix
    ../../modules/suspend.nix
  ];

  users.users.vova = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
