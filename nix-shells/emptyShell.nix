#Recall the nix primer. This expression is a function taking a record with a key called pkgs as an input and calls the function mkShell with a record as an argument
#The fact that the key is called pkgs doesn't matter but is common convention. Since nix is dynamically typed names matter a lot more 
{
  #Here we use ? which denotes a default argument so we can build it from the shell without specifying pkgs. Later we'll take care of this using a the flake
  #You *COULD* use https://github.com/NixOS/nixpkgs/tarball/master but you reaaaaaaally shouldn't. It makes derivations unstable since that URL does not qualify a unique resource.
  #fetchTarball should be used sparingly and cautiously 
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs/tarball/4b0da1885ff972d4680ae192fcaec333fdfb862f) {}
}: pkgs.mkShell {
  name = "empty-shell";
  #Build inputs is a list of packages that the shell should have available just like with nix-shell -p 
  #This will add them IN ORDER (important a bit later) to your path variable
  buildInputs = [];
  #Any key here on this record be interpreted as the definition of a environment variable 
  #This includes things that also serve a particular purpose like buildInputs or shellHook you can do `echo $shellHook` 
  myEnvVar = "HELLO WORLD!";
  #shellHook is a bash script that will be run when the shell is started 
  shellHook = ''
    echo "$myEnvVar"
  '';
}
