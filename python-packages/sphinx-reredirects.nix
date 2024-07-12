{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildPythonPackage rec {
  pname = "sphinx-reredirects";
  version = "0.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "documatt";
    repo = "sphinx-reredirects";
    rev = "v${version}";
    hash = "sha256-YP1zFE1QJWgmTxU1lx7u//OLFQqK3k2GgkdjVQ6s7xU=";
  };

  dependencies = with python-pkgs; [
		sphinx
    setuptools
  ];

  pythonImportsCheck = [ "sphinx_reredirects" ];
}
