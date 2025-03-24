{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    aiotter-systems.url = "github:aiotter/systems/nixos";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, aiotter-systems, colmena }: {
    nixosModules.default = {
      imports = nixpkgs.lib.filesystem.listFilesRecursive ./modules ++ [
        aiotter-systems.nixosModules.raspi
        nixos-hardware.nixosModules.raspberry-pi-4
      ];
    };

    nixosConfigurations.home = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit (aiotter-systems.lib) consts; };
      modules = [ self.nixosModules.default ];
    };

    colmena = {
      meta = {
        nixpkgs = import nixpkgs { system = "aarch64-linux"; };
        specialArgs = { inherit (aiotter-systems.lib) consts; };
      };
      home = {
        inherit (self.nixosModules.default) imports;
        deployment = {
          targetHost = "home.local";
          targetUser = "aiotter";
          buildOnTarget = true;
        };
      };
    };

    colmenaHive = colmena.lib.makeHive self.outputs.colmena;

    # --experimental-flake-eval を常時有効にした colmena
    defaultPackage =
      builtins.mapAttrs
        (system: colmenaPkgs:
          nixpkgs.legacyPackages.${system}.writeShellScriptBin "colmena" ''
            ${colmenaPkgs.colmena}/bin/colmena --experimental-flake-eval "$@"
          ''
        )
        colmena.outputs.packages;
  };
}
