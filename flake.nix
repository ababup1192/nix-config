{
  description = "Nix Darwin and Home Manager Flake";

  inputs = {
    # パッケージのソース
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    # nix-darwin のソース
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager のソース
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager }: {
    # "HOSTNAME" は自分の Mac のホスト名 (hostname -s) に書き換えてください
    darwinConfigurations.abab = darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Intel Mac の場合は "x86_64-darwin"
      modules = [
        ./configuration.nix  # システム設定（後で作ります）
        
        # home-manager を nix-darwin のモジュールとして組み込む
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # "YOUR_USERNAME" は自分のユーザー名に書き換えてください
          home-manager.users.abab = {
              imports = [ ./home.nix ];
          };
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
