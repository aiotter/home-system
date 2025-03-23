{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    aiotter-systems.url = "github:aiotter/systems/master";
    aiotter-nixos.url = "github:aiotter/systems/nixos";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, aiotter-systems, aiotter-nixos, colmena }:
    let
      specialArgs = { inherit (aiotter-systems.lib) consts; };
      modules = [
        aiotter-nixos.nixosModules.raspi
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix # local config
        ./hardware-configuration.nix
      ];
    in
    {
      nixosConfigurations = {
        nixos = self.nixosConfigurations.home;
        home = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit modules specialArgs;
        };
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "aarch64-linux"; };
          inherit specialArgs;
        };
        home = {
          imports = modules;
          deployment = {
            targetHost = "home.local";
            targetUser = "aiotter";
            buildOnTarget = true;
          };
        };
      };

      colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      # --experimental-flake-eval を常時有効にした colmena
      defaultApp =
        let
          makeApp = system:
            let
              pkgs = import nixpkgs { inherit system; };
              colmenaPkgs = colmena.outputs.packages.${system};
              colmena-wrapped = pkgs.writeShellScript "colmena" ''
                ${colmenaPkgs.colmena}/bin/colmena --experimental-flake-eval "$@"
              '';
            in
            { type = "app"; program = toString colmena-wrapped; };
        in
        builtins.mapAttrs (system: _: makeApp system) colmena.outputs.packages;
    };
}
