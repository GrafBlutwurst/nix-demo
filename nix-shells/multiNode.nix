{
  pkgs
}: let
  
  #Use one of these configs as buildInputs, start the shell. run `npm version` and think about what's going on 
  yikesOne = with pkgs;[
    nodejs-18_x
    nodejs-16_x
  ];

  yikesTwo = with pkgs;[
    nodejs-16_x
    nodejs-18_x
  ];

  
  fixingIt = with pkgs; let 
    #pkgs.writeShellScriptBin is a handy little function that allows you quickly and easily write shell scripts as part of a nix 
    #This indeed defines a full blown package that goes into your nix store 
    #since we use string interpolation and refer to nodejs-16_x we also introduced a transitive dependency 
    #This script will be available on your PATH with the name npm16 you probably want to cat this and think about what's going on. 
    #Remember what we discussed in the beginning about how nix handles dependencies 
    #This is also in general how you can do shell scripts that should be available as part of your devShells 
    #The down-side being that they become somewhat unreadable if large 
    node16 = writeShellScriptBin "npm16" ''
      ${nodejs-16_x}/bin/npm $@
    '';
  in [
    node16
    nodejs-18_x
  ];

in pkgs.mkShell {
  name = "multiNode-shell";
  
  #Remember emptyShell.nix and how buildInputs are added to your PATH. sooo that's not good.
  #we can't "rename" a package but we can wrap it, that fixes the issue of not having one of the npm versions on your path available 
  buildInputs = yikesOne;

}
