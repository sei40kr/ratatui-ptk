{ inputs, pkgs, ... }:
let
  pre-commit-check = import ./checks/pre-commit-check.nix { inherit inputs pkgs; };
  mkShell =
    if pkgs.stdenv.hostPlatform.isLinux then
      pkgs.mkShell.override { stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.stdenv; }
    else
      pkgs.mkShell;
in
mkShell {
  packages = with pkgs; [
    cargo
    rustc
    clippy
    cargo-insta
    rustfmt
    rust-analyzer
    mold
    sccache
  ];

  env = {
    RUSTC_WRAPPER = "sccache";
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
