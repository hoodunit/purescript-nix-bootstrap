{ pkgs ? import ./pkgs.nix }:
let
  app = pkgs.callPackage ./default.nix { pkgs = pkgs; };
in
pkgs.dockerTools.buildImage {
  name = "purescript-nix-bootstrap";
  tag = "latest";
  contents = app;
  config = {
    Cmd = [ "${pkgs.nodejs}/bin/node" "app.js" ];
  };
}