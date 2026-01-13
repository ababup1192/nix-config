{ pkgs, config, ... }:
{
  # --- 基本設定 ---
  home.username = "abab";
  home.homeDirectory = "/Users/abab";
  home.stateVersion = "23.11";

  # --- インストールするパッケージ ---
  home.packages = with pkgs; [
    nixfmt

    bat
    eza
    git
    neovim
    devbox

    #Programming Languages
    go

    protobuf
    zimfw
  ];

  xdg.configFile."zsh/.zimrc".text = ''
    zmodule zsh-users/zsh-syntax-highlighting
    zmodule zsh-users/zsh-completions
    zmodule zsh-users/zsh-autosuggestions
  '';

  home.sessionPath = [
    "${config.home.homeDirectory}/.antigravity/antigravity/bin"
  ];

  programs.zsh = {
    enable = true;

    # エイリアス設定
    shellAliases = {
      ls = "eza -F --icons";
      rm = "rm -i";
      grep = "grep --color=auto";
      cat = "bat";
      vi = "nvim";
      vim = "nvim";

      # nix設定
      nix-switch = "sudo -H nix run nix-darwin -- switch --flake ~/.config/nix-config#abab";
      nix-cd = "cd ~/.config/nix-config";
      nix-update = "sudo -H nix flake update";
    };

    initContent = ''
      # Zim のインストール先
      export ZIM_HOME=''${XDG_CACHE_HOME:-''${HOME}/.cache}/zim
      export ZIM_CONFIG_FILE=''${HOME}/.config/zsh/.zimrc
      local ZIM_FW_SCRIPT="${pkgs.zimfw}/zimfw.zsh"
      
      zimfw() { source "''${ZIM_FW_SCRIPT}" "$@" }

      if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZIM_CONFIG_FILE} ]]; then
        zsh "''${ZIM_FW_SCRIPT}" init -q
      fi

      source ''${ZIM_HOME}/init.zsh
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
    settings = {
      # Theme & Font
      theme = "Catppuccin Mocha";
      font-family = "JetBrains Mono";
      font-feature = [
        "calt"
        "liga"
        "dlig"
      ];

      # Settings from Image
      font-size = 14;
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

  # home-manager 自体を有効化
  programs.home-manager.enable = true;
}
