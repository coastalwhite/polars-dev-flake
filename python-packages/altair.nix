{ buildpythonpackage, fetchpypi, ... }:
buildpythonpackage rec {
	pname = "altair";
	version = "5.4.1";
	format = "wheel";

	docheck = false;
	src = fetchpypi {
		inherit pname version format;
		python = "py3";
    dist = "py3";
		abi = "none";
		platform = "any";
		sha256 = "sha256-d7ewucl6vp0imr+2/ny1gudwn4oezdu9khjdbjvgsu8=";
	};
}
