{ pkgs, ... }: {
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = false; # Default is false, explicit check
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129; # Caps Lock
        HIDKeyboardModifierMappingDst = 30064771303; # Command (Right GUI/GUI) or Left GUI (30064771299)
        # Using specific ID for Command:
        # Src: 30064771129 (Caps Lock) -> Dst: 30064771299 (Left Command) - Actually 30064771303 is commonly Right GUI, 30064771299 is Left GUI. 
        # Better use 30064771299 for Left Command.
      }
    ];
  };

  system.defaults = {
    dock = {
      autohide = true;
      magnification = true;
      largesize = 93;
      tilesize = 68;
      minimize-to-application = false;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      
      # Desktop icons
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    trackpad = {
      Clicking = true;  # Enable tap to click
      TrackpadThreeFingerDrag = true; # (Optional) Three finger drag is popular
    };

    NSGlobalDomain = {
      # Appearance
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      "com.apple.keyboard.fnState" = true;
      
      # Trackpad settings via NSGlobalDomain
      "com.apple.trackpad.scaling" = 2.0;
      "com.apple.mouse.tapBehavior" = 1; # Enable tap to click at global level

      # Typography / Text
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
  };
}
