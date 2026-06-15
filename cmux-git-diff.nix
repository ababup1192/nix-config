# cmux-git-diff: git diff をブラウザにライブ表示する Go 製 CLI
# (nixpkgs 未収録のため buildGoModule で GitHub から直接ビルド)
{ pkgs }:
pkgs.buildGoModule {
  pname = "cmux-git-diff";
  version = "0-unstable-2026-06-15";

  src = pkgs.fetchFromGitHub {
    owner = "sinozu";
    repo = "cmux-git-diff";
    rev = "66a8db3673da8ba49cc478c8cb6dd7f8512f74b5";
    hash = "sha256-+QYQxGZJPO88p6Ubjro7Obl9WAV64BFWHwHoG+ZS+v8=";
  };

  vendorHash = "sha256-feaUOP+joGnpjqniCtstRGHwcMyGNZ95PwEXWzjmjIk=";

  meta = {
    description = "Live git diff viewer in the browser, integrates with cmux";
    homepage = "https://github.com/sinozu/cmux-git-diff";
    mainProgram = "cmux-git-diff";
  };
}
