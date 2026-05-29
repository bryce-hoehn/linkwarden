{
  description = "Linkwarden distroless image using nix2container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
    base.url = "github:podmania/base";
  };

  outputs = { self, nixpkgs, nix2container, base }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
    n2c = nix2container.outputs.packages.${system}.nix2container;
    pkg = pkgs.linkwarden;
    imageConfig = {
      ExposedPorts = {
        
        "3000/tcp" = {};
        
      };
      Volumes = {
        
        "/data" = {};
        
      };
      
      Cmd = [ "${pkg}/bin/linkwarden" ];
    };
  in {
    packages.${system} = {
      linkwarden-image = n2c.buildImage {
        name = "linkwarden";
        tag = "latest";
        fromImage = base.packages.${system}.base-image;
        maxLayers = 5;
        config = imageConfig;
      };

      linkwarden-debug-image = n2c.buildImage {
        name = "linkwarden";
        tag = "latest-debug";
        fromImage = base.packages.${system}.base-debug-image;
        maxLayers = 5;
        config = imageConfig;
      };

      linkwarden = pkg;

      default = self.packages.${system}.linkwarden-image;
    };

    version = pkg.version;
  };
}
