{
  description = "NixOS config with Hyprland + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    odysseus.url = "github:pewdiepie-archdaemon/odysseus/pull/2568/head";
  };

  outputs = { self, nixpkgs, home-manager, odysseus, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-repo";
        runtimeInputs = [ pkgs.findutils pkgs.git pkgs.nixpkgs-fmt ];
        text = ''
          git ls-files -z -- '*.nix' \
            | while IFS= read -r -d "" file; do
                if [ -w "$file" ]; then
                  printf '%s\0' "$file"
                else
                  printf 'Skipping non-writable Nix file: %s\n' "$file" >&2
                fi
              done \
            | xargs -0 --no-run-if-empty nixpkgs-fmt
        '';
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit odysseus system; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nico = import ./home/nico.nix;
          }
        ];
      };
    };
}
