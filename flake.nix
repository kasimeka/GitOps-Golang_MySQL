{
  nixConfig.bash-prompt-prefix = ''\[\e[0;31m\](go-server) \e[0m'';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          kubectl
          kubernetes-helm
          argocd
          openssl
          kubeseal
          curl
          # podman podman-compose
        ];

        shellHook = ''
          source <(kubectl completion bash)
          source <(helm completion bash)
          source <(argocd completion bash)
        '';
      };
    });
}
