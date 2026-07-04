{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    localsend
    neovim
    wget
  ];

  programs.zsh.enable = true;
}
