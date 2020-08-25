{ config, lib, pkgs, ... }:

{
  inputs = {
    doc.url = "https://docs.aiogram.dev/en/latest/install.html";

    stable.url = "github:NixOS/nixpkgs/nixos-20.03";
  };
  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.stable.legacyPackages.${system};
      app = pkgs.poetry2nix.mkPoetryApplication { projectDir = ./.; };
    in {
      devShell."${system}" = app.dependecyEnv;
      # devShell."${system}" = import ./shell.nix {
      #   pkgs = inputs.stable.legacyPackages.${system};
      #   #import inputs.stable { inherit system; };
      # };
    };
}
