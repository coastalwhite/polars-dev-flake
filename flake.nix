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
        lib = pkgs.lib;

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        python = (pkgs.python3.withPackages ( python-pkgs: let
          localPyPkg = file: import file {
						inherit pkgs python-pkgs ;
            python = pkgs.python3;
            buildPythonPackage = python-pkgs.buildPythonPackage;
            fetchPypi = python-pkgs.fetchPypi;
          };
        in with python-pkgs; [
          pydantic
          hypothesis
          pytest
          (localPyPkg ./python-packages/pytest-codspeed.nix)
          pytest-cov
          pytest-xdist

          flask
          flask-cors

          moto
          boto3
          importlib-resources

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
          (localPyPkg ./python-packages/deltalake/default.nix)

          zstandard
          hvplot
          matplotlib
          gevent
          nest-asyncio
        ]));
      in {
        devShells.default = let
          aliases = rec {
            check = {
              cmd = "cargo check --workspace --all-targets --all-features";
              doc = "Run cargo check with all features";
            };
            clippy-all = {
              cmd = "cargo clippy --workspace --all-targets --all-features --locked -- -D warnings -D clippy::dbg_macro";
              doc = "Run clippy with all features";
            };
            clippy-default = {
              cmd = "cargo clippy --all-targets --locked -- -D warnings -D clippy::dbg_macro";
              doc = "Run clippy with default features";
            };
            fmt = {
              cmd = "cargo fmt --all";
              doc = "Run autoformatting";
            };
            pybuild = {
              cmd = "maturin develop -m $POLARS_ROOT/py-polars/Cargo.toml";
              doc = "Build the python library";
            };
            pytest-all = {
              cmd = "pytest -n auto --dist loadgroup \"$@\"";
              doc = "Run the default python tests";
            };
            pytest = {
              cmd = "pytest \"$@\"";
              doc = "Run the default python tests";
            };
            pyfmt = {
              cmd = ''
                ruff check
                ruff format
                dprint fmt
                typos
              '';
              doc = "Run python autoformatting";
            };
            precommit = {
              cmd = ''
                set -e
                echo '[Format]'
                ${fmt.cmd}
                echo 'Format Done ✅'
                echo
                echo '[Clippy All]:'
                ${clippy-all.cmd}
                echo 'Clippy All Done ✅'
                echo
                echo '[Clippy Default]:'
                ${clippy-default.cmd}
                echo 'Clippy Default Done ✅'
              '';
              doc = "Run the checks to do before committing";
            };
          };

          mapAttrsToList = lib.attrsets.mapAttrsToList;
        in pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            maturin
            rustToolchain
            ruff
            typos
            mypy
            dprint

            zlib

						cargo-nextest
            
            python
            fix-python.packages.${system}.default
          ] ++ (
            mapAttrsToList (name: value: pkgs.writeShellScriptBin "pl-${name}" value.cmd) aliases
          );

          shellHook = let
            concatStrings = lib.concatStrings;

            max = x: y:
                assert builtins.isInt x;
                assert builtins.isInt y;
                if x < y then y
                         else x;
            listMax = lib.foldr max 0;
            maxLength = listMax (mapAttrsToList (name: _: (builtins.stringLength name)) aliases);
            nSpaces = n: (lib.concatMapStrings (_: " ") (lib.range 1 n));
          in ''
            echo 'Welcome in your Polars Development Environment :)' | ${pkgs.lolcat}/bin/lolcat
            export POLARS_ROOT="$HOME/Projects/polars"
            export PYTHONPATH="$PYTHONPATH:$POLARS_ROOT/py-polars"

            echo
            echo 'Defined Aliases:'
            ${concatStrings (mapAttrsToList (name: value: ''
              echo ' - pl-${name}:${nSpaces (maxLength - (builtins.stringLength name))} ${value.doc}'
            '') aliases)}
          '';
        };
      }
    );
}