{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gaming.nix
    ../../modules/development.nix
    ../../modules/suspend.nix
  ];

  boot.loader.systemd-boot.configurationLimit = lib.mkForce 5;

  users.users.vova = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;
  networking.hostName = "t480";

  time.timeZone = "Europe/Berlin";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}
