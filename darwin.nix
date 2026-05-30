{ pkgs, lib, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "darwin";
  time.timeZone = "America/Chicago";

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    cargo
    feishin
    clang-tools
    cmake
    fd
    fish
    fzf
    gcc
    git
    git-credential-manager
    helix
    jq
    kitty
    lua-language-server
    neovim
    nil
    nixd
    opencode
    pkg-config
    ripgrep
    rust-analyzer
    sioyek
    rustc
    skhd
    tinymist
    typst
    wget
    zed-editor
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    iosevka-bin
    liberation_ttf
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "none";
      upgrade = true;
    };

    taps = [
      "nikitabobko/tap"
    ];

    brews = [
      "helix"
      "mas"
      "switchaudio-osx"
    ];

    casks = [
      "aerospace"
      "desktoppr"
      "helium-browser"
      "firefox"
      "gimp"
      "kicad"
      "kitty"
      "obsidian"
      "prismlauncher"
      "qbittorrent"
      "roblox"
      "raycast"
      "vesktop"
      "zed"
    ];
  };

  services.tailscale = {
    enable = true;
  };

  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./cfg/skhd/skhdrc;
  };

  environment.systemPath = lib.mkAfter [ "/Applications/AeroSpace.app/Contents/MacOS" ];

  system.activationScripts.aerospaceTCC.text = ''
    TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
    BUNDLE="com.nikitabobko.AeroSpace"
    APP="/Applications/AeroSpace.app"

    if [ -f "$TCC_DB" ] && [ -d "$APP" ]; then
      /usr/bin/sqlite3 "$TCC_DB" "
        DELETE FROM access WHERE client = '$BUNDLE' AND service = 'kTCCServiceAccessibility';
        INSERT OR IGNORE INTO access
          (service, client, client_type, auth_value, auth_reason, csreq, policy_id,
           indirect_object_identifier_type, indirect_object_identifier, flags, last_modified)
        VALUES
          ('kTCCServiceAccessibility', '$BUNDLE', 0, 1, 4,
           NULL, NULL, 0, 'UNUSED', 0, 0);
      " 2>/dev/null || true
    fi
  '';

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 30;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
      tilesize = 36;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = username;
  system.stateVersion = 5;
}
