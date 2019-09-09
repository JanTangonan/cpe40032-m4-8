--[[
   CMPE40032
    Candy Crush Clone (Match 3 Game)

    -- Board Class --



    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}
-----------------------------------------------------------------------------------------------------------------
function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
-----------------------------------------------------------
    self.variety = level
    self.colorCount = 6
	self.varietyCount = 5
	self.tilesInPlay = {}
-----------------------------------------------------------   
    self:initializeTiles()
end

function Board:tileCreator(x_pos, y_pos)
                        -- the purpose of this, is to minimize the apperance of too many blocks
                        -- so the player will wont have a hard time at the start of level 1

	local colorsPossible = {4, 9, 11, 12, 17, 18}               -- these numbers represent the light colored ones      
	local color = colorsPossible[math.floor(math.random(self.colorCount))]

	local variety = math.random(math.min(math.random(self.variety) / 2, self.varietyCount))
	local tile = Tile(x_pos, y_pos, color, variety, shiny)

	-- AS3.4 - adding to table of colors and varieties in play
	if self.tilesInPlay[color] ==  nil then
		self.tilesInPlay[color] = {}
		for i=1, self.varietyCount do
			self.tilesInPlay[color][i] = 0
		end
	end

	self.tilesInPlay[color][variety] = self.tilesInPlay[color][variety] + 1
	return tile
end 
-----------------------------------------------------------------------------------------------------------------
function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety     -- this is where the function tile
            local tile = self:tileCreator(tileX, tileY)                     -- creator is called and initialized
			table.insert(self.tiles[tileY], tile)
        end
    end

    while self:calculateMatches() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end
-----------------------------------------------------------------------------------------------------------------
--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
-----------------------------------------------------------        
        shinyUsed = false             -- first it should be false, only true when it is used
-----------------------------------------------------------
        -- every horizontal tile
        for x = 2, 8 do
-----------------------------------------------------------            
            if self.tiles[y][x].shiny then
                shinyUsed = true        -- if used, it'll be true
            end
-----------------------------------------------------------
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}
------------------------------------------------------------               
                    if shinyUsed then 
                        for x2 = 1, 8, 1 do           -- if used, add all the tiles in the current row       
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    if not shinyUsed then
                        for x2 = x - 1, x - matchNum, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1
                shinyUsed = false  -- now it will return to false again to reset
------------------------------------------------------------
                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
-----------------------------------------------------------
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then
                    shinyUsed = true
                    break
                end
                table.insert(match, self.tiles[y][x])
            end
            table.insert(matches, match)
        end
        if shinyUsed then
            local match = {}
            for x2 = 1, 8, 1 do
                table.insert(match, self.tiles[y][x2])
            end
            table.insert(matches, match)
        end
    end
-----------------------------------------------------------
    -- vertical matches
    for x = 1, 8 do
        
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        shinyUsed = false
        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].shiny then
                shinyUsed = true
            end
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    if shinyUsed then
                        for y2 = 1, 8, 1 do        -- same logic with the horizontal tile
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    if not shinyUsed then
                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1
                shinyUsed = false

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then
                    shinyUsed = true
                    break
                end
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
        if shinyUsed then
            local match = {}
            for y2 = 1, 8, 1 do
                table.insert(match, self.tiles[y2][x])
            end
            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
-----------------------------------------------------------------------------------------------------------------
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end
-----------------------------------------------------------------------------------------------------------------
--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set space back to 0, set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                local tile = Tile(x, y, math.random(18), math.random(6))
                tile.y = -32
                self.tiles[y][x] = tile

                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end
-----------------------------------------------------------------------------------------------------------------
function Board:getNewTiles()
    return {}
end
-----------------------------------------------------------------------------------------------------------------
function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
-----------------------------------------------------------
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:renderParticles(self.x, self.y)        -- for rendering particles
        end
    end
-----------------------------------------------------------   
end
-----------------------------------------------------------------------------------------------------------------
function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------
function Board:matchesAvailable()                   
    print("called")                         -- this part will check if there are still matches available
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do

                -- if we have at least one tile on the left
            if x > 1 then
                        -- swap tile left
                local newTile = self.tiles[y][x-1]
                self.tiles[y][x-1] = self.tiles[y][x]
                self.tiles[y][x] = newTile
                        -- calculate matches
                local matches = self:calculateMatches()
                        -- revert tiles to the original position
                newTile = self.tiles[y][x-1]
                self.tiles[y][x-1] = self.tiles[y][x]
                self.tiles[y][x] = newTile
                        -- if there is at least one match
                if matches ~= false then     
                    return true
                end
                -- if we have at least one tile on the right
            elseif x < 8 then
                        -- swap tile right
                local newTile = self.tiles[y][x+1]
                self.tiles[y][x+1] = self.tiles[y][x]
                self.tiles[y][x] = newTile
                        -- calculate matches
                local matches = self:calculateMatches()
                        -- revert tiles to the original position
                newTile = self.tiles[y][x+1]
                self.tiles[y][x+1] = self.tiles[y][x]
                self.tiles[y][x] = newTile
                        -- if there is at least one match
                if matches ~= false then
                    return true
                end
            end
        end
    end   
    return false
end