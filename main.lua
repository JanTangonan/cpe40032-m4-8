--[[
    Hello my name is Jan Arvin Tangonan
    Group 8 Bs CpE 2 - 1
    and this is the screen cast of our crush-3 modification

    1st task is to add time whenever the player gets a score

    2nd is to ensure level 1 starts with simple blocks

    3rd is to create a shiny random block which removes all the blocks aligned to it

    4th is to create a reseter if there is no matches left, and if there is no match the block returns

    we still added the features we added during the past modules

    nwo lets try the game !
]]

-- this time, we're keeping all requires and assets in our Dependencies.lua file
require 'src/Dependencies'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

scrolling = true

-----------------------------------------------------------------------------------------------------------------
function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- window bar title
    love.window.setTitle('Crush Group 8')

    -- seed the RNG
    math.randomseed(os.time())

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- set music to loop and start
    --[[gSounds['music']:setLooping(true)
    gSounds['music']:play()]]

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- keep track of scrolling our background on the X axis
    backgroundX = 0
    backgroundScrollSpeed = 80
    
    -- initialize input table
    love.keyboard.keysPressed = {}
end
-----------------------------------------------------------------------------------------------------------------
function love.resize(w, h)
    push:resize(w, h)
end
-----------------------------------------------------------------------------------------------------------------
function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
    if key == '1' then
        gSounds['music']:setLooping(true)
        gSounds['music2']:stop()
        gSounds['music']:play()
                                                        -- just like the last module, i set 2 sound tracks so that 
    elseif key == '2' then                              -- the player can choose music according to his/her taste
        gSounds['music2']:setLooping(true)
        gSounds['music']:stop()
        gSounds['music2']:play()
    end
end
-----------------------------------------------------------------------------------------------------------------
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------
function love.update(dt)
    -- scroll background, used across all states
    if scrolling == true then
        backgroundX = backgroundX - backgroundScrollSpeed * dt

        -- if we've scrolled the entire image, reset it to 0
        if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
            backgroundX = 0
        end
    end
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end
-----------------------------------------------------------------------------------------------------------------
function love.draw()
    push:start()

    -- scrolling background drawn behind every state
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    gStateMachine:render()
    push:finish()
end