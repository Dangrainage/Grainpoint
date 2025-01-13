-- Load some default values for our agent.


-- Reminder:

-- Add a non gun animation to the agent

-- Add intimidation value, and intimidation range (hopefully upgradable)

-- Add sprinting? Or just slow player down on pulling the gun out?

-- Add pouncing (or at least fix It)

-- Add/Fix Collisions 

-- Fix the fucking gun

-- Seek professional mental help (I'm In pain)










local r, g, b = love.math.colorFromBytes(132, 193, 238)
love.graphics.setBackgroundColor(r, g, b)
local timer = 0 
local int = math.ceil(timer)


collider = require 'libs/collider'


function love.load()
    local dbgcol = {1,1,1}
    -- THE RIGHT ONE WILL
    -- It's on github
    vr = 0

    -- collision thing
    guard = {x = 100, y = 100, width = 64, height = 64}
    guard.sprite = love.graphics.newImage('sprites/guard.png')
    guard.dead = false
    guard.uncons = false
    guard.ok = true
    guard.body = love.graphics.newImage('sprites/guard_body.png')


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
    --agent.nil_grid = love.graphics.newImage('sprites/nul.png')
    --agent.animations.nul_spritesheet = anim8.newGrid( 64, 64, agent.nil_grid:getWidth(), agent.nil_grid:getHeight() )
    --agent.animations.nul = anim8.newAnimation(agent.grid('1-3', 2), 0.15)
    agent.width = 64
    agent.height = 64
    agent.jumped_left = love.graphics.newImage('sprites/agent_jump_left.png')
    agent.pouncing = love.graphics.newImage('sprites/pouncing.png')


    agent.anim = agent.animations.right

    isMouseDown = false
    mouseX, mouseY = 0, 0
    disableShooting = false
   -- pouncing = false 

    gun = {}
    --gun.x = agent.x + 5
    --gun.y = agent.y - 5

    bullet = {}

    spawnBullets(0, 0, 500, 0, 100, 0, 2)
    bullet_numer = 6
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
        --love.graphics.setColor(255, 174, 66)
        --love.graphics.setColor(1, 0, 0)
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
    --if pouncing == false then
        if love.mouse.isDown(1) then
            isMouseDown = true
            mouseX, mouseY = love.mouse.getPosition()
            disableShooting = true
        else

            if isMouseDown then
                local dx = mouseX - agent.x
                local dy = mouseY - agent.y
                local distance = math.sqrt(dx * dx + dy * dy)
            
                agent.vx = (dx / distance) * agent.speed
                agent.vy = (dy / distance) * agent.speed
            end
            isMouseDown = false
            disableShooting = false
    --end
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

    if checkCollision(agent, guard) then
        t = 0 + 1 
        --pouncing = true
        --if pouncing == true then
            --love.graphics.print("You're poucing, up to kill, down to knock out", 280, 10)
        --end

    end
    -- collision checker thingy

    -- pain, suffering and bullets

    magazine()


    if love.mouse.isDown(2) and not disableShooting then
        --if pouncing == false then 
            if agent.anim == agent.animations.right then
                spawnBullets(gun.x, gun.y, 500, 0, 0, 0, 2)
                bullet_numer = bullet_numer - 1
            elseif agent.anim == agent.animations.left then
                spawnBullets(gun.x, gun.y, -500, 0, 0, 0, 2)
                bullet_numer = bullet_numer - 1
            end
                   
    --end
end


-- I swear, these monkey wrenched solutions will stop working at some point, but for now we shall enjoy

    

end


function magazine()
    if bullet_numer <= 0 then
        disableShooting = true
    end    
end


-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.print(agent.x, 10, 210)
    love.graphics.print(int, 350, 0)
    --agent.anim:draw(agent.spriteSheet, agent.x, agent.y, nil, 1)
    --love.graphics.rectangle("fill", guard.x, guard.y, guard.width, guard.height)
    love.graphics.print(t)
    love.graphics.circle("fill", gun.x, gun.y, 2)
    love.graphics.print(gun.x, 10, 250)
    love.graphics.print(gun.y, 10, 260)
    love.graphics.print(bullet_numer, 20, 300)


    love.graphics.setColor(255, 174, 66)
    drawBullets()
    collider.draw()
    
    

    --if pouncing == false then

            if isMouseDown then
                drawDottedArc(agent.x, agent.y, mouseX, mouseY)
                if mouseX > agent.x + 2 then
                    love.graphics.draw(agent.jumped, agent.x, agent.y, nil, 1)
                    agent.anim = agent.animations.right
                elseif mouseX < agent.x - 2 then
                    love.graphics.draw(agent.jumped_left, agent.x, agent.y, nil, 1)
                    agent.anim = agent.animations.left
                end
            end
       -- if guard.ok == true then
            love.graphics.draw(guard.sprite, guard.x, guard.y, nil, 1 )
       -- elseif guard.dead or guard.uncons then
         --   love.graphics.draw(guard.body, guard.x, guard.y, nil, 1)
        --end


        if not isMouseDown then
            agent.anim:draw(agent.spriteSheet, agent.x, agent.y, nil, 1)
        end
    

    --elseif  pouncing == true and guard.ok == true then
        --love.graphics.draw(agent.pouncing, agent.x, agent.y, nil, 1)
        --guard.x, guard.y = agent.x, agent.y
        --if love.keyboard.isDown("down") then
            --guard.uncons = true
            --guard.dead = false
            --guard.ok = false
            --love.graphics.print("Non-lethal", 250, 10)
            --pouncing = false
            --guard.x, guard.y = guard.x - 20, guard.y
            --love.graphics.draw(guard.body, guard.x, guard.y, nil, 1)
            --agent.x = agent.x + 20
        --elseif love.keyboard.isDown("up") then
            --guard.dead = true
            --love.graphics.print("Lethal", 250, 10)
            --guard.uncons = false
            --guard.ok = false
            --pouncing = false
            --guard.x, guard.y = guard.x - 20, guard.y + 0
            --endMysuffering()
            --love.graphics.draw(guard.body, guard.x, guard.y, nil, 1)
end       
    --end
--end


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
