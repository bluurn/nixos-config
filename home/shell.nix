_: {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      n = "nvim";
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];

    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };
}
