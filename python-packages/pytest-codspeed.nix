{ buildPythonPackage, fetchPypi, python-pkgs, ... }:
buildPythonPackage rec {
	pname = "pytest_codspeed";
	format = "pyproject";
	version = "2.2.1";

	propagatedBuildInputs = with python-pkgs; [
		cffi
		filelock
		pytest
		hatchling
	];

	doCheck = false;
	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-CtwkuvAcZKbKCguDs81wQ1FwiZfgnsCGt3dsMiJ9Tgo=";
	};
}
