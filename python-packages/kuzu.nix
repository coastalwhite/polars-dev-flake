{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "kuzu";
	version = "0.4.1";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit pname version format;
		python = "cp311";
		dist = "cp311";
		abi = "cp311";
		platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
		sha256 = "sha256-rToMGPn2vCbk+EinLZ8yvYsHldVK8UcFFlss0Q9CgPs=";
	};
}
