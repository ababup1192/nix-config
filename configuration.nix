{ pkgs, ... }: {
  imports = [
    ./font.nix
    ./macos-settings.nix
  ];

  nix.enable = false;
  users.users.abab = {
    name = "abab";
    home = "/Users/abab";
  };

  # Flakesを有効にするための設定
  nix.settings.experimental-features = "nix-command flakes";

  # システム全体で使いたいパッケージ
  environment.systemPackages = [ pkgs.git ];

  # Zshをデフォルトシェルにする（nix-darwinで必須の設定）
  programs.zsh.enable = true;

  # 初回インストール時のバージョン（基本変えない）
  system.stateVersion = 4;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.primaryUser = "abab";
  homebrew = {
    enable = true;
    onActivation.cleanup = "none"; # 勝手にアンインストールしない設定

    casks = [
      # ブラウザ
      "google-chrome"
      "sigmaos"
      "zen"

      "antigravity"
      "figma"
      "raycast"
      "cleanshot"
      "slack"
      "ghostty"
      "azooKey"
      "bettertouchtool"
      "heptabase"
      "datagrip"
      "docker-desktop"
      "ticktick"
      "nikitabobko/tap/aerospace"
    ];
  };
}
