{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.applypilot.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.claude-code
  ];
}
