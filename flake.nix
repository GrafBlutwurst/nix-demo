#A flake itself is a nix expression, specifically a record of a specific shape. 
{
  description = "nix-demo";

  # Things the flake has available to work with
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Things the flake produces 
  # outputs is a function:
  #   - from `self` followed by the inputs (with the same names as the keys in the inputs record) 
  #   - to a record of a specific shape, the full schema you can find at https://nixos.wiki/wiki/Flakes under the section "Output Schema". we'll only deal with a small subset
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system}; 
      in
      { 
        devShell = import ./shell.nix {inherit pkgs;};
      }
    );
}
