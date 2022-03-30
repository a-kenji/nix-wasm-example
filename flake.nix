{
  description = "How to buil wasm modules in nix";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs , rust-overlay , flake-utils }:
    flake-utils.lib.defaultSystems (
      system: let
        overlays = [ (import rust-overlay )];
          pkgs = import nixpkgs {inherit system overlays;};
          rustToolchainToml = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;
  #cargoLock = {
    #lockFile = builtins.path {
      #path = ./Cargo.lock;
      #name = "Cargo.lock";
    #};
  #};
  cargo = rustToolchainToml;
  rustc = rustToolchainToml;
  buildInputs = [
    rustToolchainToml
  ];
      in
      {
        #packages.wasm-test = (pkgs.makeRustPlatform {inherit cargo rustc}).buildRustPackage {
          #inherit
          #src
          #name

        #};
        #defaultPackage = packages.wasm-test;
        devShell = pkgs.mkShell {
          inherit buildInputs;
        };
    });}
