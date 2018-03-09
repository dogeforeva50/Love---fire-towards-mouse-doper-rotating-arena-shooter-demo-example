debug = true

function checkColl(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

function newCollisionMap( imageFileName )

    local imageData = love.image.newImageData( imageFileName )
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    local collisionMap = {}

    -- Build a collision map as a table of row tables that contains 1's and 0's.
    -- A 1 means the pixel at this position is non-transparent and 0 means it
    -- transparent.
    for y = 1, height do

        collisionMap[y] = {}

        for x = 1, width do

            -- Use -1 since getPixel() starts indexing at 0 not 1 like Lua.
            local r, g, b, a = imageData:getPixel( x-1, y-1 )

            if a == 0 then
                collisionMap[y][x] = 0
            else
                collisionMap[y][x] = 1
            end

        end
    end

    return collisionMap

end

function perPixelCollision( sprite1, sprite2 )

    -- First, we do a simple bounding box collision check. This will let
    -- us know if the two sprites overlap in any way.
    if not ( (sprite1.x + sprite1.image:getWidth() > sprite2.x) and
             (sprite1.x < sprite2.x + sprite2.image:getWidth()) and
             (sprite1.y + sprite1.image:getHeight() > sprite2.y) and
             (sprite1.y < sprite2.y + sprite2.image:getHeight()) ) then
        return false
    end

    -- If we made it this far, our two sprites definitely touch or overlap,
    -- but that doesn't mean that that we have an actual collision between
    -- two non-transparent pixels.

    -- By default, sprite1 scans sprite2 for a pixel collision per line, so
    -- if sprite1 is taller, swap the sprites around so the shorter one is
    -- scanning the taller one. This will result in less work in cases where 
    -- they initially overlap but ultimately do not collide at the pixel level.
    if sprite1.image:getHeight() > sprite2.image:getHeight() then
       objTemp = sprite1
       sprite1 = sprite2
       sprite1 = objTemp
    end

    -- Loop through each row of sprite1's collision map and check it against
    -- sprite2's corresponding collision map row.
    for indexY = 1, sprite1.image:getHeight() do

        local screenY = math.floor( (sprite1.y + indexY) - 1  )

        if screenY > sprite2.y and screenY <= sprite2.y + sprite2.image:getHeight() then

            -- Some, or all, of the current row (Y) of sprite1's collision map overlaps
            -- sprite2's collision map. Calculate the start and end indices (X) for each
            -- row, so we can test this area of overlap for a collision of 
            -- non-transparent pixels.

            local y1 = math.floor( indexY )
            local y2 = 1

            if screenY > sprite2.y then
                y2 = math.floor( screenY - sprite2.y )
            elseif screenY < sprite2.y then
                y2 = math.floor( sprite2.y - screenY )
            end

            local sprite1Index1 = 1
            local sprite1Index2 = sprite1.image:getWidth()
            local sprite2Index1 = 1
            local sprite2Index2 = sprite2.image:getWidth()

            if sprite1.x < sprite2.x then

               sprite1Index1 = math.floor( sprite2.x - sprite1.x ) + 1
               sprite1Index2 = sprite1.image:getWidth()

               sprite2Index1 = 1
               sprite2Index2 = math.floor( (sprite1.x + sprite1.image:getWidth()) - sprite2.x ) + 1

               -- If the sprites being tested are of different sizes it's possible
               -- for this index to get too big - so clamp it.
               if sprite2Index2 > sprite2.image:getWidth() then
                  sprite2Index2 = sprite2.image:getWidth()
               end

            elseif sprite1.x > sprite2.x then

               sprite1Index1 = 1
               sprite1Index2 = math.floor( (sprite2.x + sprite2.image:getWidth()) - sprite1.x ) + 1

               -- If the sprites being tested are of different sizes it's possible
               -- for this index to get too big - so clamp it.
               if sprite1Index2 > sprite1.image:getWidth() then
                  sprite1Index2 = sprite1.image:getWidth()
               end

               sprite2Index1 = math.floor( sprite1.x - sprite2.x ) + 1
               sprite2Index2 = sprite2.image:getWidth()

            else -- sprite1.x == sprite2.x

               -- If the two sprites have the same x position - the width of 
               -- overlap is simply the shortest width.
               shortest = sprite1.image:getWidth()

               if sprite2.image:getWidth() < shortest then
                  shortest = sprite2.image:getWidth()
               end

               sprite1Index1 = 1
               sprite1Index2 = shortest

               sprite2Index1 = 1
               sprite2Index2 = shortest

            end

            local index1 = sprite1Index1
            local index2 = sprite2Index1

            while index1 < sprite1Index2 and index2 < sprite2Index2 do

                if sprite1.collisionMap[y1][index1] == 1 and sprite2.collisionMap[y2][index2] == 1 then
                    return true -- We have a collision of two non-transparent pixels!
                end

                index1 = index1 + 1
                index2 = index2 + 1

            end

        end

    end

    return false -- We do NOT have a collision of two non-transparent pixels.

end

isAlive = true
score = 0

player = { x = 200, y = 720, speed = 340, img = nil}
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

bulletImg = nil
bullets = {}

createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
enemyImg = nil
enemies = {}

function love.load(arg)
    sprites = {}
	--bullets = {}
	--enemies = {}
	local myaircraft =
	{
	    name = "Player Aircraft",
		image = love.graphics.newImage('assets/Aircraft_04.png'),
		collisionMap = newCollisionMap('assets/Aircraft_04.png'),
		x = 200,
		y = 720,
		speed = 340
	}
	table.insert(sprites, myaircraft)
	--player.img = love.graphics.newImage('assets/Aircraft_04.png')	
	--local bullett =
	--{
	    --name = "A Bullet",
		--image = love.graphics.newImage('assets/bullet_2_orange.png'),
		--collisionMap = newCollisionMap('assets/bullet_2_orange.png')
	--}
	--table.insert(sprites, bullett)
	bulletImg = love.graphics.newImage('assets/bullet_2_orange.png')
	local enemyy =
	{
	    name = "An Enemy",
		image = love.graphics.newImage('assets/Aircraft_09.png'),
		collisionMap = newCollisionMap('assets/Aircraft_09.png')
	}
	--table.insert(sprites,enemyy)
	--enemyImg = love.graphics.newImage('assets/Aircraft_09.png')
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
	    love.event.push('quit')
    end
	
	if love.keyboard.isDown('left','a') then
	    if sprites[1].x > 0 then
	        sprites[1].x = sprites[1].x - (sprites[1].speed * dt)
		end
	elseif love.keyboard.isDown('right','d') then
	    if sprites[1].x < (love.graphics.getWidth() - sprites[1].image:getWidth()) then
		    sprites[1].x = sprites[1].x + (sprites[1].speed*dt)
	    end
	end
	
	if love.keyboard.isDown('up','w') then
	    if sprites[1].y > 0 then
		    sprites[1].y = sprites[1].y - (sprites[1].speed * dt * 0.8)
		end
	elseif love.keyboard.isDown('down','s') then
	    if sprites[1].y < (love.graphics.getHeight() - sprites[1].image:getHeight()) then
		    sprites[1].y = sprites[1].y + (sprites[1].speed * dt * 1.2)
		end
	end
	
	canShootTimer = canShootTimer - (1*dt)
	if canShootTimer < 0 then
	    canShoot = true
	end
	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
	    newBullet = {x=sprites[1].x + (sprites[1].image:getWidth()/2 -5),y=sprites[1].y,image=bulletImg}
		table.insert(bullets,newBullet)
		canShoot= false
		canShootTimer = canShootTimerMax
	end
	for i, bullet in ipairs(bullets) do
	    bullet.y = bullet.y - (250 * dt)
		if bullet.y < 0 then
		    table.remove(bullets,i)
		end
	end
	createEnemyTimer = createEnemyTimer - (1*dt)
	if createEnemyTimer < 0 then
	    createEnemyTimer = createEnemyTimerMax
		randomNumber = math.random(10,love.graphics.getWidth() - 10)
		newEnemy = {x=randomNumber,y=-10,img=enemyImg}
		table.insert(enemies,newEnemy)
	end
	for i, enemy in ipairs(enemies) do
	    enemy.y = enemy.y + (200 * dt)
		if enemy.y>850 then
		    table.remove(enemies,i)
		end
	end
	-- run collision detection
	--[
	for i, enemy in ipairs(enemies) do
	    for j, bullet in ipairs(bullets) do
		    if checkColl(enemy.x,enemy.y,enemy.img:getWidth(),enemy.img:getHeight(),bullet.x,bullet.y,bullet.img:getWidth(),bullet.img:getHeight()) then
			    table.remove(bullets,j)
				table.remove(enemies,i)
				score = score + 100
			end
		end
		if checkColl(enemy.x,enemy.y,enemy.img:getWidth(),enemy.img:getHeight(),player.x,player.y,player.img:getWidth(),player.img:getHeight())
		and isAlive then
		    table.remove(enemies,i)
			isAlive=false
		end
	end
	--]
	-- allow restart
	if not isAlive and love.keyboard.isDown('r') then
	    bullets = {}
		enemies = {}
		
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax
		player.x = 50
		player.y = 720
		score = 0
		isAlive = true
	end
end

function love.draw(dt)
    if isAlive then
        love.graphics.draw(sprites[1].image,sprites[1].x,sprites[1].y)
	else
	    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	for i, bullet in ipairs(bullets) do
	    love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end
	for i, enemy in ipairs(enemies) do
	    love.graphics.draw(enemy.img, enemy.x, enemy.y, math.rad(180))
	end
	love.graphics.setColor(255, 255, 255)
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
end
