pitch = 1.0
function love.load(arg)
    module = love.audio.newSource("assets/emotional_landscape.xm","static")
	module:play()
end
function love.update(dt)
	if love.keyboard.isDown('up') then
	    pitch = pitch + 0.05
	    module:setPitch(pitch)
    end
	if pitch > 0.05 then
	    if love.keyboard.isDown('down') then
	        pitch = pitch - 0.05
	        module:setPitch(pitch)
        end
    end
	if love.keyboard.isDown('left') then
	    --love.audio.rewind(module)
		module:rewind()
	end
end
function love.draw(dt)
    love.graphics.print("dt: " .. tostring(dt), 400, 10)
	love.graphics.print("pitch" .. tostring(pitch),10,10)
end