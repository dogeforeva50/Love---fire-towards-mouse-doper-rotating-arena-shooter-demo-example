debug = true

function checkColl(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

flipdegz = math.rad(180)
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
    player.img = love.graphics.newImage('assets/Aircraft_04.png')
	bulletImg = love.graphics.newImage('assets/bullet_2_orange.png')
	enemyImg = love.graphics.newImage('assets/Aircraft_09.png')
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
	    love.event.push('quit')
    end
	
	if love.keyboard.isDown('left','a') then
	    if player.x > 0 then
	        player.x = player.x - (player.speed * dt)
		end
	elseif love.keyboard.isDown('right','d') then
	    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
		    player.x = player.x + (player.speed*dt)
	    end
	end
	
	if love.keyboard.isDown('up','w') then
	    if player.y > 0 then
		    player.y = player.y - (player.speed * dt * 0.8)
		end
	elseif love.keyboard.isDown('down','s') then
	    if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
		    player.y = player.y + (player.speed * dt * 1.2)
		end
	end
	
	canShootTimer = canShootTimer - (1*dt)
	if canShootTimer < 0 then
	    canShoot = true
	end
	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
	    newBullet = {x=player.x + (player.img:getWidth()/2 -5),y=player.y,img=bulletImg}
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
        love.graphics.draw(player.img,player.x,player.y)
	else
	    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	for i, bullet in ipairs(bullets) do
	    love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end
	for i, enemy in ipairs(enemies) do
	    love.graphics.draw(enemy.img, enemy.x, enemy.y, flipdegz)
	end
	love.graphics.setColor(255, 255, 255)
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
end
