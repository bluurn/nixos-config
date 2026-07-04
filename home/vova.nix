{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./shell.nix
    ./devtools.nix
  ];
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    tree
    ripgrep
    fd
    fzf
    pass
  ];
}
