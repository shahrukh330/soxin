{
  description = "Soxin ...";

  inputs = {
    nixpkgs.url = "nixpkgs/master";
    # home-manager.url = "github:rycee/home-manager/bqv-flakes";
    home-manager.url = "git+file:///yl/code/stories/opensource/home-manager/flakes/github.com/rycee/home-manager";
  };

  outputs = inputs@{ self, nixpkgs, home-manager }:
  let
    inherit (nixpkgs) lib;
    inherit (utils) pathsToImportedAttrs;

    utils = import ./lib/utils.nix { inherit lib; };
  in {
    nixosModules = pathsToImportedAttrs (import ./modules/list.nix);
  };
}