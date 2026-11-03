# Shared by the checks so they reuse one build of the dependencies.
{ inputs, pkgs }:
let
  craneLib = (inputs.crane.mkLib pkgs).overrideScope (
    _: _: {
      stdenvSelector =
        p: if p.stdenv.hostPlatform.isLinux then p.stdenvAdapters.useMoldLinker p.stdenv else p.stdenv;
    }
  );
  commonArgs = {
    # Keep insta snapshots, which cleanCargoSource would drop.
    src = pkgs.lib.cleanSourceWith {
      src = ../.;
      filter = path: type: pkgs.lib.hasSuffix ".snap" path || craneLib.filterCargoSources path type;
    };
    strictDeps = true;
  };
in
{
  inherit craneLib commonArgs;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
}
