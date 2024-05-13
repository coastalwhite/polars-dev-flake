{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
  pname = "adbc_driver_sqlite";
  version = "0.11.0";
  format = "wheel";

  doCheck = false;
  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    sha256 = "sha256-bazbckm+VAoe3TatTzxtKnwbbzdCx4Yjnr5gfuXPKYs=";
  };
}
