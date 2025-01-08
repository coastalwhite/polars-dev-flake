{ buildPythonPackage, pkgs, ... }:
buildPythonPackage rec {
  pname = "ruff";
  version = "0.8.1";
  pyproject = true;

  outputs = [
    "bin"
    "out"
  ];

  src = pkgs.fetchFromGitHub {
    owner = "astral-sh";
    repo = pname;
    rev = version;
    hash = "sha256-N3TplR+vPu2r56VP/vnOfkxN3Lh2o92kE2hFZKLXO04=";
  };

  nativeBuildInputs =
    [ pkgs.installShellFiles ]
    ++ (with pkgs.rustPlatform; [
      cargoSetupHook
      maturinBuildHook
      cargoCheckHook
    ]);

  buildInputs = with pkgs; [
    rust-jemalloc-sys
  ];

  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "lsp-types-0.95.1" = "sha256-8Oh299exWXVi6A39pALOISNfp8XBya8z+KT/Z7suRxQ=";
      "salsa-0.18.0" = "sha256-zUF2ZBorJzgo8O8ZEnFaitAvWXqNwtHSqx4JE8nByIg=";
    };
  };

  postInstall =
  ''
    mkdir -p $bin/bin
    mv $out/bin/ruff $bin/bin/
    rmdir $out/bin
  ''
  + pkgs.lib.optionalString (pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform) ''
    installShellCompletion --cmd ruff \
      --bash <($bin/bin/ruff generate-shell-completion bash) \
      --fish <($bin/bin/ruff generate-shell-completion fish) \
      --zsh <($bin/bin/ruff generate-shell-completion zsh)
  '';

  doCheck = false;
}
