{ buildPythonPackage, pkgs, python-pkgs, localPyPkg, ... }:
buildPythonPackage rec {
	pname = "google-auth-stubs";
	version = "0.3.0";
	format = "pyproject";

	# disabled = pythonVersion < 3.7

	dependencies = with python-pkgs; [
		pytest
		cffi
		filelock
		hatchling
    setuptools
	];


  nativeBuildInputs = with python-pkgs; [
		poetry-core
	];

	propagatedBuildInputs = with python-pkgs; [
		google-auth
		(localPyPkg ./grpc-stubs.nix)
		types-requests
	];

	src = pkgs.fetchFromGitHub {
		owner = "henribru";
		repo = "${pname}";
		rev = "v${version}";
		hash = "sha256-xTJ+MaOZN7jgjSSKB36bcADXC28wUh22DAezZMVd+mk=";
	};

	# pythonImportsCheck = [ "pytest_codspeed" ];
}
