{
  description = "Go dev shell";

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
          go
          gopls
          delve
          golangci-lint
          gotools
          just
        ];

        shellHook = ''
          export GOPATH="$PWD/.go"
          export GOBIN="$GOPATH/bin"
          export PATH="$GOBIN:$PATH"

          echo "Go dev shell"
          go version
        '';
      };
    };
}
