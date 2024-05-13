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

        rustToolchainStable = pkgs.rust-bin.stable.latest.default;
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            maturin
            rustToolchain
            ruff
            mypy
            dprint
            
            fix-python.packages.${system}.default
            
            (python3.withPackages ( python-pkgs: let
              adbc-driver-manager = python-pkgs.buildPythonPackage rec {
                pname = "adbc_driver_manager";
                version = "0.11.0";
                format = "wheel";

                doCheck = false;
                src = python-pkgs.fetchPypi {
                  inherit pname version format;
									dist = "cp311";
									python = "cp311";
									abi = "cp311";
                  platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
                  sha256 = "sha256-bhWC60UyupxcDhPH3sYQAm3G3IPAUM7pszIJ1o8IsF4=";
                };
              };
              adbc-driver-sqlite = python-pkgs.buildPythonPackage rec {
                pname = "adbc_driver_sqlite";
                version = "0.11.0";
                format = "wheel";

                doCheck = false;
                src = python-pkgs.fetchPypi {
                  inherit pname version format;
									dist = "py3";
									python = "py3";
									abi = "none";
                  platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
                  sha256 = "sha256-bazbckm+VAoe3TatTzxtKnwbbzdCx4Yjnr5gfuXPKYs=";
                };
              };
              connectorx = python-pkgs.buildPythonPackage rec {
                pname = "connectorx";
                version = "0.3.3";
                format = "wheel";
                doCheck = false;
                src = python-pkgs.fetchPypi {
                  inherit pname version format;
                  platform = "manylinux_2_28_x86_64";
									dist = "cp311";
									python = "cp311";
									abi = "cp311";
                  sha256 = "sha256-9DDDWeeXeBj5CsjM47t7o0BGncq+4T5Kx5JvgONOjE0=";
                };
              };
              kuzu = python-pkgs.buildPythonPackage rec {
                pname = "kuzu";
                version = "0.4.1";
                format = "wheel";

                doCheck = false;
                src = python-pkgs.fetchPypi {
                  inherit pname version format;
                  python = "cp311";
                  dist = "cp311";
                  abi = "cp311";
                  platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
                  sha256 = "sha256-rToMGPn2vCbk+EinLZ8yvYsHldVK8UcFFlss0Q9CgPs=";
                };
              };
        #       py-maturin = python-pkgs.buildPythonPackage rec {
        #         pname = "maturin";
        #         version = "1.5.1";
        #         format = "pyproject";
								#
        #         nativeBuildInputs = [
        #           rustToolchainStable
        #         ];
								#
								# propagatedBuildInputs = with python-pkgs; [
								# 	setuptools
								# 	setuptools-rust
								# ];
								#
        #         doCheck = false;
        #         src = builtins.fetchGit {
        #           url = "https://github.com/PyO3/maturin.git";
        #           rev = "dc0b10439309ee9ded8673bc2d928690a28aa405";
        #         };
        #       };
        #       deltalake = python-pkgs.buildPythonPackage rec {
        #         pname = "deltalake";
        #         version = "0.17.4";
        #         format = "pyproject";
								#
        #         nativeBuildInputs = with pkgs; [
        #           maturin
        #         ];
								# dependencies = with pkgs; [
								#   py-maturin
								# ];
        #         doCheck = false;
        #         src = let 
        #           repo = builtins.fetchGit {
        #             url = "https://github.com/delta-io/delta-rs.git";
        #             rev = "497ed209b6e3bcf78eb2190a00341e47e8c30a39";
        #           };
        #         in "${repo}/python";
        #       };
            in with python-pkgs; [
              pytest

              numpy
              pandas
              pyarrow

              # backports-zoneinfo
              tzdata

              sqlalchemy
              adbc-driver-manager
              adbc-driver-sqlite
              aiosqlite
              connectorx
              kuzu

              cloudpickle
              fsspec
              s3fs
              
              lxml
              openpyxl
              pyxlsb
              xlsx2csv
              XlsxWriter
              # deltalake

              zstandard
              hvplot
              matplotlib
              gevent
              nest-asyncio


            ]))
          ];
        };
      }
    );
}