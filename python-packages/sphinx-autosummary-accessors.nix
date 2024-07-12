{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildPythonPackage {
  pname = "sphinx-autosummary-accessors";
  version = "2023.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "xarray-contrib";
    repo = "sphinx-autosummary-accessors";
    rev = "2023.04.0";
    hash = "sha256-s0epnJLRwTVXn8Y4tzd2i9qkGSXPG2lTL4e0Q4z9eYo=";
  };

  dependencies = with python-pkgs; [
		sphinx
    setuptools
    setuptools-scm
  ];

  pythonImportsCheck = [ "sphinx_autosummary_accessors" ];
}