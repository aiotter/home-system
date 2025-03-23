{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    aiotter-systems.url = "github:aiotter/systems/master";
    aiotter-nixos.url = "github:aiotter/systems/nixos";
  };

  outputs = { self, nixpkgs, nixos-hardware, aiotter-systems, aiotter-nixos }: {
    nixosConfigurations.nixos = self.nixosConfigurations.home;

    nixosConfigurations.home = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit (aiotter-systems.lib) consts; };
      modules = [
        aiotter-nixos.nixosModules.raspi
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix # local config
        ./hardware-configuration.nix
      ];
    };
  };
}
