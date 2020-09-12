{ self, lib, home-manager }:

{ modules ? [], ... } @ args:
lib.nixosSystem (args // {
  modules = lib.concat modules [
    home-manager.nixosModules.home-manager
    {
      # This is required when using flakes.
      home-manager.useGlobalPkgs = true;
    }

    # Allow accessing the parent NixOS configuration.
    ({ config, ... }: {
      options.home-manager.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submoduleWith {
          modules = [ ];
          specialArgs = {
            super = config;
          };
        });
      };
    })
  ];
})