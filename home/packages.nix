{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    bat
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

    inputs.dedup.packages.${pkgs.system}.default # <3
  ];
}
