{ ... }:

{
  imports = [
    ./neovim.nix
    ./shell.nix
    ./devtools.nix
    ./packages.nix
  ];
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "25.11";
}
