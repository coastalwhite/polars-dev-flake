{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
	rustToolchain = pkgs.rust-bin.stable.latest.default;
	rustPlatform = pkgs.makeRustPlatform {
		cargo = rustToolchain;
		rustc = rustToolchain;
	};
	subdir = "python";
  lib = pkgs.lib;
  openssl = pkgs.openssl;

	pyarrow-hotfix = buildPythonPackage rec {
		pname = "pyarrow-hotfix";
		version = "0.6";
		format = "pyproject";

		dependencies = with python-pkgs; [
			hatchling
		];

		src = pkgs.fetchFromGitHub {
			owner = "pitrou";
			repo = pname;
			rev = "v${version}";
			hash = "sha256-LlSbxIxvouzvlP6PB8J8fJaxWoRbxz4wTs7Gb5LbM4A=";
		};

		pythonImportsCheck = [ "pyarrow_hotfix" ];
	};
in buildPythonPackage rec {
  pname = "deltalake";
  version = "0.17.4";
  format = "pyproject";

  src = pkgs.stdenv.mkDerivation {
		name = "${pname}-src";
		src = pkgs.fetchFromGitHub {
			owner = "delta-io";
			repo = "delta-rs";
			rev = "python-v${version}";
			hash = "sha256-e+XbsM3CH++ITPmkMNyaf71Noozyx94N9a4P1q3QgAw=";
		};
		phases = [ "unpackPhase" "buildPhase" ];
		buildPhase = ''
			cat ${./Cargo.lock} > Cargo.lock
			mkdir -p $out
			cp ./* -rv $out
		'';
	};

	cargoDeps = rustPlatform.fetchCargoTarball {
		inherit src;
		name = "deltalake-python-${version}";
		hash = "sha256-kOPED5aNiXxGZQxoE0EZJLMzSp0qUeNJ8eoYe1YtmVs=";
  };

	buildAndTestSubdir = subdir;

	env = {
		# needed for openssl-sys
		OPENSSL_NO_VENDOR = 1;
		OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
		OPENSSL_DIR = "${lib.getDev openssl}";
	};

	dependencies = with python-pkgs; [
		pyarrow
		pyarrow-hotfix
	];

	nativeBuildInputs = [
		rustPlatform.cargoSetupHook
		rustPlatform.maturinBuildHook
		rustPlatform.bindgenHook
	];
  
  buildInputs = with pkgs; [
    openssl
  ];

	pythonImportsCheck = [ pname ];
}