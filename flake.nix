{
  description = "How to build wasm modules in nix";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        src = ./.;
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {inherit system overlays;};
        pkgs-cross-wasm-wasi = import nixpkgs {
      inherit system ;
      crossSystem = nixpkgs.lib.systems.examples.wasi32
      // {
        rustc.config = "wasm32-wasi";
    };
    useLLVM = true;
};
        rust-cross-wasm-wasi-ToolchainToml = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;

        cargoLock = {
          lockFile = builtins.path {
            path = ./Cargo.lock;
            name = "Cargo.lock";
          };
        };
        nativeBuildInputs = [
          rust-cross-wasm-wasi-ToolchainToml
        ];
      in rec {
        packages.wasm-test = (pkgs-cross-wasm-wasi.makeRustPlatform {
          cargo = rust-cross-wasm-wasi-ToolchainToml;
          rustc = rust-cross-wasm-wasi-ToolchainToml;
        }).buildRustPackage {
          inherit
            src
            cargoLock
            ;
          name = "wasm-test";
        };
        defaultPackage = packages.wasm-test;
        devShell = pkgs.mkShell {
          inherit nativeBuildInputs;
        };
      }
    );
}
