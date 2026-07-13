{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    dedup # <3
    eza
    fd
    fzf
    jq
    just
    pass
    ripgrep
    tree
    wget
    wl-clipboard
    zoxide
  ];
}
