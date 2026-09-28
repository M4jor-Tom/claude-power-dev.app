{
  description = "Claude Code, pre-loaded with the claude-power-dev profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { self
    , nixpkgs
    , systems
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.foldl' lib.recursiveUpdate { } (map f (import systems));

      overlay = final: prev: {
        claude-power-dev = final.callPackage ./package.nix { };
      };
    in
    eachSystem
      (system:
      let
        # claude-code is unfree, so this flake allows it for its own nixpkgs.
        # Without this, `nix run github:...` fails at evaluation for everyone.
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
      in
      {
        packages.${system} = {
          default = pkgs.claude-power-dev;
          claude-power-dev = pkgs.claude-power-dev;
        };

        apps.${system} = {
          default = {
            type = "app";
            program = "${pkgs.claude-power-dev}/bin/claude-power-dev";
            meta.description = "Claude Code running the claude-power-dev profile";
          };
          claude-power-dev = {
            type = "app";
            program = "${pkgs.claude-power-dev}/bin/claude-power-dev";
            meta.description = "Claude Code running the claude-power-dev profile";
          };
        };

        devShells.${system}.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-fmt ];
        };
      }) // {
      overlays.default = overlay;
    };
}
