//  Mark Maxham’s Fast Sweeper algorithm 
//  might be interesting if my own funky algorithm is ever not good enough.
var grid = this.getNavGrid().grid;
var tileSize = 4;
var occ = function(x, y) { return grid[y][x].length > 0; };
var occCol = function(x, y1, y2) {
    for (var j = y1; j < y2; j++) 
        if (occ(x, j))
            return true;
    return false;
};
var addRectAndMark = function(x1, y1, x2, y2) { 
    // the args list for addRect is not to my liking
    this.addRect(x1 + (x2-x1)/2, y1 + (y2-y1)/2, x2-x1, y2-y1);
    // alas, adding a rect doesn't mark the grid filled
    for (var x = x1; x < x2; x += tileSize)
        for (var y = y1; y < y2; y += tileSize)
            grid[y][x] = 'x'; // FIXME structure unknown
};
for (var x = 0; x + tileSize < grid[0].length; x += tileSize) {
    for (var y = 0; y + tileSize < 93; y += tileSize) {
        var y2 = y; // note our current y
        while (!occ(x, y2)) { // sweep thru y to expand 1xN rect
            y2 += tileSize;
        }
        if (y2 > y) { // if we got a hit, now sweep X with that swath
            var x2 = x + tileSize;
            while (!occCol(x2, y, y2)) {
                x2 += tileSize;
            }
            // whatever size we ended up with, 
            // make the rect, mark those squares used
            addRectAndMark.call(this, x, y, x2, y2);
            y = y2;
            this.wait();  
        }
    }
}

