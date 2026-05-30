{ pkgs, username, ... }:

{
  imports = [
    ./nvim.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.05";

  stylix.enable = true;
  stylix.base16Scheme = {
    scheme = "coffee";
    base00 = "181614";
    base01 = "2e2c2a";
    base02 = "484644";
    base03 = "6e6c69";
    base04 = "898785";
    base05 = "c4c2bf";
    base06 = "d4d2cf";
    base07 = "ebe9e5";
    base08 = "9a5a52";
    base09 = "9e8060";
    base0A = "a59772";
    base0B = "7a8a64";
    base0C = "688080";
    base0D = "6878a0";
    base0E = "866878";
    base0F = "594c44";
  };
  stylix.targets.kitty.enable = false;

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
      rebuild = "darwin-rebuild switch --flake ~/git/darwin-config#will-mac";
    };
  };

  home.file.".config/skhd/README.md".text = ''
    skhd mirrors the old labwc workflow as closely as macOS allows.

    W/Super from labwc is mapped to cmd.
    Alt bindings are mapped to alt.
    App focus-or-open bindings use `open -a` because macOS owns app activation.
    Window movement/workspace operations are delegated to AeroSpace.
  '';
}
