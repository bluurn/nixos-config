{ pkgs, ... }:

{
  imports = [
    ./neovim.nix
  ];

  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "25.11";

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      n  = "nvim";
      ll = "ls -lah";
      la = "ls -A";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gd = "git diff";

      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#t480";
      update = "cd /etc/nixos && nix flake update";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

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

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  home.packages = with pkgs; [
    direnv
    tree
    ripgrep
    fd
    fzf
    lazygit
    pass
  ];
}
