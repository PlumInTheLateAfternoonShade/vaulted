local LuaUnit = require('luaunit.luaunit')
require('geometry.Seg')
require('geometry.Point')

Tests = {}

function Tests:testSegmentIntersects()
    -- Omit the colors. Because we can.
    local line11 = Seg(Point(0, 0), Point(2, 8))
    local line12 = Seg(Point(8, 0), Point(0, 20))

    local line21 = Seg(Point(0, 10), Point(2, 0))
    local line22 = Seg(Point(10, 0), Point(0, 5))

    local line31 = Seg(Point(0, 0), Point(0, 10))
    local line32 = Seg(Point(2, 0), Point(2, 10))

    local line41 = Seg(Point(0, 0), Point(5, 5))
    local line42 = Seg(Point(2, 0), Point(7, 5))
    
    local line51 = Seg(Point(0, 0), Point(5, 5))
    local line52 = Seg(Point(2, 2), Point(7, 7))

    local line61 = Seg(Point(0, 0), Point(5, 5))
    local line62 = Seg(Point(7, 7), Point(10, 10))
    
    local line71 = Seg(Point(0, 0), Point(5, 5))
    local line72 = Seg(Point(5, 5), Point(10, 10))
    
    local line81 = Seg(Point(0, 0), Point(5, 5))
    local line82 = Seg(Point(5, 5), Point(1, 9))
    
    assertEquals(line11:intersects(line12), false) -- No intersects
    assertEquals(line21:intersects(line22), true) -- Intersects
    assertEquals(line31:intersects(line32), false) -- Parallel, vertical
    assertEquals(line41:intersects(line42), false) -- Parallel, diagonal
    assertEquals(line51:intersects(line52), true) -- Collinear, overlap
    assertEquals(line61:intersects(line62), false) -- Collinear, no overlap
    assertEquals(line71:intersects(line72), true) -- Collinear, point overlap
    assertEquals(line81:intersects(line82), true) -- Point overlap
end

function Tests:testSegmentPointDist()
    -- TODO
end

LuaUnit:run()
