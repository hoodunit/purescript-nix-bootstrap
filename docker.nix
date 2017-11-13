{ pkgs ? import ./pkgs.nix }:
let
  app = pkgs.callPackage ./default.nix { pkgs = pkgs; };
in
pkgs.dockerTools.buildImage {
  name = "purescript-nix-bootstrap";
  tag = "latest";
  contents = [ pkgs.bashInteractive pkgs.coreutils pkgs.gnugrep ];
  config = {
    Cmd = [ "${app}/bin/purescript-nix-bootstrap" ];
    WorkingDir = "${app}";
  };
}