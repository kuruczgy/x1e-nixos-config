{
  inputs = {
    # Unstable nixpkgs, required for now.
    nixpkgs.url = "github:nixos/nixpkgs";

    # This repository.
    x1e-nixos-config.url = "github:kuruczgy/x1e-nixos-config";
    x1e-nixos-config.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, x1e-nixos-config }: {
    # Change "system" to your chosen hostname here:
    nixosConfigurations.system = nixpkgs.lib.nixosSystem {
      modules = [
        x1e-nixos-config.nixosModules.x1e
        {
          networking.hostName = "system";
          hardware.deviceTree.name = "qcom/x1e80100-lenovo-yoga-slim7x.dtb";

          nixpkgs.hostPlatform.system = "aarch64-linux";

          # Uncomment this to allow unfree packages.
          # nixpkgs.config.allowUnfree = true;

          nix = {
            channel.enable = false;
            settings.experimental-features = [ "nix-command" "flakes" ];
          };
        }
        ./configuration.nix
      ];
    };
  };
}
