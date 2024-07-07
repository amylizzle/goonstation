# Typhon Tiles
These tiles are used to generate the Typhon mining level. Each tile MUST be 15x15

## Name Format
The first four characters are used to indicate valid connections to that tile.
They are ordered N,E,S,W. "c" is used to indicate a totally clear connection. 
The centre tile is always "cccc" to indicate clear on all sides.
After the first underscore is the tile's name.
After the second underscore is a probability weighting from 0 to 100 inclusive.

## Tile Selection
When choosing a tile, every possible tile that can connect to established tiles
is put in a list, weighted by the probability. One is then selected at random.
