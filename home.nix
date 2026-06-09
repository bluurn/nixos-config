{ pkgs, ... }:

{
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "25.11";

  programs.firefox = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "vova";
    userEmail = "vova@local";
  };

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    tree
    ripgrep
    fd
    fzf
  ];
}
