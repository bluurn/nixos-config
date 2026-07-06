{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  home.packages = with pkgs; [
    # LazyVim basics
    git
    curl
    unzip
    gcc
    gnumake

    # Search
    ripgrep
    fd

    # Clipboard
    wl-clipboard

    # Runtime / tooling
    nodejs
    tree-sitter

    # Lua
    lua-language-server
    stylua

    # Nix
    nil
    nixfmt-rfc-style

    # Python
    pyright
    ruff

    # Rust
    rust-analyzer

    # Go
    gopls
    delve
    golangci-lint
  ];

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
