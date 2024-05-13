{
  description = "A basic Nix Flake for eachDefaultSystem";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    fix-python.url = "github:GuillaumeDesforges/fix-python";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, utils, fix-python, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        polarsPath = "$HOME/Projects/polars";

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            maturin
            rustToolchain
            ruff
            typos
            mypy
            dprint
            
            fix-python.packages.${system}.default
            
            (python3.withPackages ( python-pkgs: let
              localPyPkg = file: import file {
                python = python3;
                python-pkgs = python-pkgs;
                pkgs = pkgs;
                buildPythonPackage = python-pkgs.buildPythonPackage;
                fetchPypi = python-pkgs.fetchPypi;
              };
              
            in with python-pkgs; [
              hypothesis
              pytest
              (localPyPkg ./python-packages/pytest-codspeed.nix)
              pytest-cov
              pytest-xdist

              numpy
              pandas
              pyarrow

              # backports-zoneinfo
              tzdata

              sqlalchemy
              (localPyPkg ./python-packages/adbc-driver-manager.nix)
              (localPyPkg ./python-packages/adbc-driver-sqlite.nix)
              aiosqlite
              (localPyPkg ./python-packages/connectorx.nix)
              (localPyPkg ./python-packages/kuzu.nix)

              cloudpickle
              fsspec
              s3fs
              
              lxml
              openpyxl
              pyxlsb
              xlsx2csv
              XlsxWriter
              (localPyPkg ./python-packages/deltalake.nix)

              zstandard
              hvplot
              matplotlib
              gevent
              nest-asyncio
            ]))
          ];

          shellHook = ''
            echo 'Welcome in your Polars Development Environment :)' | ${pkgs.lolcat}/bin/lolcat
            export PYTHONPATH="$PYTHONPATH:${polarsPath}/py-polars"
          '';
        };
      }
    );
}