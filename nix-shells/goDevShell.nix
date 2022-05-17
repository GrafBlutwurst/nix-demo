{ pkgs
}:
let

  #I found this script somewhere and it's pretty neat! Generated the needed data you need to define VSCode plugins in nix  
  #to call this, go to the marketplace to a plugin, check the unique identifier and split it at '.' those are the two arguments to this script e.g. 
  #https://marketplace.visualstudio.com/items?itemName=golang.go
  #Unique Identifier: golang.Go 
  #vscPlugin "golang" "Go" 
  vscPlugin = with pkgs; writeShellScriptBin "vscPlugin" ''
    function get_vsixpkg() {
        N="$1.$2"
    
        # Create a tempdir for the extension download
        EXTTMP=$(mktemp -d -t vscode_exts_XXXXXXXX)
    
        URL="https://$1.gallery.vsassets.io/_apis/public/gallery/publisher/$1/extension/$2/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    
        # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
        ${curl}/bin/curl --silent --show-error --fail -X GET -o "$EXTTMP/$N.zip" "$URL"
        # Unpack the file we need to stdout then pull out the version
        VER=$(${jq}/bin/jq -r '.version' <(${unzip}/bin/unzip -qc "$EXTTMP/$N.zip" "extension/package.json"))
        # Calculate the SHA
        # We assume you have nix installed, else you couldn't run it anyway. So we don't interpolate here 
        SHA=$(nix-hash --flat --base32 --type sha256 "$EXTTMP/$N.zip")
    
        # Clean up.
        rm -Rf "$EXTTMP"
        # I don't like 'rm -Rf' lurking in my scripts but this seems appropriate
    
        cat <<-EOF
      {
        name = "$2";
        publisher = "$1";
        version = "$VER";
        sha256 = "$SHA";
      }
    EOF
    }

    get_vsixpkg $@
  '';

  #And here we configure our VSCode. You can find more about how to do this here: 
  # https://nixos.wiki/wiki/Visual_Studio_Code
  vsCode =
    with pkgs; let
      goExtension = {
        name = "Go";
        publisher = "golang";
        version = "0.33.0";
        sha256 = "1wd9zg4jnn7y75pjqhrxm4g89i15gff69hsxy7y5i6njid0x3x0w";
      };
      marketPlaceVsCodeExtensions = vscode-utils.extensionsFromVscodeMarketplace [
        goExtension
      ];
      nixVsCodeExtensions = with vscode-extensions; [
        bbenoist.nix
      ];
      extensions = nixVsCodeExtensions ++ marketPlaceVsCodeExtensions;

    in
    vscode-with-extensions.override {
      vscodeExtensions = extensions;
    };


in
pkgs.mkShell {
  name = "go-dev-shell";
  buildInputs = [
    pkgs.rnix-lsp
    pkgs.nixpkgs-fmt
    pkgs.gopls
    pkgs.go_1_17
    pkgs.golint
    vscPlugin
    vsCode
  ];
}
