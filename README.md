# Tetris

A small terminal Tetris for [Omarchy](https://omarchy.org/). The board follows the theme you already have selected. Pieces are drawn as little squares. A landing sound plays when a piece first sits on the stack, a chime plays when lines clear, and one of three Korobeiniki arrangements loops underneath. Game sounds and music have separate volume bars. `m` mutes only the music.

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
| t | Next music theme |
| m | Mute music only |
| [ ] | Game volume |
| - = | Music volume |
| p / Esc | Pause |
| r | Retry |
| q | Menu, or quit from the menu |

Landing voices are **thock**, **click**, **chip**, and **hush**. Line clears use a chime that rises with 2–7 lines. Music themes are **piano**, **strings**, and **music box**. Mute music from the panel or with `m`; landing and score sounds stay on. Game volume and music volume are separate. Settings live in `~/.local/state/omarchy/tetris.json`. The board, with date and time, lives in `~/.local/share/omarchy-tetris/scores.json`. First place sits in an ASCII fire box.

## Music

The three themes are *Tetris Theme – Korobeiniki – Rearranged* by [Gregor Quendel](https://www.gregorquendel.com), from [ClassicalS.de](https://www.classicals.de/tetris-theme). © 2024 Gregor Quendel. Licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

That license lets this free plugin share and loop the recordings if the credit stays with them. It does **not** allow selling the plugin or putting the tracks in a paid product. For that, buy a [commercial license](https://www.classicals.de/). The plugin uses one 8-bar phrase from each recording (12.8s), spliced with a 45ms equal-power join; see `sounds/themes/NOTICE.md`.

## Configure

```sh
omarchy bar move terminal.tetris --section left
```

## Why this is safe

`omarchy plugin add` only clones the git repo. It does not run install scripts or request elevated privileges.

The game is Python 3 and the standard library. It does not open the network. It reads the current theme colors, writes scores and the sound setting under your home directory, and plays short local WAV files with `pw-play`. The bar widget launches that script in a terminal. Plugins stay off until you enable them.

## Remove

```sh
omarchy plugin remove terminal.tetris
```
