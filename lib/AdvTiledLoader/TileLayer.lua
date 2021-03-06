---------------------------------------------------------------------------------------------------
-- -= TileLayer =-
---------------------------------------------------------------------------------------------------

-- Setup
local Point = require("geometry.Point")
require 'utils'
local floor = math.floor
local type = type
local love = love
local TileLayer = {}
TileLayer.__index = TileLayer

-- Returns a new TileLayer
function TileLayer:new(map, name, opacity, prop)
	assert( map and name , "TileLayer:new - Needs at least 2 parameters for the map and name.")
	local tl = {}
	
	-- Public:
	tl.name = name				-- The name of the tile layer
	tl.map = map 				-- The map that this layer belongs to
	tl.opacity = opacity or 1	-- The opacity to draw the tiles (0-1)
	tl.properties = prop or {}	-- Properties set by Tiled
	tl.tileData = {}			-- 2d array containing the tile locations
	tl.useSpriteBatch = nil		-- If true then the layer is rendered with sprite batches. If
									-- false then the layer will not use sprite batches. If nil then 
									-- map.useSpriteBatch will be used. Note that using sprite 
									-- batches will break the draw order when using multiple tilesets
									-- on the same layer. Using Map.drawAfterTile is also not possible.
	-- Private:
	tl._batches = {}			-- Keeps track of the sprite batches for each tileset
	tl._flippedTiles = {}		-- Stores the flipped tile locations.
	tl._afterTileFunctions = {}	-- Functions that must happen right after a tile is drawn.
	tl._afterTileIndexes = {}	-- Keeps track of _afterTileFunctions indexes so we can clear them.
	tl._previousUseSpriteBatch = false	-- The previous useSpriteBatch. If this is different then we 
											-- need to force a special redraw
	
	for i=1,tl.map.height do tl._afterTileFunctions[i] = {} end
	return setmetatable(tl, TileLayer)
end

-- Clears the draw list of any functions
function TileLayer:clearAfterTile()
	local cells, indexes = self._afterTileFunctions, self._afterTileIndexes
	local cell = false
	for i = 1,#indexes,2 do
		cell = cells[ indexes[i] ][ indexes[i+1] ]
		for k = 1,#cell do
			cell[k] = nil
		end
		indexes[i], indexes[i+1] = nil, nil
	end
end

