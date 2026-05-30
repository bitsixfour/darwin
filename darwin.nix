{ pkgs, username, ... }:

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
    aerospace
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
