{ buildPythonPackage, pkgs, python-pkgs, ... }:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildPythonPackage rec {
  pname = "sphinx-autosummary-accessors";
  version = "0.2.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Chilipp";
    repo = "autodocsumm";
    rev = "v${version}";
    hash = "sha256-dl4whzVw85gSZGPGgGbBISbu6bmZSzN8ynQ2+SlCoik=";
  };

  dependencies = with python-pkgs; [
		sphinx
		versioneer
    setuptools
  ];

  pythonImportsCheck = [ "autodocsumm" ];
}