{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "narwhals";
	version = "1.12.1";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit pname version format;
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-4lHLX+TKvcq7hH01n13iuB33c99H5G+Fj9VXDJNpGcQ=";
	};
}
