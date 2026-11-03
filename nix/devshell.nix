{ inputs, pkgs, ... }:
let
  pre-commit-check = import ./checks/pre-commit-check.nix { inherit inputs pkgs; };
in
pkgs.mkShell {
  packages = with pkgs; [
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer
  ];

  env = {
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
