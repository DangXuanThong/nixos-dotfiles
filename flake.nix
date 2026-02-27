{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpaks.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, home-manager, flatpaks, ... }@inputs: {
    nixosConfigurations.Nix-PC = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager {
          home-manager.useUserPackages = true;
          home-manager.users.penguin.imports = [
            flatpaks.homeManagerModules.nix-flatpak
            ./home.nix
          ];
          home-manager.backupFileExtension = "bak";
        }
      ];
    };
  };
}
