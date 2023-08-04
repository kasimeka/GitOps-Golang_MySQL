{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system: let pkgs = import nixpkgs { inherit system; };
    in with pkgs; {
      devShells.default = mkShell {
        buildInputs = [
          kubectl kubernetes-helm argocd openssl kubeseal curl # podman podman-compose
        ];

        shellHook = ''
          source <(kubectl completion bash)
          source <(helm completion bash)
          source <(argocd completion bash)
          export PS1='\[\e[0;31m\](go-serve) '$PS1
        '';
      };
    });
}
