{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildPythonPackage rec {
  pname = "sphinx-favicon";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tcmetzger";
    repo = "sphinx-favicon";
    rev = "v${version}";
    hash = "sha256-Arcjj+6WWuSfufh8oqrDyAtjp07j1JEuw2YlmFcfL3U=";
  };

  dependencies = with python-pkgs; [
		sphinx
    setuptools
  ];

  pythonImportsCheck = [ "sphinx_favicon" ];
}
