{ inputs, pkgs, ... }:
let
  crane = import ../crane.nix { inherit inputs pkgs; };
in
crane.craneLib.cargoTest (crane.commonArgs // { inherit (crane) cargoArtifacts; })
