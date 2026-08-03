{ ... }:

{
  imports = [
    ./applypilot.nix
    ./gnome.nix
    ./neovim.nix
    ./shell.nix
    ./devtools.nix
    ./packages.nix
    ./services.nix
    ./mime.nix
  ];

  home = {
    username = "vova";
    homeDirectory = "/home/vova";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
