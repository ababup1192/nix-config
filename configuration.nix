{ pkgs, ... }:
{
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
  # compinit は zimfw の completion モジュールが実行するため、システム側
  # (/etc/zshrc) の global compinit を無効化して二重初期化を防ぐ。
  # これをしないと devbox shell など /etc/zshrc が再実行される場面で
  # zimfw より先に compinit が走り「completion was already initialized」
  # 警告が出て補完が壊れる。fpath 設定のため enableCompletion は true のまま。
  programs.zsh.enableGlobalCompInit = false;

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
      "discord"
      "ghostty"
      "bettertouchtool"
      "heptabase"
      "datagrip"
      "docker-desktop"
      "ticktick"
      "nikitabobko/tap/aerospace"
      "steam"
      "obsidian"
      "visual-studio-code"
    ];
  };
}
