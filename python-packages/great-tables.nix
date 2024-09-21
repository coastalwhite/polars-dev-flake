{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "great-tables";
	version = "0.11.0";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit version format;
    pname = "great_tables";
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-IIlwKu3fzVOmcDwQZMOrHl+/U6ZwUeETlgelC1p9q0o=";
	};
}