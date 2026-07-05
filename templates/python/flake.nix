{
  description = "Python dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          python3
          uv
          ruff
          pyright
          just
        ];

        shellHook = ''
          export UV_PROJECT_ENVIRONMENT=".venv"

          echo "Python dev shell"
          python --version
          uv --version
        '';
      };
    };
}
