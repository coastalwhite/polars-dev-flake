{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
  pname = "connectorx";
  version = "0.3.3";
  format = "wheel";

  doCheck = false;
  src = fetchPypi {
    inherit pname version format;
    platform = "manylinux_2_28_x86_64";
    dist = "cp311";
    python = "cp311";
    abi = "cp311";
    sha256 = "sha256-9DDDWeeXeBj5CsjM47t7o0BGncq+4T5Kx5JvgONOjE0=";
  };
}
