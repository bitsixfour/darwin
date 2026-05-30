{ pkgs, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "will-mac";
  time.timeZone = "America/Chicago";

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    aerospace
    bat
    cargo
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
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "mas"
      "switchaudio-osx"
    ];

    casks = [
      "aerospace"
      "firefox"
      "gimp"
      "kicad"
      "kitty"
      "obsidian"
      "prismlauncher"
      "qbittorrent"
      "raycast"
      "strawberry"
      "vesktop"
      "zed"
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./cfg/skhd/skhdrc;
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
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
      TrackpadThreeFingerDrag = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = username;
  system.stateVersion = 5;
}
