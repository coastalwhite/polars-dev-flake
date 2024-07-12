{
  description = "A basic Nix Flake for eachDefaultSystem";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fix-python.url = "github:GuillaumeDesforges/fix-python";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
  };

  outputs = { self, nixpkgs, utils, fix-python, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        lib = pkgs.lib;

        polarsRoot = "$HOME/Projects/polars";
        rustToolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
          extensions = [ "rust-analyzer" "rust-src" ];
        };

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

          pandas-stubs
          boto3-stubs
          duckdb

          sphinx
          numpydoc
          pydata-sphinx-theme
          sphinx-copybutton
          sphinx-design
          # (localPyPkg ./python-packages/sphinx-favicon.nix)
          # (localPyPkg ./python-packages/sphinx-reredirects.nix)
          # (localPyPkg ./python-packages/sphinx-toolbox.nix)
          (localPyPkg ./python-packages/autodocsumm.nix)
          (localPyPkg ./python-packages/sphinx-autosummary-accessors.nix)
          livereload
        ]));
      in {
        devShells.default = let
          aliasToScript = alias: let
            pwd = if alias ? pwd then "${polarsRoot}/${alias.pwd}" else polarsRoot;
          in ''
            set -e
            pushd ${pwd} > /dev/null
            echo "[INFO]: Changed directory to ${pwd}"
            ${alias.cmd}
            popd > /dev/null
          '';
          step = title: alias: ''
            echo '[${title}]'
            ${aliasToScript alias}
            echo '${title} Done ✅'
            echo
          '';
          aliases = rec {
            check = {
              cmd = "cargo check --workspace --all-targets --all-features";
              doc = "Run cargo check with all features";
            };
            typos = {
              cmd = "typos";
              doc = "Run a Spell Check with Typos";
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
              pwd = "py-polars";
              cmd = "maturin develop -m $POLARS_ROOT/py-polars/Cargo.toml";
              doc = "Build the python library";
            };
            pybuild-release = {
              pwd = "py-polars";
              cmd = "maturin develop --release -- -C codegen-units=8 -C lto=thin -C target-cpu=native";
              doc = "Build the python library in release mode";
            };
            pytest-all = {
              pwd = "py-polars";
              cmd = "pytest -n auto --dist loadgroup \"$@\"";
              doc = "Run the default python tests";
            };
            pytest = {
              pwd = "py-polars";
              cmd = "pytest \"$@\"";
              doc = "Run the default python tests";
            };
            pyfmt = {
              pwd = "py-polars";
              cmd = ''
                ruff check
                ruff format
                dprint fmt
                typos
              '';
              doc = "Run python autoformatting";
            };
            rstest = {
              pwd = "crates";
              cmd = ''
                cargo test --all-features \
                  -p polars-compute       \
                  -p polars-core          \
                  -p polars-io            \
                  -p polars-lazy          \
                  -p polars-ops           \
                  -p polars-plan          \
                  -p polars-row           \
                  -p polars-sql           \
                  -p polars-time          \
                  -p polars-utils         \
                  --                      \
                  --test-threads=2        \
              '';
              doc = "Run the Rust tests";
            };
            rsnextest = {
              pwd = "crates";
              cmd = ''
                cargo nextest run --all-features \
                  -p polars-compute              \
                  -p polars-core                 \
                  -p polars-io                   \
                  -p polars-lazy                 \
                  -p polars-ops                  \
                  -p polars-plan                 \
                  -p polars-row                  \
                  -p polars-sql                  \
                  -p polars-time                 \
                  -p polars-utils                \
              '';
              doc = "Run the Rust tests with Cargo-Nextest";
            };
            precommit = {
              cmd = ''
                ${step "Rust Format" fmt}
                ${step "Python Format" pyfmt}
                ${step "Spell Check" typos}
                ${step "Clippy All" clippy-all}
                ${step "Clippy Default" clippy-default}
              '';
              doc = "Run the checks to do before committing";
            };
            prepush = {
              cmd = ''
                ${aliasToScript precommit}
                ${step "Rust Tests" rstest}
                ${step "Python Build" pybuild}
                ${step "Python Tests" pytest-all}
              '';
              doc = "Run the checks to do before pushing";
            };
            profile-setup = {
              cmd = ''
                echo '1'    | sudo tee /proc/sys/kernel/perf_event_paranoid
                echo '1024' | sudo tee /proc/sys/kernel/perf_event_mlock_kb
              '';
              doc = "Setup the environment for profiling";
            };
          };

          mapAttrsToList = lib.attrsets.mapAttrsToList;
        in pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            cmake
            gnumake

            maturin
            rustToolchain
            ruff
            typos
            mypy
            dprint

            zlib

            cargo-nextest

            samply
            hyperfine
            
            python
            fix-python.packages.${system}.default
          ] ++ (
            mapAttrsToList (name: value: pkgs.writeShellScriptBin "pl-${name}" (aliasToScript value)) aliases
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
            export RUST_SRC_BIN="${rustToolchain}/lib/rustlib/src/rust/library";
            export POLARS_ROOT="${polarsRoot}"
            export PYTHONPATH="$PYTHONPATH:$POLARS_ROOT/py-polars"
            export CARGO_BUILD_JOBS=8

            echo
            echo 'Defined Aliases:'
            ${concatStrings (mapAttrsToList (name: value: ''
              echo ' - pl-${name}:${nSpaces (maxLength - (builtins.stringLength name))} ${value.doc}'
            '') aliases)}
          '';
        };
        devShells.polars-py = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            (python3.withPackages (python-pkgs: with python-pkgs; [
              polars
            ]))
          ];
        };
      }
    );
}