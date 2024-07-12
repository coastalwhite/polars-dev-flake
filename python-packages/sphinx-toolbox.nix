{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
  whey = buildPythonPackage rec {
    pname = "whey";
    version = "0.1.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "repo-helper";
      repo = "whey";
      rev = "v${version}";
      hash = "sha256-s2jZmuFj0gTWVTcXWcBhcu5RBuaf/qMS/xzIpIoG1ZE=";
    };

    dependencies = with python-pkgs; [ setuptools ];

    pythonImportsCheck = [ "whey" ];
  };
in
buildPythonPackage rec {
  pname = "sphinx-toolbox";
  version = "3.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sphinx-toolbox";
    repo = "sphinx-toolbox";
    rev = "v${version}";
    hash = "sha256-UjXWj5jrgDDuyljsf0XCnvigV4BpZ02Wb6QxN+sXDXs=";
  };

  dependencies = with python-pkgs; [
		sphinx
    whey
    setuptools
  ];

  pythonImportsCheck = [ "sphinx_toolbox" ];
}
