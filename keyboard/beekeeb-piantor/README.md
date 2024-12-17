# Piantor Pro 42 Keyboard Configuration

A split keyboard, 3x6 column staggered keys + 3 thumb keys.

## Setup

The main in this setup has been to facilitate transition and adoption of an alternate layout while making the most of modern techniques (layering, home row mods, tap dancing, etc.). This has resulted in overall design choices such as:

- Maintaining QWERTY layout for letter characters.
- Maintaining the number row and their respective symbols behind layers 1 and 2.
- Maximizing the use of thumb keys for surrounding keys and access to layers.
- Implementing home row mods.
- Minimizing or even discarding altogether keys in side corners which would normally be reached by moving/stretching the pinky.
- Facilitating one-handed access for when combinations of keyboard + cursor work is required. This includes:
  - Mirroring certain keys and layers so they're accessible on both sides.
  - Providing alternative access to certain keys on the opposite side.

The details below reflect the last version of the setup.

### Constants

- Thumb keys will function as Tap / Hold keys and will remain fairly identical throughout the layers.
  - Left Board
    - Esc / Hyper key
    - Tab / Layer 1
    - Space / Layer 2
  - Right Board
    - Enter / Layer 2
    - Delete / Layer 1
    - Backspace / Hyper
- Corner keys (top and bottom left of left pad; and top and bottom right of right pad) will remain mostly blank to discourage moving/stretching of pinky fingers.

### Layer 0: Base

- QWERTY Layout - Mostly untouched except for the most left column (blank, tilde, blank) and the two most right columns (blank, quotation mark, blank).

### Layer 1: Numbers and Arrows

- First row: Number row
- Second row: Arrow keys in VIM layout. Mirrored for left hand as well.
- Third row: Mirrors the thumb keys to make them accessible to the other hand.
- Holding the left L2 thumb key momentarily activates the num pad layer (3).

### Layer 2: Media Functions and Symbols

- First row across: Symbols row (Shifted numbers)
- Remaining left pad keys are used for media
- Remaining right pad keys are used for symbols. These try to find certain logic in how they're moved from their original QWERTY position but this is very subjective.
- Holding the left L1 thumb key momentarily activates the num pad layer (3).

### Layer 3: Num Pad

- Meant to act as a layer to be activated (not great for momentary usage).
- Only the right pad is used for this.
- Left pad to still find a use. Media tool (drawing, video, audio) companion?

### Layer 5/6: Gaming

- Removes Home Row Mods and places them in side and bottom keys.
- Changes h, j, k, l to left, top, bottom, right. (Platformers)

### Layer 10/11/12: Alternative Layout

- Aims to be the "next level", fully customized setup to replace 0/1/2.
- Colemak/Workman inspired layout.
- Aims to push letters least used away the core and balance out symbol keys.
- Layer 11 now combines numbers and symbols.
- Layer 12 now combines media, arrow, and mirrored thumb key alternatives.

## Changelog

These are Vial backup files of the keyboard configuration.

- v1 - Initial configuration. Very close to the default Piantor setup.
- v2 - Added a few more layers and macros, testing custom tap dance functions.
- v3 - Reverts back to Mod-Tap due to better functioning and easier management. Rearranges keys and adds All Mod combos.
- v4 - Changes to home row mods setup. Changes media to layer 3 and makes available to both hands. Cleans up old configuration.
- v5 - Adds alternative keyboard layout (layer 10/11/12). Very experimental, barely used.
- v6 - Moves numpad to layer 3, adds a gaming layout to layer 4, mirrors arrow keys on left side of keyboard (layer 1). Moves toggle keys. Copies some of the changes to experimental layers.
- v7 - Moves gaming layer to 5/6 and changes modifier keys based on what I'm already used to. Adjusts other layer keys based on usage.
