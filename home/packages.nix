{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    bat
    eza
    fd
    jq
    just
    lf
    pass
    passExtensions.pass-otp
    ripgrep
    telegram-desktop
    tree
    vlc
    wget
    wl-clipboard

    # mine
    inputs.dedup.packages.${pkgs.stdenv.hostPlatform.system}.default # <3
    inputs.port-scanner.packages.${pkgs.stdenv.hostPlatform.system}.default # <3

    # 3rd party
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
