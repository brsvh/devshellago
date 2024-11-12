# devshellago

The devshellago flake-parts module provides a simple wrapper of the `devshell` flake-parts module, help you to use `nixago` to generate configuration files.

## Usage

> [!NOTE]
>
> The inputs must include both `devshell` and `nixago`.

``` nix
{
  inputs = {
    devshell.url = "github:numtide/devshell/main";
    devshellago.url = "github:brsvh/devshellago/main";
    nixago.url = "github:nix-community/nixago/master";
    nixago-extensions.url = "github:nix-community/nixago-extensions/master";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshellago.flakeModule
      ];

      perSystem =
        { pkgs, ... }:
        {
          devshells.default = {
            commands = [ ];
            devshell = { };
            env = [ ];
            nixago = {
              treefmt = {
                data = {
                  formatter = {
                    nix = {
                      command = "nixfmt";

                      includes = [
                        "*.nix"
                      ];
                    };
                  };
                };

                format = "toml";
                output = "treefmt.toml";

                packages = with pkgs; [
                  nixfmt-rfc-style
                  treefmt
                ];
              };
            };
          };
        };

      systems = [ "x86_64-linux" ];
    };
}
```


This example will create a `treefmt.toml` file with the following content when you enter `devShells.x86_64-linux.default`.

``` toml
[formatter.nix]
command = "nixfmt"
includes = ["*.nix"]
```

## Documentation

This flake-parts module directly imports the modules of `devshell` and `nixago`. For detailed option documents, refer to <https://flake.parts/options/devshell> and <https://github.com/nix-community/nixago/blob/5133633e9fe6b144c8e00e3b212cdbd5a173b63d/modules/request.nix>.

## License

All work is free. You can redistribute it and/or modify it under the terms of the MIT License. You should have received a copy of it, see the COPYING file for more details. If you did not recive it, see <https://spdx.org/licenses/MIT.html> for more details.
