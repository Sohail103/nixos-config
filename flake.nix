{
  description = "Sohail's NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, quickshell, caelestia-shell, ... }@inputs:
  let
    system = "x86_64-linux";

    # Define both stable and unstable package sets
    pkgs = import nixpkgs { 
    	inherit system;
	config.allowUnfree = true;
	};
    pkgsUnstable = import nixpkgs-unstable { inherit system; };
  in {
    nixosConfigurations."sohail-nixos" = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs pkgs pkgsUnstable;
      };

      modules = [
        ./configuration.nix
	./hardware-configuration.nix
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs pkgs pkgsUnstable; };
          home-manager.users.sohail = import ./home.nix;
        }
      ];
    };
  };
}

