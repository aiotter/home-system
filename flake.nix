{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    aiotter-systems.url = "github:aiotter/systems/nixos";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, aiotter-systems, colmena, ... }@flakeInputs: {
    nixosModules.primer.imports = [
      aiotter-systems.nixosModules.raspi
      nixos-hardware.nixosModules.raspberry-pi-4
      ./modules/primer.nix
    ];

    nixosConfigurations.primer = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit (aiotter-systems.lib) consts; };
      modules = [ self.nixosModules.primer ];
    };

    colmena = {
      meta = {
        specialArgs = { inherit (aiotter-systems.lib) consts; inherit flakeInputs; };
        nixpkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [ (import ./overlays.nix) ];
          config.permittedInsecurePackages = [
            "python3.14-ecdsa-0.19.2"  # ha-ef-ble で必要
          ];
        };
      };

      home = { pkgs, lib, config, ... }: {
        deployment = {
          targetHost = "home.local";
          targetUser = "aiotter";
          buildOnTarget = true;
        };

        imports = [
          self.nixosModules.primer
          ./secrets.nix
          ./modules
        ];
      };
    };

    colmenaHive = colmena.lib.makeHive self.outputs.colmena;

    packages =
      builtins.mapAttrs
        (system: colmenaPkgs:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            inherit (colmenaPkgs) colmena;
            default = colmenaPkgs.colmena;

            switch = pkgs.writeShellScriptBin "colmena-switch" ''
              export PATH=${pkgs.lib.makeBinPath [ pkgs.nix ]}:$PATH
              ${pkgs.lib.getExe colmenaPkgs.colmena} apply switch
            '';
          }
        )
        colmena.outputs.packages;
  };

  nixConfig = {
    extra-experimental-features = [ "pipe-operators" ];
  };
}
