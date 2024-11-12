{
  flake-parts-lib,
  lib,
  inputs,
  ...
}:
let
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;

  inherit (lib)
    mapAttrs
    mkOption
    types
    ;

  devshell =
    if inputs ? devshell then
      inputs.devshell
    else
      throw ''
        devshell input not found, please add a devshell input to your flake.
      '';

  nixago =
    if inputs ? nixago then
      inputs.nixago
    else
      throw ''
        nixago input not found, please add a nixago input to your flake.
      '';
in
{
  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        lib,
        pkgs,
        system,
        ...
      }:
      let
        inherit (builtins)
          map
          ;

        inherit (lib)
          flatten
          nameValuePair
          ;

        devshellSubmodule =
          let
            inherit (builtins)
              attrValues
              ;

            inherit (lib)
              mapAttrs'
              ;

            nixagoSubmodule =
              {
                config,
                ...
              }:
              let
                engines = import "${nixago}/engines/default.nix" {
                  inherit
                    lib
                    pkgs
                    ;
                };

                request = import "${nixago}/modules/request.nix" {
                  inherit
                    config
                    engines
                    lib
                    ;
                };
              in
              request;

            nixagoSubmodule' =
              {
                config,
                ...
              }:
              {
                options = {
                  packages = mkOption {
                    default = [ ];

                    description = ''
                      Dependencies of this request.
                    '';

                    type = with types; listOf package;
                  };
                };
              };

            mkNixago = nixago.lib.${system}.make;
          in
          (import "${devshell}/modules/modules.nix" {
            inherit
              lib
              pkgs
              ;
          })
          ++ [
            (
              {
                config,
                ...
              }:
              {
                options = {
                  nixago = mkOption {
                    default = { };

                    description = ''
                      A list of nixago configurations.
                    '';

                    type =
                      with types;
                      lazyAttrsOf (submoduleWith {
                        modules = [
                          nixagoSubmodule
                          nixagoSubmodule'
                        ];
                      });
                  };
                };

                config = {
                  devshell = {
                    packages = flatten (map (n: n.packages) (attrValues config.nixago));
                    startup = mapAttrs' (
                      n: v:
                      nameValuePair n {
                        text = (mkNixago v).shellHook;
                      }
                    ) config.nixago;
                  };
                };
              }
            )
          ];
      in
      {
        options = {
          devshells = mkOption {
            default = { };

            description = ''
              Configure devshells with flake-parts.

              Not to be confused with `devShells`, with a capital S. Yes, this
              is unfortunate.

              Each devshell will also configure an equivalent `devShells`.

              Used to define devshells. not to be confused with `devShells`
            '';

            type = types.lazyAttrsOf (types.submoduleWith { modules = devshellSubmodule; });
          };
        };

        config = {
          devShells = mapAttrs (_name: devshell: devshell.devshell.shell) config.devshells;
        };
      }
    );
  };
}
