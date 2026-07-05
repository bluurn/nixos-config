{
  description = "Node.js dev shell";

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
          nodejs
          pnpm
          yarn
          typescript
          typescript-language-server
          prettier
          just
        ];

        shellHook = ''
          echo "Node dev shell"
          node --version
          pnpm --version
        '';
      };
    };
}
