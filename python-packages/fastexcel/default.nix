{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
  pname = "fastexcel";
  version = "0.12.0";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "ToucanToco";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HL3KQ/jSQ/+zMz033eFLfN1Hyq3+FXB2QSYhUyHdFUs=";
  };
  
  dependencies = with python-pkgs; [
		pyarrow
  ];

  nativeBuildInputs = with pkgs.rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    cargoCheckHook
  ];

  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  doCheck = false;
}
