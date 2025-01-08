{ buildPythonPackage, pkgs, python-pkgs, ... }:
buildPythonPackage rec {
  pname = "apeye";
  version = "1.4.1";
  pyproject = true;

  dependencies = with python-pkgs; [
    apeye-core
    requests
    platformdirs
    flit-core
  ];

  src = pkgs.fetchFromGitHub {
    owner = "domdfcoding";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kxFVsGMqOrrelqiiRh7U/VdG/1WTY6MxCKI/keUjBTM=";
  };
}
