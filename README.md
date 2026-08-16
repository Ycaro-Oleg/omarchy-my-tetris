# Omarchy Tetris

A small terminal Tetris for [Omarchy](https://omarchy.org/). It reads the theme you already have selected and paints the board, pieces, and menus with those colors. Switch theme, open the game again, and it follows.

## Install

```bash
omarchy plugin add git@github.com:Ycaro-Oleg/omarchy-my-tetris.git
omarchy plugin enable ycarooleg.tetris --section left
```

HTTPS works too:

```bash
omarchy plugin add https://github.com/Ycaro-Oleg/omarchy-my-tetris.git
```

That clones the repo into `~/.config/omarchy/plugins/ycarooleg.tetris/` and puts a Tetris icon on the bar. Click it, or run the game directly:

```bash
~/.config/omarchy/plugins/ycarooleg.tetris/omarchy-tetris
```

Optional desktop launcher (shows up in Super + Space):

```bash
cp ~/.config/omarchy/plugins/ycarooleg.tetris/Tetris.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

Remove it with `omarchy plugin remove ycarooleg.tetris`.

## Modes

| Mode | Goal |
|---|---|
| **Classic** | Play until the stack reaches the top. Score and level keep climbing. |
| **Sprint** | Clear 40 lines. Fastest time is the record. |
| **Ultra** | Two minutes. Highest score is the record. |

Scores are stored in `~/.local/share/omarchy-tetris/scores.json`.

## Controls

| Key | Action |
|---|---|
| ← → / a d | Move |
| ↑ / w / x | Rotate |
| z | Rotate the other way |
| ↓ / s | Soft drop |
| Space | Hard drop |
| c | Hold |
| p / Esc | Pause |
| r | Retry |
| q | Back to the menu, or quit from the menu |
| 1 2 3 | Pick a mode on the menu |

## How it works

The plugin is two parts:

1. **`BarWidget.qml`** — a bar icon. A click runs Omarchy's normal TUI launcher (`omarchy launch or focus tui`) so the game opens in your default terminal, or focuses it if it is already open.
2. **`omarchy-tetris`** — the game. One Python 3 file. It reads `~/.local/state/omarchy/current/theme/colors.toml` (the same file Omarchy writes when you change theme) and maps those colors onto the seven pieces, the well, and the text.

Gameplay is ordinary guideline Tetris: 7-bag randomizer, ghost piece, hold, next queue, SRS kicks, lock delay, combos, back-to-back Tetrises, and T-spins. Level speed follows the usual curve. Nothing talks to a server.

## Why this is safe

`omarchy plugin add` only clones the git repo. It does not run install scripts or ask for sudo.

The game itself is a Python script that uses the standard library only. It does not open the network, does not need extra packages, and does not write outside two places:

- reads the current theme colors from Omarchy's existing state directory
- writes high scores to `~/.local/share/omarchy-tetris/`

The bar widget only launches that script in a terminal. Plugins are disabled until you enable them, so you can read the files first. The whole game is in `omarchy-tetris` if you want to skim it.

## Theme

Colors come from the active Omarchy theme on every launch, and the file is checked again while the game is open. Custom themes work as long as they ship a `colors.toml` with the usual keys (`background`, `foreground`, `cyan`, `yellow`, and so on). If that file is missing, the game falls back to a built-in dark palette.

A floating window the size of other Omarchy TUIs is nicer than a huge tiled terminal. After install you can add this to `~/.config/hypr/hyprland.lua`:

```lua
o.window("org.omarchy.tetris", { tag = "+floating-window" })
```
