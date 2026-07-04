{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/users.nix
    ../../modules/gaming.nix
    ../../modules/desktop.nix
    ../../modules/development.nix
    ../../modules/suspend.nix
  ];

  system.stateVersion = "25.11";
}
