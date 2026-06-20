{ config, pkgs, lib, ... }:
{
  # Google Cloud SDK のセットアップ

  # PATHにgcloudを追加
  home.sessionPath = [
    "${config.home.homeDirectory}/google-cloud-sdk/bin"
  ];

  # インストールスクリプト
  home.activation.installGcloudSdk = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.gzip}/bin:${pkgs.python311}/bin:$PATH"
    export CLOUDSDK_PYTHON="${pkgs.python311}/bin/python3.11"
    GCLOUD_DIR="${config.home.homeDirectory}/google-cloud-sdk"

    if [ ! -f "$GCLOUD_DIR/bin/gcloud" ]; then
      rm -rf "$GCLOUD_DIR"
      echo "Installing Google Cloud SDK..."
      cd ${config.home.homeDirectory}
      ${pkgs.curl}/bin/curl -o /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
      ${pkgs.gnutar}/bin/tar -xzf /tmp/google-cloud-sdk.tar.gz -C ${config.home.homeDirectory}
      rm /tmp/google-cloud-sdk.tar.gz
      $GCLOUD_DIR/install.sh --quiet --usage-reporting false --path-update false --command-completion false
      echo "Google Cloud SDK installed successfully"
    else
      echo "Google Cloud SDK already exists at $GCLOUD_DIR"
    fi
  '';

  # Zsh統合
  # compinit を呼ぶ completion.zsh.inc が Zim の completion モジュールより
  # 先に走ると二重初期化で補完が壊れるため、mkAfter で initContent の最後
  # (Zim init.zsh の後) に回す。compdef 定義済みなら compinit はスキップされる。
  programs.zsh.initContent = lib.mkAfter ''
    # Google Cloud SDK
    export CLOUDSDK_PYTHON="${pkgs.python311}/bin/python3.11"
    if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
      source "$HOME/google-cloud-sdk/path.zsh.inc"
    fi
    if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
      source "$HOME/google-cloud-sdk/completion.zsh.inc"
    fi
  '';
}
