{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
  pname = "deltalake";
  version = "0.17.4";
  format = "wheel";

  doCheck = false;
  src = fetchPypi {
    inherit pname version format;
    python = "cp38";
    abi = "abi3";
    dist = "cp38";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    sha256 = "sha256-lN3mwtCgfpzke+Nn0BZUHTpJmDk1CFIgWBk1NEHhqcE=";
  };
}