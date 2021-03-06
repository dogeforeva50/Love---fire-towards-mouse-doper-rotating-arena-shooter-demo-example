function love.conf( t )

	t.title = "LOVE - Per-Pixel Collision Demo"  -- The title of the window the game is in (string)
	t.author = "Kevin Harris of CodeSampler.com" -- The author of the game (string)

	t.version = 0.62            -- The LOVE version this game was made for (number)
	t.console = false           -- Attach a console (boolean, Windows only)

	t.window.fullscreen = false -- Enable fullscreen (boolean)
	t.window.vsync = true       -- Enable vertical sync (boolean)
	t.window.fsaa = 0           -- The number of FSAA-buffers (number)
	t.window.width = 800        -- The window width (number)
	t.window.height = 600       -- The window height (number)

	t.modules.joystick = false  -- Enable the joystick module (boolean)
	t.modules.audio = false     -- Enable the audio module (boolean)
	t.modules.keyboard = true   -- Enable the keyboard module (boolean)
	t.modules.event = true      -- Enable the event module (boolean)
	t.modules.image = true      -- Enable the image module (boolean)
	t.modules.graphics = true   -- Enable the graphics module (boolean)
	t.modules.timer = true      -- Enable the timer module (boolean)
	t.modules.mouse = true      -- Enable the mouse module (boolean)
	t.modules.sound = false     -- Enable the sound module (boolean)
	t.modules.physics = false   -- Enable the physics module (boolean)

end