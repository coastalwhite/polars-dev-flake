{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "altair";
	version = "5.4.1";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit pname version format;
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-D7EwuCl6Vp0ImR+2/nY1gudWn4oEZDu9khJDbjvgSu8=";
	};
}
