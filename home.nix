{ config, pkgs, lib, ... }:

{
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "/home/vova/projects/lazyvim-config";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    gcc
    git
    jq
    lazygit
    ripgrep
    starship
    tree-sitter
    unzip
    wget
    wl-clipboard
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    zoxide
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Vova";
      user.email = "bluurn@gmail.com";
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      n = "nvim";
      ll = "ls -la";
      gst = "git status";
      rebuild = "sudo nixos-rebuild switch";
    };
    initContent = ''
      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"
      eval "$(starship init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableZshIntegration = true;
  };

  programs.firefox = { 
    enable = true;

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  programs.zoxide.enable = true;

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [ "xkb" "us" ])
        (lib.hm.gvariant.mkTuple [ "xkb" "ru" ])
      ];
      xkb-options = [];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Super>space" ];
      switch-input-source-backward = [ "<Shift><Super>space" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kgx";
      binding = "<Control><Alt>t";
    };
  };
}
