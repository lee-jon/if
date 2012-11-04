if
==

An interactive fiction game engine.


## Data
The engine uses OpenStruct to create a tree of data. Each node has a parent node and can have multiple-child nodes. Rooms are the first child of the root node. Things in a room are hence children of that room, this includes the player node. Items that are children of the player are considered in inventory. Moving an item, or the player, removes it from the children of one node and adds it to another node. A good effect of this structure is there are no instance variables.

## Describing the world
there a


## Bugs & Issues
* At the minute everything can be opened or closed, which leads to some weird side effects. FIXED
* At the minute everything in a room can be taken.

* dead and new batteries in kitchen - if you have the remote and the drawer and type get batteries it doesn't see they're in a closed container.