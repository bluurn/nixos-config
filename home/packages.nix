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

    inputs.dedup.packages.${pkgs.stdenv.hostPlatform.system}.default # <3
    inputs.port-scanner.packages.${pkgs.stdenv.hostPlatform.system}.default # <3
  ];
}
