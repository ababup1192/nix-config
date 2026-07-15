{ pkgs, config, ... }:
{
  # --- Imports ---
  imports = [
    ./gcloud.nix
  ];
  # --- 基本設定 ---
  home.username = "abab";
  home.homeDirectory = "/Users/abab";
  home.stateVersion = "23.11";

  # --- インストールするパッケージ ---
  home.packages = with pkgs; [
    nixfmt

    zoxide
    bat
    eza
    git
    jujutsu
    gh
    neovim
    devbox
    claude-code
    cmux
    herdr
    (import ./cmux-git-diff.nix { inherit pkgs; })
    gzip

    #Programming Languages(あんまり入れたくないよ)
    go

    rtk
    protobuf
    zimfw
    jankyborders
    (pkgs.writeShellScriptBin "difit" ''
      export PATH="${pkgs.git}/bin:${pkgs.nodejs}/bin:$PATH"
      ${pkgs.nodejs}/bin/npx -y difit "$@"
    '')
    (pkgs.writeShellScriptBin "feed-curator" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      if ! command -v "$HOME/.npm-global/bin/feed-curator" &> /dev/null; then
        ${pkgs.nodejs}/bin/npm install -g feed-curator
      fi
      "$HOME/.npm-global/bin/feed-curator" "$@"
    '')
  ];

  xdg.configFile."zsh/.zimrc".text = ''
    # 補完系を先に読み込み、completion モジュールで compinit を実行する
    zmodule zsh-users/zsh-completions
    zmodule completion

    # ZLE ウィジェットをラップするため、これらは必ず最後に読み込む
    zmodule zsh-users/zsh-syntax-highlighting
    zmodule zsh-users/zsh-autosuggestions
  '';

  xdg.configFile."zsh/devbox_auto_shell.zsh".text = ''
    #!/usr/bin/env zsh
    # Devbox automatic shell entry/exit hook
    # Automatically enters devbox shell when cd into a devbox project,
    # and exits when leaving the project directory.

    # precmd hook: Check if we returned from devbox shell and need to cd
    function devbox_check_target_dir() {
      local target_dir_file="/tmp/devbox_target_dir_$$"

      # Skip if we're inside devbox shell
      if [[ -n "$DEVBOX_PROJECT_ROOT" ]]; then
        return
      fi

      # If target directory file exists, cd to that directory
      if [[ -f "$target_dir_file" ]]; then
        local target_dir=$(cat "$target_dir_file")
        rm -f "$target_dir_file"
        if [[ -d "$target_dir" ]] && [[ "$target_dir" != "$PWD" ]]; then
          print -P "%F{blue}📦 Moving to: $target_dir%f"
          cd "$target_dir"
        fi
      fi
    }

    function devbox_auto_shell() {
      local current_dir="$PWD"
      local has_devbox_json=false

      # Check if current directory has devbox.json
      if [[ -f "$current_dir/devbox.json" ]]; then
        has_devbox_json=true
      fi

      # Case 1: We're in a devbox shell
      if [[ -n "$DEVBOX_PROJECT_ROOT" ]]; then
        # Check if we've left the devbox project directory
        if [[ "$current_dir" != "$DEVBOX_PROJECT_ROOT"* ]]; then
          # Save target directory to temp file (use parent PID)
          local target_dir_file="/tmp/devbox_target_dir_$DEVBOX_PARENT_PID"
          echo "$current_dir" > "$target_dir_file"
          print -P "%F{yellow}📦 Leaving devbox project. Exiting shell...%f"
          exit
        fi
      # Case 2: We're not in a devbox shell
      elif [[ "$has_devbox_json" == true ]] && [[ -z "$DEVBOX_SHELL_ENABLED" ]]; then
        # Save parent PID for later use
        export DEVBOX_PARENT_PID=$$
        print -P "%F{green}📦 Devbox detected. Entering shell...%f"
        devbox shell
      fi
    }

    # Register hooks
    precmd_functions+=(devbox_check_target_dir)
    chpwd_functions+=(devbox_auto_shell)
  '';

  home.sessionPath = [
    "${config.home.homeDirectory}/.antigravity/antigravity/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;

    # compinit は zim の completion モジュール (.zimrc) で実行するため、
    # home-manager 側の compinit 呼び出しを無効化して二重初期化を防ぐ
    enableCompletion = false;

    # エイリアス設定
    shellAliases = {
      rm = "rm -i";
      grep = "grep --color=auto";
      cat = "bat";
      vi = "nvim";
      vim = "nvim";

      # nix設定
      nix-switch = "sudo -H env NIX_CONFIG=\"access-tokens = github.com=$(gh auth token)\" nix run nix-darwin -- switch --flake ~/.config/nix-config#abab";
      nix-cd = "cd ~/.config/nix-config";
      nix-update = "sudo -H env NIX_CONFIG=\"access-tokens = github.com=$(gh auth token)\" nix flake update";
    };

    initContent = ''
      # Source devbox auto shell hook
      source ~/.config/zsh/devbox_auto_shell.zsh

      ls() {
        ${pkgs.eza}/bin/eza -F --icons "$@"
      }

      # Zim のインストール先
      export ZIM_HOME=''${XDG_CACHE_HOME:-''${HOME}/.cache}/zim
      export ZIM_CONFIG_FILE=''${HOME}/.config/zsh/.zimrc
      local ZIM_FW_SCRIPT="${pkgs.zimfw}/zimfw.zsh"

      zimfw() { source "''${ZIM_FW_SCRIPT}" "$@" }

      # .zimrc は nix store 上の symlink で mtime が 1970 固定のため、
      # -nt 比較では再生成が走らない。symlink の実体パス(内容が変わると
      # store hash も変わる)をセンチネルに記録し、変化時のみ再生成する。
      local _zimrc_target="$(readlink -f ''${ZIM_CONFIG_FILE})"
      local _zim_sentinel="''${ZIM_HOME}/.zimrc-source"
      if [[ ! -e ''${ZIM_HOME}/init.zsh \
            || ! -e ''${_zim_sentinel} \
            || "$(cat ''${_zim_sentinel} 2>/dev/null)" != "''${_zimrc_target}" ]]; then
        zsh "''${ZIM_FW_SCRIPT}" init -q
        print -r -- "''${_zimrc_target}" > ''${_zim_sentinel}
      fi

      source ''${ZIM_HOME}/init.zsh

      # Ghostty シェル統合 (home-manager 既定の代替・堅牢版)
      # ファイルが実在するときだけ source し、変数が壊れていてもエラーにしない
      if [[ -n "$GHOSTTY_RESOURCES_DIR" \
            && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
      fi

      # 新しいシェル起動時にも devbox 自動入りをチェック
      # (ghostty の cmd+d で分割した新ペインなど、chpwd が発火しないケース用)
      devbox_auto_shell
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Ghosttyなどの端末でGitの変更行数(+/-)を表示するための設定
      git_metrics = {
        disabled = false;
      };
      # クラウド情報の非表示
      gcloud = {
        disabled = true;
      };
      # ディレクトリパスの表示
      directory = {
        truncate_to_repo = false;
        truncation_length = 0; # 0 means no truncation
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "ababup1192";
        email = "ababup1192@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      core = {
        editor = "nvim";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    # zsh 統合は home-manager 既定だと存在チェックなしで source するため、
    # GHOSTTY_RESOURCES_DIR が壊れた値のとき(devbox 自動シェル起動時など)に
    # エラーを出す。無効化し、initContent 側で -r チェック付きの安全版を読み込む。
    enableZshIntegration = false;
    settings = {
      # Theme & Font
      theme = "Catppuccin Mocha";
      font-family = "JetBrains Mono";
      # font-feature = [
      #   "calt"
      #   "liga"
      #   "dlig"
      # ];

      # Settings from Image
      font-size = 13;
      font-thicken = true;
      font-thicken-strength = 1;
      alpha-blending = "linear";
      adjust-cell-width = -1;
      adjust-cell-height = 2;
      macos-titlebar-style = "hidden";
      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-balance = true;
      background-opacity = 0.8;
      background-blur-radius = 20;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  launchd.agents.borders = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "active_color=0xE025A64A"
        "inactive_color=0x262F2F2F"
        "width=12.0"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  # home-manager 自体を有効化
  programs.home-manager.enable = true;
}
