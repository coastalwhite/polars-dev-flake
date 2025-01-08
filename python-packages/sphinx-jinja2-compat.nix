{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
  pname = "sphinx-jinja2-compat";
  version = "0.3.0";
  pyproject = true;

  dependencies = with python-pkgs; [ whey whey-pth jinja2 markupsafe ];

  src = pkgs.fetchFromGitHub {
    owner = "sphinx-toolbox";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-MsmeZP96Lrxvfx07yX1fDgXuxrsjx25uGGrIJYRWlbg=";
  };
}
