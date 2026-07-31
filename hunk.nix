# hunk: レビュー特化のターミナル diff ビューア (https://www.hunk.dev/)
# (nixpkgs 未収録・flake 提供なしのため、GitHub リリースのバイナリを取得)
{ pkgs }:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "hunk";
  version = "0.17.0";

  src = pkgs.fetchurl {
    url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
    hash = "sha256-cAIhZppRt4yDWYW0nKZ+Wku6r9tDSmygP50mL3qCaT4=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # Homebrew formula と同じ配置: バイナリと skills を libexec に置き、
  # bin/hunk はラッパーにする (skills をバイナリ隣接で参照するため)
  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec
    cp hunk $out/libexec/hunk
    cp -r skills $out/libexec/skills
    chmod 755 $out/libexec/hunk
    makeWrapper $out/libexec/hunk $out/bin/hunk \
      --set HUNK_INSTALL_SOURCE nix
    runHook postInstall
  '';

  meta = {
    description = "Review-first terminal diff viewer for agent-authored changesets";
    homepage = "https://www.hunk.dev/";
    mainProgram = "hunk";
    platforms = [ "aarch64-darwin" ];
  };
}
