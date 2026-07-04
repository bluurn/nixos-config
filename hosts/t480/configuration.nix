{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gaming.nix
  ];

  users.users.vova = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.hostName = "t480";

  time.timeZone = "Europe/Berlin";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    localsend
    neovim
    pciutils
    wget
  ];

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.11";
}
