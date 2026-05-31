{ pkgs, lib, username, ... }:

{
  imports = [
    ./nvim.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.05";

  stylix.enable = true;
  stylix.base16Scheme = {
    scheme = "muted";
    base00 = "141312";
    base01 = "211f1e";
    base02 = "333130";
    base03 = "494746";
    base04 = "696765";
    base05 = "b3b1af";
    base06 = "ceccca";
    base07 = "e6e4e2";
    base08 = "78605c";
    base09 = "786c5c";
    base0A = "6c785c";
    base0B = "5c7860";
    base0C = "5c6e78";
    base0D = "5c6078";
    base0E = "6e5c78";
    base0F = "5c5c5c";
  };
  stylix.targets = {
    kitty.enable = false;
    bat.enable = true;
    fish.enable = true;
    fzf.enable = true;
    neovim.enable = true;
    zellij.enable = true;
  };
  home.activation.setWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/${username}/main.jpg"'
  '';

  home.packages = with pkgs; [
    fastfetch
    fd
    ripgrep
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "osxkeychain";
    };
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./cfg/kitty/theme.conf;
    keybindings = {
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";
    };
  };

  home.file.".aerospace.toml".source = ./cfg/aerospace/aerospace.toml;
  home.file.".config/ghostty/config".source = ./cfg/ghostty/config;
  home.file.".config/skhd/skhdrc".source = ./cfg/skhd/skhdrc;
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "type": "small" },
      "display": { "separator": "  " },
      "modules": ["title", "os", "host", "kernel", "uptime", "packages", "shell", "terminal", "cpu", "gpu", "memory"]
    }
  '';

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx EDITOR nvim
      set -gx VISUAL nvim
    '';
    shellAliases = {
      v = "nvim";
      lg = "lazygit";
      rebuild = "darwin-rebuild switch --flake /etc/nixos#darwin";
      nixclean = "nix-collect-garbage -d && nix store optimise";
    };
  };

  services.syncthing.enable = true;

  home.file.".config/skhd/README.md".text = ''
    skhd mirrors the old labwc workflow as closely as macOS allows.

    W/Super from labwc is mapped to cmd.
    Alt bindings are mapped to alt.
    App focus-or-open bindings use `open -a` because macOS owns app activation.
    Window tiling and movement are delegated to AeroSpace.
  '';
}
