{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./shell.nix
  ];
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Vladimir Suvorov";
      email = "bluurn@gmail.com";
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry = {
      package = pkgs.pinentry-curses;
    };
  };

  home.packages = with pkgs; [
    tree
    ripgrep
    fd
    fzf
    lazygit
    pass
  ];
}
