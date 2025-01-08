{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
	pname = "pytest-codspeed";
	version = "2.2.1";
	format = "pyproject";

	# disabled = pythonVersion < 3.7

	dependencies = with python-pkgs; [
		pytest
		cffi
		filelock
		hatchling
    setuptools
	];

	src = pkgs.fetchFromGitHub {
		owner = "CodSpeedHQ";
		repo = "pytest-codspeed";
		rev = "v${version}";
		hash = "sha256-8C+Nxp831qZAWTOPwWXfnXQs0lMesu2QPPhJZsmTEl4=";
	};

	pythonImportsCheck = [ "pytest_codspeed" ];
}
