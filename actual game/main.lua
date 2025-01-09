-- Load some default values for our agent.
local r, g, b = love.math.colorFromBytes(132, 193, 238)
love.graphics.setBackgroundColor(r, g, b)
local timer = 0 
local int = math.ceil(timer)


collider = require 'libs/collider'


function love.load()
    local dbgcol = {1,1,1}
    -- THE RIGHT ONE WILL
    -- It's on github



    -- collision thing
    wall = {x = 100, y = 100, width = 50, height = 50}
    wall.sprite = love.graphics.newImage('sprites/white.png')
    -- If you installed transform.lua
    local transform = require 'libs/transform'


    anim8 = require 'libs/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")
    checker = 0 
    agent = {}
    agent.vx = 0
    agent.vy = 0 
    agent.x = 0
    agent.y = 0
    agent.speed = 300
    agent.spriteSheet = love.graphics.newImage('sprites/spritesheet3.png')
    agent.grid = anim8.newGrid( 64, 64, agent.spriteSheet:getWidth(), agent.spriteSheet:getHeight() )
    agent.animations = {}
    agent.animations.right = anim8.newAnimation( agent.grid('1-3', 1),0.15)
    agent.animations.left = anim8.newAnimation( agent.grid('1-3', 2),0.15)
    agent.jumped = love.graphics.newImage('sprites/agent_jump.png')
    agent.width = 64
    agent.height = 64

    agent.anim = agent.animations.right

    isMouseDown = false
    mouseX, mouseY = 0, 0

    gun = {}
    gun.x = agent.x + 5
    gun.y = agent.y - 5

    bullet = {}

    spawnBullets(0, 0, 500, 0, 100, 0, 2)

end

function spawnBullets(x, y, vx, vy, ax, ay, r)
    table.insert(bullet, {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        ax = ax,
        ay = ay,
        r = r
    })
end



function drawBullets()
    for _, bullet in ipairs(bullet) do
        love.graphics.setColor(255, 174, 66)
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.r)
    end
end


function updateBullets(dt)
    for _, bullet in ipairs(bullet) do

        bullet.vx = bullet.vx + bullet.ax * dt
        bullet.vy = bullet.vy + bullet.ay * dt


        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
    end
end



function love.update(dt)

    updateBullets(dt)

    agent.y = agent.y + 0 --this is gravity here at play trust
    gun.y = agent.y + 30

    collider.update()



    if agent.anim == agent.animations.right then -- making the gun work
        gun.x = agent.x + 60
    end

    if agent.anim == agent.animations.left then -- also making the gun work
        gun.x = agent.x - -5
    end


    t = 0 -- counter thing
    timer = timer + dt
    local distance
    local isMoving = false
    if love.keyboard.isDown("right") then
        agent.anim = agent.animations.right
        agent.x = agent.x + 2
        isMoving = true
        gun.x = agent.x + 60 --make the gun face right
    end

    if love.keyboard.isDown("left") then
        isMoving = true
        agent.x = agent.x - 2
        agent.anim = agent.animations.left
        gun.x = agent.x - -5 --make the gun face left I guess
    end

    agent.anim:update(dt)

    if isMoving == false then
        agent.anim:gotoFrame(1)

    end

    agent.x = agent.x + agent.vx * dt
    agent.y = agent.y + agent.vy * dt

    if love.mouse.isDown(1) then
        isMouseDown = true
        mouseX, mouseY = love.mouse.getPosition()
    else

        if isMouseDown then
            local dx = mouseX - agent.x
            local dy = mouseY - agent.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            agent.vx = (dx / distance) * agent.speed
            agent.vy = (dy / distance) * agent.speed
        end
        isMouseDown = false
    end


    local damping = 0.98 
    local stopThreshold = 10 
    
    agent.x = agent.x + agent.vx * dt
    agent.y = agent.y + agent.vy * dt
    

    agent.vx = agent.vx * damping
    agent.vy = agent.vy * damping


    if math.abs(agent.vx) < stopThreshold and math.abs(agent.vy) < stopThreshold then
        agent.vx = 0
        agent.vy = 0
    end

    if checkCollision(agent, wall) then
        t = 0 + 1 
    end
    -- collision checker thingy

    -- pain, suffering and bullets


    if love.mouse.isDown(2) then
        if agent.anim == agent.animations.right then
            spawnBullets(gun.x, gun.y, 500, 0, 0, 0, 2)
        elseif agent.anim == agent.animations.left then
            spawnBullets(gun.x, gun.y, -500, 0, 0, 0, 2)
        end           
    end

-- I swear, these monkey wrenched solutions will stop working at some point, but for now we shall enjoy


end







-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.print(agent.x, 10, 210)
    love.graphics.print(int, 350, 0)
    agent.anim:draw(agent.spriteSheet, agent.x, agent.y, nil, 1)
    love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
    love.graphics.print(t)
    love.graphics.circle("fill", gun.x, gun.y, 2)
    love.graphics.print(gun.x, 10, 250)
    love.graphics.print(gun.y, 10, 260)

    love.graphics.setColor(255, 174, 66)
    drawBullets()


    if isMouseDown then
        drawDottedArc(agent.x, agent.y, mouseX, mouseY)
        love.graphics.draw(agent.jumped, agent.x, agent.y, nil, 1)
    end
    collider.draw()
end

function drawDottedArc(x1, y1, x2, y2)
    local numDots = 20 
    local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    
    for i = 1, numDots do
        local t = i / numDots
        local cx = x1 + (x2 - x1) * t
        local cy = y1 + (y2 - y1) * t
        love.graphics.circle("fill", cx, cy, 2)
    end
end


-- thanks google
function checkCollision(obj1, obj2)
    return obj1.x < obj2.x + obj2.width and
           obj1.x + obj1.width > obj2.x and
           obj1.y < obj2.y + obj2.height and
           obj1.y + obj1.height > obj2.y
end
-- THE ACTUAL THING!!!
