{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
	pname = "pytest-profiling";
	version = "1.8.0";
	format = "pyproject";

	# disabled = pythonVersion < 3.7

	dependencies = with python-pkgs; [
		pytest
		cffi
		filelock
		hatchling
    setuptools
    six
    gprof2dot
	];

	src = let
		owner = "man-group";
		repo = "pytest-plugins";
  in builtins.fetchTarball {
    url = "https://github.com/${owner}/${repo}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256:124j9rj4g6am3yjqw06dz80k1m1c56mqa1njmbbqxqjyygpyq252";
  };
}
