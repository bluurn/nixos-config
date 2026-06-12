{ pkgs, ... }:

{
  home.username = "vova";

  # либо вообще убери, либо оставь ТОЛЬКО тут
  home.homeDirectory = "/home/vova";

  home.stateVersion = "25.11";

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "vova";
    userEmail = "vova@local";
  };

  home.packages = with pkgs; [
    tree
    ripgrep
    fd
    fzf
    lazygit
  ];
}
