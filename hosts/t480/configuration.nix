{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "t480";
  time.timeZone = "Europe/Berlin";

  users.users.vova = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
  ];

  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.11";
}
