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
    src = craneLib.cleanCargoSource ../.;
    strictDeps = true;
  };
in
{
  inherit craneLib commonArgs;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
}
