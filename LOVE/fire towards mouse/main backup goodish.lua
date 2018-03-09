function love.load()
	love.graphics.setBackgroundColor(54, 172, 248)
 
	bulletSpeed = 250
 
	bullets = {}
	bullets2 = {}
	
	bullets2p2 = {}
	bulletsp2 = {}
	--player = {x=300, y=300, width=15, height=15,speed = 200}
	player = {x=0, y=0, width=40, height=40,speed = 200}
	--player2 = {x=300,y=300,width=10,height=10,speed=220}
	player2 = {x=0,y=0,width=10,height=10,speed=220}
	ybound = love.graphics.getHeight()
	xbound = love.graphics.getWidth()
	scalx = 2
	scaly = 2
	myangle = 0
	transx = 300
	transy = 300
end

function love.draw()
    love.graphics.push()
	--love.graphics.scale(scalx,scaly)
	love.graphics.translate(transx,transy)
	love.graphics.rotate(math.rad(myangle))
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill",  player.x, player.y, player.width, player.height)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", player2.x,player2.y,player2.width,player2.height)
 
	love.graphics.setColor(0, 250, 128)
	for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 2)
	end
	love.graphics.setColor(0,100,100)
	for i,v in ipairs(bullets2) do
	    love.graphics.circle("fill", v.x, v.y, 1)
	end

	love.graphics.setColor(100,0,100)
	for i,v in ipairs(bulletsp2) do
	    love.graphics.circle("fill",v.x,v.y,2)
	end
	love.graphics.setColor(120,0,120)
	for i,v in ipairs(bullets2p2) do
	    love.graphics.circle("fill",v.x,v.y,1)
	end
	--love.graphics.print("SCORE: " .. tostring(score), 400, 10)
	love.graphics.print("Angle: ".. myangle, 10, 10)
	love.graphics.pop()
end

function love.update(dt)
    if love.mouse.isDown(1) then
	    local startX = player.x + player.width / 2
		local startY = player.y + player.height / 2
		local mouseX = love.mouse.getX()
		local mouseY = love.mouse.getY()
 
		--local angle = math.atan2((mouseY - startY), (mouseX - startX))
		-- below three statements work but only if not moved from origin
		local angle = math.atan2((mouseY - startY -transx), (mouseX - startX - transy))
		local bulletDx = bulletSpeed * (math.cos(angle-math.rad(myangle)))
		local bulletDy = bulletSpeed * (math.sin(angle-math.rad(myangle)))
		--above works if player startX and startY don't change from the origin
		--above is what i used
		
		--translated by 300,300, here we subtract 300 and 300
 		--local bulletDx = bulletSpeed * (math.cos(angle) - math.cos(myangle))
		
		
		
		--local bulletDy = bulletSpeed * (math.sin(angle) - math.sin(myangle))
		
 
		table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
	end
	if love.mouse.isDown(2) then
	    local startX = player.x + player.width / 2
		local startY = player.y + player.height / 2
		local mouseX = love.mouse.getX()
		local mouseY = love.mouse.getY()
 
		local angle = math.atan2((mouseY - startY -300), (mouseX - startX -300))
 
		local bulletDx = bulletSpeed * math.cos(angle)
		local bulletDy = bulletSpeed * math.sin(angle)
 
		table.insert(bullets2, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
		
		local startX2 = player2.x + player2.width / 2
		local startY2 = player2.y + player2.height / 2
		local angle2 = math.atan2((mouseY - startY2), (mouseX - startX2))
		
		local bullet2Dx = bulletSpeed * math.cos(angle2)
		local bullet2Dy = bulletSpeed * math.sin(angle2)
		table.insert(bullets2p2, {x=startX2,y=startY2,dx=bullet2Dx,dy=bullet2Dy})
	end
	if love.keyboard.isDown('w') then
	    player.y = player.y - player.speed*dt
		player2.y = player2.y - player2.speed*dt
	end
	if love.keyboard.isDown('s') then
	    player.y = player.y + player.speed*dt
		player2.y = player2.y + player2.speed*dt
	end
	if love.keyboard.isDown('d') then
	    player.x = player.x + player.speed*dt
		player2.x = player2.x + player2.speed*dt
	end
	if love.keyboard.isDown('a') then
	    player.x = player.x - player.speed*dt
		player2.x = player2.x - player2.speed*dt
	end
	if love.keyboard.isDown('e') then
	    myangle = myangle + 1
	end
	if love.keyboard.isDown('q') then
	    myangle = myangle - 1
	end
	if love.keyboard.isDown('rctrl') then
	    debug.debug()
	end
	for i,v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
		--[[if v.y < (0 - 300) then
		    table.remove(bullets,i)
		end
		if v.y > (ybound - 300) then
		    table.remove(bullets,i)
		end
		if v.x < (0 - 300) then
		    table.remove(bullets, i)
		end
		if v.x > (xbound - 300) then
		    table.remove(bullets, i)
		end
		--]]
		local sumxy = math.abs(v.x) + math.abs(v.y)
		local radius = 600 * math.sqrt(2)
		if sumxy > radius then
		    table.remove(bullets,i)
		end
	end
	for i,v in ipairs(bullets2) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
		if v.y < 0 then
		    table.remove(bullets2,i)
		end
		if v.y > ybound then
		    table.remove(bullets2,i)
		end
		if v.x < 0 then
		    table.remove(bullets2, i)
		end
		if v.x > xbound then
		    table.remove(bullets2, i)
		end
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