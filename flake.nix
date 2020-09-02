{
  description = "Telegram bot for downloading yt videos";
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-20.03";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.unstable.legacyPackages.${system};
      app = pkgs.poetry2nix.mkPoetryApplication { projectDir = ./.; };
      env = pkgs.poetry2nix.mkPoetryEnv { projectDir = ./.; };
    in {
      devShell."${system}" = pkgs.mkShell {
        buildInputs = with pkgs; [ env poetry youtube-dl ];
      };
      defaultPackage."${system}" = app;
    };
}
