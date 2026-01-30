{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  iconv,
  darwin,
  makeBinaryWrapper,
  github-cli,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "octorus";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "ushironoko";
    repo = "octorus";
    rev = "v${version}";
    sha256 = "1hjc2jb0qsdyhnp6m1z528837ipjrfp50y64g9c61fs4gy19zhr3";
  };

  cargoHash = "sha256-bmYzed69Q8Hjg8GKvzgPdAgVOk2AJbjT9WTm+zaGIZw=";

  doCheck = false;

  nativeBuildInputs = [ makeBinaryWrapper ];

  buildInputs = lib.optionals stdenv.isDarwin [
    iconv
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  postInstall = ''
    wrapProgram $out/bin/or \
      --prefix PATH : ${
        lib.makeBinPath [
          github-cli
          git
        ]
      }
  '';

  meta = with lib; {
    description = "TUI PR review tool for GitHub";
    homepage = "https://github.com/ushironoko/octorus";
    license = licenses.mit;
    mainProgram = "or";
  };
}
