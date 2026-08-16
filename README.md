# Tetris

A small terminal Tetris for [Omarchy](https://omarchy.org/). The board follows the theme you already have selected. Pieces are drawn as little squares. A landing sound plays when a piece first sits on the stack, a chime plays when lines clear, and a quiet 8-bit loop sits under the game. All of that follows the volume bar.

The game opens as a normal tiled window, so it joins whatever layout you are already using. Move and resize it with your usual keys.

## Install

```sh
omarchy plugin add https://github.com/Ycaro-Oleg/omarchy-my-tetris.git --enable
```

That clones the repo into `~/.config/omarchy/plugins/terminal.tetris/`. Click the bar icon to open the panel, then Play. Or run the game directly:

```sh
~/.config/omarchy/plugins/terminal.tetris/omarchy-tetris
```

## Usage

Left click the bar icon for the panel. Right click starts a game. Escape closes the panel. `omarchy-shell shell summon terminal.tetris` opens it the same way.

| Mode | Goal |
|---|---|
| **Classic** | Play until the stack reaches the top |
| **Sprint** | Clear 40 lines. Fastest time wins |
| **Ultra** | Two minutes. Highest score wins |

| Key | Action |
|---|---|
| ← → | Move |
| ↑ / x | Rotate |
| z | Rotate the other way |
| ↓ | Soft drop |
| Space | Hard drop |
| c | Hold |
| n | Next landing sound |
| [ ] | Volume |
| p / Esc | Pause |
| r | Retry |
| q | Menu, or quit from the menu |

Landing voices are **thock**, **click**, **chip**, and **hush**. Line clears use one shared chime. Quiet 8-bit music loops in the background. Volume and voice are shared between the panel and the game in `~/.local/state/omarchy/tetris.json`. The board, with date and time, lives in `~/.local/share/omarchy-tetris/scores.json`. First place sits in an ASCII fire box.

## Configure

```sh
omarchy bar move terminal.tetris --section left
```

## Why this is safe

`omarchy plugin add` only clones the git repo. It does not run install scripts or ask for sudo.

The game is Python 3 and the standard library. It does not open the network. It reads the current theme colors, writes scores and the sound setting under your home directory, and plays short local WAV files with `pw-play`. The bar widget launches that script in a terminal. Plugins stay off until you enable them.

## Remove

```sh
omarchy plugin remove terminal.tetris
```
