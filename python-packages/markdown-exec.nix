{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "markdown-exec";
	version = "1.9.3";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit version format;
    pname = "markdown_exec";
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-az9fNdnHTjx7qQETdq0XMqo+04Bsre+4Ui3uOv4Csew=";
	};
}