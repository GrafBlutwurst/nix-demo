#A flake itself is a nix expression, specifically a record of a specific shape. 
{
  description = "nix-demo";

  # Things the flake has available to work with
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-same-version-as-tarball.url = "github:NixOS/nixpkgs?rev=4b0da1885ff972d4680ae192fcaec333fdfb862f";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Things the flake produces 
  # outputs is a function:
  #   - from `self` followed by the inputs (with the same names as the keys in the inputs record) 
  #   - to a record of a specific shape, the full schema you can find at https://nixos.wiki/wiki/Flakes under the section "Output Schema". we'll only deal with a small subset
  outputs = { self, nixpkgs, flake-utils, nixpkgs-same-version-as-tarball }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system}; 
        tarballPkgs = nixpkgs-same-version-as-tarball.legacyPackages.${system};
        
        emptyShell = import ./nix-shells/emptyShell.nix;
      in
      { 
        #devShell tells what the default shell of this flake is. It is invoked when you run the command `nix develop`
        #Recall what we discussed when we built and used this shell "the old way" this now passes pkgs explicitly
        #pkgs is in turn controlled by the flake and it's lockfile 
        devShell = emptyShell {inherit pkgs;};

        #devShells are all other available shells for this flake. They have to be started by name 
        #nix develop .#emptyShell 
        #            ^     ^
        #            |     |
        #         flake    |             (in our case pwd, but this can also refer to something by URL or something in `nix registry list`
        #              devShells key 
        devShells =  {
          #So lets create a shell with the same version as we fetched the tarball using the default argument before. 
          emptyShellTarBall = emptyShell {pkgs = tarballPkgs;};
        };
      }
    );
}
