# nix-darwin config

Standalone macOS/Darwin version of the `/etc/nixos` workflow.

## What this keeps

- Same `will` user assumption.
- Same Coffee/Stylix palette.
- Same Kitty tab bindings.
- Same Neovim config copied into `cfg/nvim`.
- Same core development tools and language servers.
- Labwc-style app/window keybindings translated to `skhd` + AeroSpace.

## What changes on macOS

- `labwc`, `waybar`, `wofi`, `pipewire`, `networkmanager`, and Linux portals are not used.
- AeroSpace replaces labwc for workspace/window management.
- skhd replaces XML window-manager keybindings.
- Homebrew casks install GUI apps that are better handled as macOS apps.

## First install

On a Mac with Nix flakes enabled:

```sh
cd ~/git/darwin-config
nix run nix-darwin -- switch --flake .#will-mac
```

After the first switch, use:

```sh
darwin-rebuild switch --flake ~/git/darwin-config#will-mac
```

## Notes

- This targets Apple Silicon: `aarch64-darwin`.
- If you use Intel, change `system = "x86_64-darwin"` in `flake.nix`.
- The `cmd - space` binding opens Raycast as the practical wofi replacement.
- macOS may reserve some global shortcuts, especially `cmd-tab`; if a binding is not intercepted, change that one line in `cfg/skhd/skhdrc`.
- Kitty uses `cfg/kitty/theme.conf` directly instead of Stylix so the terminal theme is stable and custom.

## AeroSpace and skhd

`AeroSpace` is the macOS window manager layer. It gives macOS real keyboard-driven workspaces, directional focus, moving windows between workspaces, resizing, and tiling behavior. In this config, `cfg/aerospace/aerospace.toml` keeps the layout simple: two main workspaces, no gaps, tiled containers, and app placement rules.

`skhd` is the hotkey daemon. It listens for keybindings and runs commands. Think of it as the Darwin replacement for the keybind section in `labwc/rc.xml`. The file `cfg/skhd/skhdrc` maps the old Linux workflow to macOS: `cmd-h/l` changes workspaces, `cmd-shift-h/l` moves windows between workspaces, `cmd-return` opens Kitty, and app binds like `cmd-4` open Obsidian.

So the split is: `skhd` catches the keys, then `AeroSpace` performs the window/workspace action.

If you meant `sxhkd`: that is the Linux/X11 hotkey daemon. On macOS the equivalent tool is `skhd`, so this config uses `skhd`.

## Neovim Theme

Neovim uses a custom Modus-inspired dark palette in `cfg/nvim/colors/onedark.lua`. The filename is kept because `init.lua` already sources it, but the palette is no longer One Dark. It is intentionally more like the readable color schemes long-time Emacs users tend to prefer: high contrast, muted background, clear diagnostics, and restrained syntax colors.
