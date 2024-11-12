{
  description = "A flake-parts module for wrap devshell and nixago";

  outputs = inputs: {
    flakeModule = ./flake-module.nix;
  };
}
