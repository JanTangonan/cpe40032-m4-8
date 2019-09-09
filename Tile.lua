--[[
   CMPE40032
    Candy Crush Clone (Match 3 Game)

    -- Tile Class --



    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
-----------------------------------------------------------
    self.shiny = math.random(1,100) < 10  -- out of 100, there is only 10% chance of spawning of shiny

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.8, 1)
    self.psystem:setLinearAcceleration(0, 0, 0, -1)                 -- these are fot the appearance of particles
    self.psystem:setAreaSpread('normal', 6, 6)                      -- something that will make the block look
                                                                    -- shining
    Timer.every(0.1, function()
        self.psystem:emit(2)
    end)
-----------------------------------------------------------

end

function Tile:update(dt)
    if self.shiny then
        self.psystem:setColors(
            255,
            255,
            250,
            90,
            255,
            255,
            205,
            0
        )
        self.psystem:update(dt)
    end
end

--[[
    Function to swap this tile with another tile, tweening the two's positions.
]]
--[[
function Tile:swap(tile)

end]]

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end
-----------------------------------------------------------
function Tile:renderParticles(x, y)                 -- rendering the particles
    if self.shiny then                              
        love.graphics.draw(self.psystem, x + self.x + 16, y + self.y + 16)      
    end
end
-----------------------------------------------------------