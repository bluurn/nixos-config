{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    localsend
    neovim
  ];

  programs.zsh.enable = true;
}
