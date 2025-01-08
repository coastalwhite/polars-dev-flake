{ buildPythonPackage, python-pkgs, pkgs, ... }:
buildPythonPackage rec {
  pname = "dict2css";
  version = "0.3.0";
  pyproject = true;

  dependencies = with python-pkgs; [
    whey
    cssutils
  ];

  src = pkgs.fetchFromGitHub {
    owner = "sphinx-toolbox";
    repo = "dict2css";
    rev = "v${version}";
    hash = "sha256-PkoXFSbTJaYfhb1ba6qUIQ3e9dYNpeTXmCLc39hhrF4=";
  };
}
