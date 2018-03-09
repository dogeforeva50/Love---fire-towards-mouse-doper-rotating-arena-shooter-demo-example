function love.load()
	love.graphics.setBackgroundColor(54, 172, 248)
 
	bulletSpeed = 250
 
	bullets = {}
	player = {x=250, y=250, width=15, height=15,speed = 200}
	--ybound = love.graphics.getHeight()
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill",  player.x, player.y, player.width, player.height)
 
	love.graphics.setColor(128, 128, 128)
	for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 3)
	end
end

function love.update(dt)
    if love.mouse.isDown(1) then
	    local startX = player.x + player.width / 2
		local startY = player.y + player.height / 2
		local mouseX = love.mouse.getX()
		local mouseY = love.mouse.getY()
 
		local angle = math.atan2((mouseY - startY), (mouseX - startX))
 
		local bulletDx = bulletSpeed * math.cos(angle)
		local bulletDy = bulletSpeed * math.sin(angle)
 
		table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
	end
	if love.keyboard.isDown('w') then
	    player.y = player.y - player.speed*dt
	end
	if love.keyboard.isDown('s') then
	    player.y = player.y + player.speed*dt
	end
	if love.keyboard.isDown('d') then
	    player.x = player.x + player.speed*dt
	end
	if love.keyboard.isDown('a') then
	    player.x = player.x - player.speed*dt
	end
	for i,v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
		--[[if v.y < 0 then
		    table.remove(bullets,i)
		end
		if v.y > ybound then
		    table.remove(bullets,i)
		end
		--]]
	end
end
--[[
function love.mousepressed(x, y, button)
	if button == "l" then
		local startX = player.x + player.width / 2
		local startY = player.y + player.height / 2
		local mouseX = x
		local mouseY = y
 
		local angle = math.atan2((mouseY - startY), (mouseX - startX))
 
		local bulletDx = bulletSpeed * math.cos(angle)
		local bulletDy = bulletSpeed * math.sin(angle)
 
		table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
	end
end
--]]