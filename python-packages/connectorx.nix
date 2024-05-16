{ buildPythonPackage, pkgs, ... }:
let
	rustToolchain = pkgs.rust-bin.stable.latest.default;
	rustPlatform = pkgs.makeRustPlatform {
		cargo = rustToolchain;
		rustc = rustToolchain;
	};
	subdir = "connectorx-python";
	lib = pkgs.lib;
	openssl = pkgs.openssl;
in buildPythonPackage rec {
  pname = "connectorx";
  version = "0.3.3";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
		owner = "sfu-db";
		repo = "connector-x";
    rev = "v${version}";
		hash = "sha256-L/tI2Lux+UnXZrpBxXX193pvb34hr5kqWo0Ncb1V+R0=";
  };

	cargoDeps = rustPlatform.importCargoLock {
		lockFile = "${src}/${subdir}/Cargo.lock";
  };

	buildAndTestSubdir = subdir;
	cargoRoot          = subdir;

	env = {
		# needed for openssl-sys
		OPENSSL_NO_VENDOR = 1;
		OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
		OPENSSL_DIR = "${lib.getDev openssl}";
	};

	nativeBuildInputs = with pkgs; [
		krb5 # needed for `krb5-config` during libgssapi-sys

		rustPlatform.cargoSetupHook
		rustPlatform.maturinBuildHook
		rustPlatform.bindgenHook
	];

	buildInputs = with pkgs; [
		libkrb5 # needed for libgssapi-sys
		openssl # needed for openssl-sys
	];

	pythonImportsCheck = [ pname ];
}
