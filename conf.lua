function love.conf(t)
	t.window.fullscreen = love._os == "Android"
	t.window.width = 1280
	t.window.height = 720
	t.window.highdpi = true
	t.externalstorage = true
	t.identity = "Super Mario Whatever"
	t.window.title = "Super Mario Whatever"
end