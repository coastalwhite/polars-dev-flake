{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
	pname = "grpc-stubs";
	version = "1.53.0.5";
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
		grpcio
	];

	src = pkgs.fetchFromGitHub {
		owner = "shabbyrobe";
		repo = "${pname}";
		rev = "${version}";
		hash = "sha256-an7xztaCqxOEmf74Rgb8q9u/WsojFYkBiwtLRa1qqBQ=";
	};

	# pythonImportsCheck = [ "pytest_codspeed" ];
}
