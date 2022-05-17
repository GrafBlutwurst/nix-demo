{pkgs}: pkgs.mkShell {
  name = "nix-demo shell";
  buildInputs = [];
  shellHook = ''
    echo "PATH"
    echo "=================================="
    echo $PATH
    echo "=================================="
  '';
}
