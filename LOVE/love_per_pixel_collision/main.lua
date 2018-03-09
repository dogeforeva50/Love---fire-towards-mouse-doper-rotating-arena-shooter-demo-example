--==============================================================================
--          Name: main.lua
--        Author: Kevin Harris
-- Last Modified: July 22, 2010
--   Description: LOVE demo of per-pixel collision using the transparent pixels
--                of PNG image files.
--==============================================================================

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

function love.load()

    sprites = {}

    local terrainSprite =
    {
        name = "Terrain",
        image = love.graphics.newImage( "terrain.png" ),
        collisionMap = newCollisionMap( "terrain.png" ),
        x = 0,
        y = 440
    }

    table.insert( sprites, terrainSprite )

    local bushSprite =
    {
        name = "Bush",
        image = love.graphics.newImage( "bush.png" ),
        collisionMap = newCollisionMap( "bush.png" ),
        x = 500,
        y = 425
    }

    table.insert( sprites, bushSprite )

    local treeSprite =
    {
        name = "Tree",
        image = love.graphics.newImage( "tree.png" ),
        collisionMap = newCollisionMap( "tree.png" ),
        x = 50,
        y = 185
    }

    table.insert( sprites, treeSprite )

    local cloudSprite =
    {
        name = "Cloud",
        image = love.graphics.newImage( "cloud_plain.png" ),
        collisionMap = newCollisionMap( "cloud_plain.png" ),
        x = 300,
        y = 25
    }

    table.insert( sprites, cloudSprite )

    local loveLogoSprite =
    {
        name = "LOVE Logo",
        image = love.graphics.newImage( "love_logo.png" ),
        collisionMap = newCollisionMap( "love_logo.png" ),
        x = 350,
        y = 275
    }

    table.insert( sprites, loveLogoSprite )

    font = love.graphics.newFont( 12 )
    love.graphics.setFont( font )
    message = "No pixels colliding!"
    enableCollisionResponse = false

    -- Light blue color for the sky (HTML).
    love.graphics.setBackgroundColor( 0x84, 0xCA, 0xFF )

end

function love.keypressed( key )

    -- Space bar
    if key == " " then
        enableCollisionResponse = not enableCollisionResponse
    end

end

function love.update( dt )
    
    -- Cache the old x,y just in case we need to prevent the LOVE logo
    -- from entering another sprite.
    local x = sprites[5].x
    local y = sprites[5].y

    if love.keyboard.isDown( "left" ) then
       sprites[5].x = sprites[5].x - 200 * dt
    end

    if love.keyboard.isDown( "right" ) then
       sprites[5].x = sprites[5].x + 200 * dt
    end

    if love.keyboard.isDown( "up" ) then
       sprites[5].y = sprites[5].y - 200 * dt
    end

    if love.keyboard.isDown( "down" ) then
       sprites[5].y = sprites[5].y + 200 * dt
    end

    local colliding = false
    local name = ""

    for i,v in ipairs( sprites ) do

        -- If the sprite is not number 5, which is our LOVE logo, test the 
        -- sprite for per pixel collision against our ball sprite.
        if i ~= 5 then
            if perPixelCollision( sprites[5], v ) then
                colliding = true

                if name == "" then
                    name = '"' .. v.name .. '"'
                else
                    name = name .. " and " .. '"' .. v.name .. '"'
                end

            end
        end
    end

    if colliding then
        message = "LOVE logo pixels colliding with " .. name .. "!"

        -- If collision response is enabled and we have collided with another
        -- sprite - simply disallow the move by restoring its old x, y position.
        if enableCollisionResponse == true then
            sprites[5].x = x
            sprites[5].y = y
        end
    else
       message = "No pixels colliding!"
    end

end

function love.draw()

    for i,v in ipairs( sprites ) do
        love.graphics.draw( v.image, v.x, v.y )
    end

    love.graphics.print( "Use the arrow keys to move the LOVE logo.", 10, 20 )

    if enableCollisionResponse == true then
       love.graphics.print( "Use the Space bar to toggle a collision response. (ON)", 10, 40 )
    else
        love.graphics.print( "Use the Space bar to toggle a collision response. (OFF)", 10, 40 )
    end

    love.graphics.print( message, 10, 60 )

end
