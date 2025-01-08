{ buildPythonPackage, pkgs, python-pkgs, ... } @ params:
let
  fetchFromGitHub = pkgs.fetchFromGitHub;
	dict2css = import ./dict2css.nix params;
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
    dict2css
		(import ./autodocsumm.nix params)
    (import ./apeye.nix params)
    beautifulsoup4
    cachecontrol
    sphinx-tabs
    sphinx-prompt
    sphinx-autodoc-typehints
		(import ./sphinx-jinja2-compat.nix params)
    filelock
    html5lib
    ruamel-yaml
    tabulate
  ];

  pythonImportsCheck = [ "sphinx_toolbox" ];
}
