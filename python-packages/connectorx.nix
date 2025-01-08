{ buildPythonPackage, pkgs, fetchPypi, ... }:
let
  lib = pkgs.lib;
in buildPythonPackage rec {
  pname = "connectorx";
  version = "0.4.0";
  format = "pyproject";
  
  src = pkgs.fetchFromGitHub {
    owner = "sfu-db";
    repo = "connector-x";
    rev = "v${version}";
    hash = "sha256-KlD1cGrNXxx1XDXxzuCqsSO7PxOrB60f9e7UT86A17g=";
  };

  sourceRoot = "${src.name}/connectorx-python";

  cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
    inherit src sourceRoot;
    name = "${pname}-python-${version}";
    hash = "sha256-FC7F/dGFG17vSP4lHqCbVOK6hx5td2xa7rSnrPPKg/c=";
  };

  env = {
    # needed for openssl-sys
    OPENSSL_NO_VENDOR = 1;
    OPENSSL_LIB_DIR = "${lib.getLib pkgs.openssl}/lib";
    OPENSSL_DIR = "${lib.getDev pkgs.openssl}";
  };

  nativeBuildInputs = [
    pkgs.krb5 # needed for `krb5-config` during libgssapi-sys

    pkgs.rustPlatform.cargoSetupHook
    pkgs.rustPlatform.maturinBuildHook
    pkgs.rustPlatform.bindgenHook
  ];

  # nativeCheckInputs = [ pytestCheckHook ];

  buildInputs = with pkgs; [
    libkrb5 # needed for libgssapi-sys
    openssl # needed for openssl-sys
  ];

  pythonImportsCheck = [ "connectorx" ];

}
