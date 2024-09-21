{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "material-plausible";
	version = "0.2.0";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit version format;
    pname = "material_plausible_plugin";
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-t9yGazWEddlAxcYfVvhsQAucHnP/orBoGSB98480/PQ=";
	};
}