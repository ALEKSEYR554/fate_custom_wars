# 2D Dice in Godot

The current version of this project is made in and for [Godot](https://godotengine.org) ``v4.0.2.stable.official [7a0977ce2]``.

A Dice that can be used in Godot projects.
The intended use is Tabletop-like games.

[▶️ Watch Video Demonstration](.readme-assets/demo.webm)

## How to fix low-quality graphics

To make this project more easy to work with (especially for beginners), i decided to make the dice's visuals from textures instead of shaders.
This means that the Exported Raster Images from the SVG Vector Images look good only in certain resolutions.

If the textures appear low-quality, re-import them with a different SVG Scale.
Then set the same number as the 'Texture Scale' in the 'Dice' scene's HDSprite nodes to make sure that the dice stays the original size.

For example, in the Demo Video above, this scale is set to 8.

## Features

- Smooth Animation when rolling the dice
- - To simplify the code,
	the animation is made in a way where only 1 symbol has to be displayed on the dice at any time.
	This way, i never have to store the old symbol (from before finished re-rolling) in a separate variable,
	and i can use 1 HDSprite node less
- - When rolling, the symbol is picked from a Spritesheet
- - - The position of the symbol in the spritesheet corresponds directly to how high the number is 
- - - Symbols for the numbers 0 to 9 (but only 1 to 6 are used by Default).
	  Change ``randi_range(1, 6)`` in the 'Dice' scene's Root Node's script to ``randi_range(0, 9)``
	  to roll from 0 to 9 instead of 1 to 6.
- - Animated in 30 frames per second (a common target refresh rate for games)
	by setting the animation's 'Step' value to _1.0/30_
- ``return``s the rolled number
- - by calling ``get_rolled_number()`` in the 'Dice' scene's Root Node's script
- - when calling ``roll()``.
	This can be useful e.g. for moving the player at the same time as rolling the dice:
	``position.x += $Dice.roll() * 64``
- Emits a signal ('on_rolled_dice') when rolling the dice.
  This can be useful to trigger outside code (e.g. player movement code) by rolling the dice.
- The action 'dice_roll' in the Input Map, so that you can roll the dice by pressing a key.
