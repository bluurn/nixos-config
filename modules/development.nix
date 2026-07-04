{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    localsend
    neovim
    wget
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.zsh.enable = true;
}
