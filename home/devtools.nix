{ pkgs, ... }: {

  programs.git = {
    enable = true;
    settings.user = {
      name = "Vladimir Suvorov";
      email = "bluurn@gmail.com";
    };
  };

  programs.lazygit.enable = true;

  programs.gpg = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry = {
      package = pkgs.pinentry-curses;
    };
  };
}
