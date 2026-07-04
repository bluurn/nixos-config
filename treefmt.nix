{ pkgs, ... }:

{
  projectRootFile = "flake.nix";

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
    width = 100;
  };

  programs.prettier = {
    enable = true;
    includes = [
      "*.md"
      "*.json"
      "*.json5"
      "*.yaml"
      "*.yml"
    ];
    settings = {
      printWidth = 100;
      proseWrap = "preserve";
    };
  };

  programs.shfmt = {
    enable = true;
    indent_size = 2;
  };

  programs.shellcheck.enable = true;

  programs.taplo.enable = true;

  programs.deadnix.enable = true;
  programs.statix.enable = true;
}
