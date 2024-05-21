{ buildPythonPackage, fetchPypi, ... }:
buildPythonPackage rec {
	pname = "kuzu";
	version = "0.4.1";
	format = "wheel";

	doCheck = false;
	src = fetchPypi {
		inherit pname version format;
		python = "cp311";
		dist = "cp311";
		abi = "cp311";
		platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
		sha256 = "sha256-rToMGPn2vCbk+EinLZ8yvYsHldVK8UcFFlss0Q9CgPs=";
	};
}
# { buildPythonPackage, pkgs, ... }:
# let
#		gnumake = pkgs.gnumake;
#		cmake = pkgs.cmake;
#		python = pkgs.python3;
#		fetchFromGitHub = pkgs.fetchFromGitHub;
# in buildPythonPackage rec {
#		pname = "kuzu";
#		version = "0.4.2";
#		format = "pyproject";
#
#		src = fetchFromGitHub {
#     owner = "kuzudb";
#     repo = "kuzu";
#     rev = "v${version}";
#     hash = "sha256-cGaAdSKz/wwc2+fvhZhE8Df9+U0Sm3Rq8fM/xRXSeDQ=";
#		};
#
#		phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
#
#		sourceRoot = "source/tools/python_api";
#
#		nativeBuildInputs = [
#			cmake
#			gnumake
#			(python.withPackages(pp: with pp; [
#				pybind11
#			]))
#		];
#
#   patchPhase = ''
#     substituteInPlace Makefile \
#       --replace "/bin/bash" "${pkgs.bash}/bin/bash"
#   '';
#
#		configurePhase = "";
#
#		buildPhase = ''
#			make build
#		'';
# }
