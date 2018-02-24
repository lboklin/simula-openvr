{ pkgs ? import <nixpkgs> {}, ghc ? pkgs.ghc }:

with pkgs;

haskellPackages.callPackage ./default.nix {
  inherit fetchFromGitHub;

  openvr_api = callPackage ./openvr.nix {};
  stdenv = overrideCC stdenv gcc7;
}
