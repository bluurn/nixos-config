_: {
  programs = {
    git = {
      enable = true;
      settings.user = {
        name = "Vladimir Suvorov";
        email = "bluurn@gmail.com";
      };
    };

    lazygit.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