-- Adds a function to the tile's draw list
function TileLayer:drawAfterTile(h, w, funct)
	if self.useSpriteBatch ~= nil and self.useSpriteBatch or map.useSpriteBatch then 
		error("TileLayer:drawAfterTile - This function is not possible with sprite batches enabled.")
	end
	local ati = self._afterTileIndexes
	ati[#ati+1] = h
	ati[#ati+1] = w
	if not self._afterTileFunctions[h] then self._afterTileFunctions[h] = {} end
	if not self._afterTileFunctions[h][w] then self._afterTileFunctions[h][w] = {} end
	self._afterTileFunctions[h][w][ #self._afterTileFunctions[h][w]+1 ] = funct
end

-- These are used in TileLayer:draw() but since that function is called so often we'll define them
-- outside to prevent them from being created and destroyed all the time.
local map, tiles, tileData, postDraw, useSpriteBatch, tile, width, height
local at, drawX, drawY, flipX, flipY, r, g, b, a, halfW, halfH

-- Draws the TileLayer.
function TileLayer:draw()

	-- We access these a lot so we'll shorted them a bit. 
	map, tiles, tileData = self.map, self.map.tiles, self.tileData
	-- Same with post draw
	postDraw = self.postDraw
	
	-- If useSpriteBatch was turned on then we need to force redraw the sprite batches
	if self.useSpriteBatch ~= self._previousUseSpriteBatch then map:forceRedraw() end
	-- Set the previous useSpriteBatch
	self._previousUseSpriteBatch = self.useSpriteBatch
	-- If useSpriteBatch is set for this layer then use that, otherwise use the map's setting.
	useSpriteBatch = self.useSpriteBatch ~= nil and self.useSpriteBatch or map.useSpriteBatch
	
	-- We'll blend the set alpha in with the current alpha
	r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(r,g,b, a*self.opacity)
	
	self._previousUseSpriteBatch = self.useSpriteBatch
	
	
	-- Clear sprite batches if the screen has changed.
	if map._specialRedraw and useSpriteBatch then
		for k,v in pairs(self._batches) do
			v:clear()
		end
	end
	
	-- Get the tile range
	local x1, y1, x2, y2 = map._tileRange[1], map._tileRange[2], map._tileRange[3], map._tileRange[4]
	
	-- Only draw if we're not using sprite batches or we need to update the sprite batches.
	if map._specialRedraw or not useSpriteBatch then
	
		-- Orthogonal tiles
		if map.orientation == "orthogonal" then
			-- From top to bottom
			for h = y1, y2 do 
				-- From left to right
				for w = x1,x2 do
					-- Check and see if the tile is flipped
					-- 1 = flipped X;  2 = flipped Y;  3 = flipped X and Y
					flipX, flipY = 1, 1
					if self._flippedTiles[h] then
						if self._flippedTiles[h][w] then
							flipX = (self._flippedTiles[h][w] % 2) == 1 and -1 or 1
							flipY = (self._flippedTiles[h][w] / 2) >= 1 and -1 or 1
						end
					end
					-- Get the tile
					tile = map.tiles[ self.tileData[h][w] ]
					if tile and tile ~= 0 then 
						-- Get the half-width and half-height
						halfW, halfH = tile.width*0.5, tile.height*0.5
						-- Draw the tile from the bottom left corner
						drawX, drawY = (w-1)*map.tileWidth, h*map.tileHeight
						if useSpriteBatch then
							-- If we dont have a spritebatch for the current tile's tileset then make one
							if not self._batches[tile.tileset] then 
								self._batches[tile.tileset] = love.graphics.newSpriteBatch(
																		tile.tileset.image, 
																		map.width * map.height)
							end
							self._batches[tile.tileset]:addq(tile.quad, drawX+halfW, drawY-halfH, 0, flipX, flipY, halfW, halfH)
						else
							tile:draw(drawX+halfW, drawY-halfH, 0, flipX, flipY, halfW, halfH)
							-- If there's something in the _afterTileFunctions for this tile then call it
							at = self._afterTileFunctions[h][w] 
							if type(at) == "nil" then
							elseif type(at) == "function" then at(drawX, drawY)
							elseif type(at) == "table" then for i=1,#at do at[i](drawX, drawY) end end
						end -- sprite batches
					end --drawable tile
				end -- left to right
			end -- top to bottom
		end --orthogonal tiles
	

		-- Isometric tiles
		if map.orientation == "isometric" then
			local h, w
			-- Get the starting x drawing location
			draw_start = map.height * map.tileWidth/2
			-- Draw each tile starting from the top left tile. Make sure we have enough
			-- room to draw the widest and tallest tile in the map.
			for down=0,y2 do 
				for layer=0,1 do
					for right=0,x2 do
						h = y1 - right + down 
						w = x1	+ right + down + layer
						-- If there is a tile row
						if tileData[h] then
							-- Check and see if the tile is flipped
							-- 1 = flipped X;  2 = flipped Y;  3 = flipped X and Y
							flipX, flipY = 1, 1
							if self._flippedTiles[h] then
								if self._flippedTiles[h][w] then
									flipX = (self._flippedTiles[h][w] % 2) == 1 and -1 or 1
									flipY = (self._flippedTiles[h][w] / 2) >= 1 and -1 or 1
								end
							end
							-- Get the tile
							tile = tiles[ tileData[h][w] ]
							-- If the tile is drawable then draw the tile
							if tile ~= nil and tile ~= 0 then 
								-- Get the half-width and half-height
								halfW, halfH = tile.width*0.5, tile.height*0.5
								-- Get the tile draw location
								drawX = floor(draw_start + map.tileWidth/2 * (w - h-2))
								drawY = floor(map.tileHeight/2 * (w + h))
								-- Using sprite batches
								if useSpriteBatch then
									-- If we dont have a spritebatch for the current tile's tileset then make one
									if not self._batches[tile.tileset] then 
										self._batches[tile.tileset] = love.graphics.newSpriteBatch(
																				tile.tileset.image, 
																				map.width * map.height)
									end
									-- Add the tile to the sprite batch.
									self._batches[tile.tileset]:addq(tile.quad, drawX+halfW, drawY-halfH, 0, flipX, flipY, halfW, halfH)
								-- Not using sprite batches
								else
									tile:draw(drawX+halfW, drawY-halfH, 0, flipX, flipY, halfW, halfH)
									-- If there's something in the _afterTileFunctions for this tile then call it
									at = self._afterTileFunctions[h][w] 
									if type(at) == "nil" then
									elseif type(at) == "function" then at(drawX, drawY)
									elseif type(at) == "table" then for i=1,#at do at[i](drawX, drawY) end end
								end -- sprite batches
							end -- tile drawable
						end -- tile row
					end -- right
				end -- layer
			end -- down
		end --isometric
		
	end -- draw

	-- If sprite batches are turned on then render them
	if useSpriteBatch then
		for k,v in pairs(self._batches) do
			love.graphics.draw(v)
		end
	end
	
	-- Clears the draw list
	self:clearAfterTile()
	
	-- Change the color back
	love.graphics.setColor(r,g,b,a)
end

local ADDED_TO_RECT = -1

local function validTile(tile)
    return tile ~= nil and tile ~= 0
end

local function goRightWhileValid(x, y, targetWidth, tiles, tileData, tileWidth)
    local lengthRight = 0
    -- go right until we hit an invalid tile.
    -- we want to go horz first to make sure
    -- platforms are as smooth-feeling as possible
    for rightIter = x, targetWidth do
        if validTile(tiles[tileData[y][rightIter]]) then
            -- save the amount we went right in a variable
            lengthRight = lengthRight + tile.width
        else
            return lengthRight
        end
    end
    return lengthRight
end

local function setAddedToRect(x, y, targetWidth, tileData)
    for rightIter = x, targetWidth - 1 do
        -- set the tile as belonging to a rect.
        tileData[y][rightIter] = ADDED_TO_RECT
    end
end

local function goDownAndRightWhileValid(x, y, mWidth, mHeight, tiles, tileData, tileWidth, tileHeight)
    -- used to compress the map into rectangles instead of a large number of square tiles
    -- go down and right that var amount until we hit a row
    -- where at least one tile is invalid.
    -- set each tile to -1 as we go.

    -- First go right along starting at (x, y) until we hit an invalid tile. Store the amount we
    -- went right in targetRight
    local targetRight = goRightWhileValid(x, y, mWidth, tiles, tileData, tileWidth)
    -- The targetWidth in number of tiles
    local targetWidth = x + math.floor(targetRight / tileWidth)
    -- Mark each tile as added to the current rect along that line
    setAddedToRect(x, y, targetWidth, tileData)
    -- Starting one below the current height, go down one tile per iteration
    for downIter = y + 1, mHeight do
        -- Find out how far we can go right at this y level.
        local lengthRight = goRightWhileValid(x, downIter,
              targetWidth, tiles, tileData, tileWidth)
        -- If we couldn't go right as far as before, we can't extend the rectangle
        -- to this y position.
        if targetRight > lengthRight then
            return (downIter - y)*tileHeight, targetRight
        end
        setAddedToRect(x, downIter, targetWidth, tileData)
    end
    return (mHeight + 1 - y)*tileHeight, targetRight
end

function TileLayer:addToWorld(objectFactory)
    local physX, physY, lengthDown, lengthRight
    local rectifiedTileData = objectDeepcopy(self.tileData)
    for y = 1, self.map.height do
        for x = 1, self.map.width do
            tile = self.map.tiles[rectifiedTileData[y][x]]
            if validTile(tile) then
                lengthDown, lengthRight = goDownAndRightWhileValid(x, y, self.map.width,
                              self.map.height, self.map.tiles, rectifiedTileData, tile.width, tile.height)
                physX, physY = x*tile.width, y*tile.height
                halfW, halfH = lengthRight*0.5, lengthDown*0.5
                local groundPoints =
                {
                    Point(physX, physY), -- top left
                    Point(physX + lengthRight, physY), -- top right
                    Point(physX + lengthRight, physY + lengthDown), -- bottom right
                    Point(physX, physY + lengthDown), -- bottom left
                }
                objectFactory.createTile(groundPoints, Point(physX + halfW - tile.width, physY + halfH - tile.height))
            end
        end
    end
end
----------------------------------------------------------------------------------------------------
-- Private
----------------------------------------------------------------------------------------------------

-- Creates the tileData from a table containing each tile id in sequential order
-- from left-to-right, top-to-bottom.
function TileLayer:_populate(t)
	-- Some temporary storage
	local width, height =  self.map.width, self.map.height
	local flipX, flipY
	local i = 1
	-- The values that indicate flipped tiles are in the last two binary digits.
	local flipXVal, flipYVal = 2^31, 2^30
	self.tileData = {}
	-- Inset the tile data
	for y = 1,height do
		self.tileData[y] = {}
		for x = 1,width do
			-- If the tile is nil then make it zero
			if t[i] == nil then t[i] = 0 end
			-- Check for flipped tiles and store them in self._flippedTiles
			flipX = floor(t[i] / flipXVal)
			t[i] = t[i] % flipXVal
			flipY = floor(t[i] / flipYVal)
			t[i] = t[i] % flipYVal
			-- If a tile is flipped we need to make an entry for it
			-- 1 = flipped X;  2 = flipped Y;  3 = flipped X and Y
			if flipX ~= 0 or flipY ~= 0 then
				if not self._flippedTiles[y] then self._flippedTiles[y] = {} end
				self._flippedTiles[y][x] = flipX + flipY*2
			end
			self.tileData[y][x] =  t[i]
			i = i + 1
		end
	end
end

-- Return the TileLayer class
return TileLayer


--[[Copyright (c) 2011 Casey Baxter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.--]]
