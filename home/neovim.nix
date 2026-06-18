{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };
  home.packages = with pkgs; [
    git
    curl
    unzip

    ripgrep
    fd

    gcc
    gnumake

    nodejs

    lua-language-server
    stylua

    nil
    nixfmt-rfc-style

    pyright
    rust-analyzer
  ]; 
}
# THEN RUN
# git clone https://github.com/LazyVim/starter ~/.config/nvim
# rm -rf ~/.config/nvim/.git
# nvim
