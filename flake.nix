{
  description = "Telegram bot for downloading yt videos";
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-20.03";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    let
      lib = inputs.stable.lib;
      system = "x86_64-linux";
      unstable-pkgs = inputs.unstable.legacyPackages.${system};
      pkgs = inputs.stable.legacyPackages.${system};
      runtimeDeps = with pkgs; [ youtube-dl ];
      config = {
        projectDir = ./.;
        propagatedBuildInputs = runtimeDeps;
      };
      app = unstable-pkgs.poetry2nix.mkPoetryApplication config;
      env = app.dependencyEnv; # pkgs.poetry2nix.mkPoetryEnv config;
    in {
      devShell."${system}" = pkgs.mkShell {
        buildInputs = with pkgs; [ env poetry nix-deploy ] ++ runtimeDeps;
      };
      defaultPackage."${system}" = app;

      nixosConfigurations = {
        aws-tgytdl = lib.nixosSystem {
          inherit system;
          modules = [{
            imports = [
              "${inputs.stable}/nixos/modules/virtualisation/amazon-image.nix"
            ];
            ec2.hvm = true;
            networking.hostName = "aws-tgytdl";
            systemd.services.tgytdl = {
              description = "Telegram Bot for downloading youtube videos";
              # path = [ pkgs.alsaTools ];
              wantedBy = [ "default.target" ];
              script = ''
                ${inputs.self.defaultPackage."${system}"}/bin/tgytdl_CONTROL 0x0
              '';
            };
            environment.systemPackages =
              [ inputs.self.defaultPackage."${system}" ];
          }];
        };
      };
      aws-tgytdl =
        inputs.self.nixosConfigurations.aws-tgytdl.config.system.build.toplevel;
    };
}
