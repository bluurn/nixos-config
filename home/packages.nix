{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
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
    inputs.dedup.packages.${system}.default # <3
    inputs.port-scanner.packages.${system}.default # <3

    # 3rd party
    inputs.codex-cli-nix.packages.${system}.default
    devenv
  ];
}
