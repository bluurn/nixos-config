{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    jq
    pass
    ripgrep
    tree
    wget
    wl-clipboard
    zoxide
  ];
}
