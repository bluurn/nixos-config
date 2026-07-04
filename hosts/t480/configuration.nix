{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/users.nix
    ../../modules/fonts.nix
    ../../modules/development.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/suspend.nix
  ];

  system.stateVersion = "25.11";
}
