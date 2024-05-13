{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
  pname = "adbc_driver_manager";
  version = "0.11.0";
  format = "wheel";

  doCheck = false;
  src = fetchPypi {
    inherit pname version format;
    dist = "cp311";
    python = "cp311";
    abi = "cp311";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    sha256 = "sha256-bhWC60UyupxcDhPH3sYQAm3G3IPAUM7pszIJ1o8IsF4=";
  };
}