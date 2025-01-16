{
  description = "A basic Nix Flake for eachDefaultSystem";

  inputs = {
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
    polars = {
      url = "github:pola-rs/polars";
      flake = false;
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs, utils, rust-overlay, polars, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        lib = pkgs.lib;

        polarsRoot = "$HOME/Projects/polars";
        rustToolchain = (pkgs.rust-bin.fromRustupToolchainFile "${polars}/rust-toolchain.toml").override {
          extensions = [ "rust-analyzer" "rust-src" "miri" ];
        };

        python = (pkgs.python311.withPackages ( python-pkgs: let
          localPyPkg = file: import file {
            inherit pkgs python-pkgs ;
            python = pkgs.python3;
            buildPythonPackage = python-pkgs.buildPythonPackage;
            fetchPypi = python-pkgs.fetchPypi;
            localPyPkg = localPyPkg;
          };
          requirements = with python-pkgs; {
            dev = [
              # === DEPENDENCIES ===
              # Interop
              numpy
              numba # >= 0.54; python_version < '3.13'
              pandas
              pyarrow
              pydantic # >=2.0.0
              numba

              # Datetime / Time zones
              # backports.zoneinfo # python_version < '3.9'
              tzdata             # platform_system == 'Windows'

              # Database
              sqlalchemy
              (localPyPkg ./python-packages/adbc-driver-manager.nix) # python_version >= '3.9' and platform_system != 'Windows'
              (localPyPkg ./python-packages/adbc-driver-sqlite.nix)  # python_version >= '3.9' and platform_system != 'Windows'
              aiosqlite
              (localPyPkg ./python-packages/connectorx.nix)
              (localPyPkg ./python-packages/kuzu.nix)
              nest-asyncio

              # Cloud
              cloudpickle
              fsspec
              s3fs # [boto3]

              # Spreadsheet
              (localPyPkg ./python-packages/fastexcel) # >= 0.11.5
              openpyxl
              xlsx2csv
              xlsxwriter

              # Other IO
              deltalake # >= 0.15.0

              # CSV
              zstandard

              # Plotting
              altair #>= 5.4.0

              # Styling
              great-tables #>=0.8.0; python_version >= '3.9'

              # Async
              gevent

              # Graph
              matplotlib

              # Testing
              hypothesis

              # === TOOLING ===
              pytest                                             # ==8.3.2
              (localPyPkg ./python-packages/pytest-codspeed.nix) # ==3.0.0
              pytest-cov                                         # ==6.0.0
              pytest-xdist                                       # ==3.6.1

              moto # [s3]==5.0.9
              flask
              flask-cors

              # Stub files
              pandas-stubs
              boto3-stubs
              (localPyPkg ./python-packages/google-auth-stubs.nix)
            ];
            ci = [
              # --extra-index-url https://download.pytorch.org/whl/cpu
              torch
              jax # [cpu]
              (pkgs-unstable.python311Packages.pyiceberg) # >=0.5.0
            ];
            lint = [
              mypy  # [faster-cache]==1.13.0
              (localPyPkg ./python-packages/ruff)  # ==0.8.1
              pkgs.typos # ==1.27.2
            ];
            docs = [
              hypothesis
              numpy
              pandas
              pyarrow

              sphinx                       #==8.1.3

              # Third-party Sphinx extensions
              (localPyPkg ./python-packages/autodocsumm.nix)                  #==0.2.14
              numpydoc                                                        #==1.8.0
              pydata-sphinx-theme                                             #==0.16.0
              (localPyPkg ./python-packages/sphinx-autosummary-accessors.nix) #==2023.4.0
              sphinx-copybutton                                               #==0.5.2
              sphinx-design                                                   #==0.6.1
              (localPyPkg ./python-packages/sphinx-favicon.nix)               #==1.0.1
              (localPyPkg ./python-packages/sphinx-reredirects.nix)           #==0.1.5
              # Sphinx toolbox is a bitch
              # (localPyPkg ./python-packages/sphinx-toolbox.nix)               #==3.8.1

              livereload                                                      #==2.7.0
            ];
          };
        in with python-pkgs; 
          (requirements.dev ++
          requirements.ci   ++
          requirements.lint ++
          requirements.docs ++

          [
            importlib-resources
            psutil
            hvplot
            seaborn

            duckdb
            pandas
            jupyterlab

            pygithub

            # Used for polars-benchmark
            pydantic-settings
     #    [
     #      pydantic
     #      hypothesis
     #      pytest
     #      (localPyPkg ./python-packages/pytest-codspeed.nix)
     #      pytest-cov
     #      pytest-xdist
					#
     #      moto
     #      flask
     #      flask-cors
     #      boto3
					#
     #      numpy
     #      pandas
					# # pkgs-unstable.python311Packages.pyarrow
     #      pyarrow
					#
     #      backports-zoneinfo
     #      tzdata
					#
     #      cloudpickle
     #      fsspec
     #      s3fs
     #      
     #      lxml
     #      openpyxl
     #      pyxlsb
     #      xlsx2csv
     #      XlsxWriter
     #      (localPyPkg ./python-packages/deltalake/default.nix)
					#
     #      zstandard
     #      (localPyPkg ./python-packages/altair.nix)
     #      matplotlib
     #      gevent
     #      nest-asyncio
					#
     #      pandas-stubs
     #      boto3-stubs
					#
     #      mkdocs-material
     #      mkdocs-material-extensions
     #      mkdocs-redirects
     #      mkdocs-macros
     #      (localPyPkg ./python-packages/markdown-exec.nix)
     #      (localPyPkg ./python-packages/material-plausible.nix)
     #      (localPyPkg ./python-packages/great-tables.nix)
					# numba
					# plotly
					#
     #      jsonschema
     #      (localPyPkg ./python-packages/narwhals.nix)
					#
     #      memory-profiler
					#
     #      sphinx
     #      numpydoc
     #      pydata-sphinx-theme
     #      sphinx-copybutton
     #      sphinx-design
     #      # (localPyPkg ./python-packages/sphinx-favicon.nix)
     #      # (localPyPkg ./python-packages/sphinx-reredirects.nix)
     #      # (localPyPkg ./python-packages/sphinx-toolbox.nix)
     #      (localPyPkg ./python-packages/autodocsumm.nix)
     #      (localPyPkg ./python-packages/sphinx-autosummary-accessors.nix)
     #      livereload
        ])));
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
          buildPy = alias: cmd: let 
            targetDir = "$POLARS_ROOT/py-polars/polars";
          in ''
            ${cmd}
            mv "${targetDir}/polars.abi3.so" "${targetDir}/polars.abi3.so.${alias}"
            ln -sf "${targetDir}/polars.abi3.so.${alias}" "${targetDir}/polars.abi3.so"
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
            pyselect = {
              pwd = "py-polars";
              cmd = ''
								if [ -z "$1" ]; then
									echo "Usage $0 <debug/debug-release>"
                  exit 2
								fi

                ln -sf "$POLARS_ROOT/py-polars/polars/polars.abi3.so.$1.latest" polars/polars.abi3.so
              '';
              doc = "Build the python library";
            };
            pybuild = {
              pwd = "py-polars";
              cmd = buildPy "debug" "maturin develop -m $POLARS_ROOT/py-polars/Cargo.toml \"$@\"";
              doc = "Build the python library";
            };
            pybuild-mindebug = {
              pwd = "py-polars";
              cmd = buildPy "mindebug" "maturin develop --profile mindebug-dev \"$@\"";
              doc = "Build the python library with minimal debug information";
            };
            pybuild-nodebug-release = {
              pwd = "py-polars";
              cmd = buildPy "nodebug-release" "maturin develop --profile nodebug-release \"$@\"";
              doc = "Build the python library in release mode without debug symbols";
            };
            pybuild-release = {
              pwd = "py-polars";
              cmd = buildPy "release" "maturin develop --profile release \"$@\"";
              doc = "Build the python library in release mode with minimal debug symbols";
            };
            pybuild-debug-release = {
              pwd = "py-polars";
              cmd = buildPy "debug-release" "maturin develop --profile debug-release \"$@\"";
              doc = "Build the python library in release mode with full debug symbols";
            };
            pybuild-dist-release = {
              pwd = "py-polars";
              cmd = buildPy "dist-release" "maturin develop --profile dist-release \"$@\"";
              doc = "Build the python library in release mode which would be distributed to users";
            };
            pyselect-build = {
              pwd = "py-polars";
              cmd = ''
                if [ -z "$1" ]; then
                    echo "Usage: $0 <BUILD>" > 2
                    exit 2
                fi

                TARGET_DIR="$POLARS_ROOT/py-polars/polars"
                ln -sf "$TARGET_DIR/polars.abi3.so.$1" "$TARGET_DIR/polars.abi3.so"
              '';
              doc = "Select a previous build of polars";
            };
            pytest-all = {
              pwd = "py-polars";
              cmd = "pytest -n auto --dist=loadgroup \"$@\"";
              doc = "Run the default python tests";
            };
            pytest-release = {
              pwd = "py-polars";
              cmd = "pytest -n auto --dist=loadgroup -m 'not release and not benchmark and not docs' \"$@\"";
              doc = "Run the release python tests";
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
                ${step "Python Build" pybuild-mindebug}
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
            debug-setup = {
              cmd = ''
                echo '0' | sudo tee /proc/sys/kernel/yama/ptrace_scope
              '';
              doc = "Setup the environment for attach debugging";
            };
          };

          mapAttrsToList = lib.attrsets.mapAttrsToList;
        in pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            cmake
            gnumake

            maturin
            rustToolchain
            
            typos
            mypy
            dprint

            zlib

            cargo-nextest

            samply
            hyperfine

            openssl
            pkg-config
            
            python
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
						export PATH="${python}/bin:$PATH"

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