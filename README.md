if
==

An interactive fiction game engine. RDoc available in the [docs](./docs) folder.

## Use
There are currently sample 'games' in the repo. To play the games open a terminal and issue the following commands:

    git clone git@github.com:lee-jon/if.git
    cd if

Make sure the yaml library is installed - this is required for saving and loading. If you want to use the data visualisation tools for development you will also need to install graph to output graphviz format, and svg2png.

    gem install yaml

Run the sample game using

    ruby game.rb


## Basics

### Data
The engine uses OpenStruct to create a tree of data. Each node has a parent node and can have multiple-child nodes. Rooms are the first child of the root node. Things in a room are hence children of that room, this includes the player node. Items that are children of the player are considered in inventory. Moving an item, or the player, removes it from the children of one node and adds it to another node. A good effect of this structure is there are no instance variables.

### Describing the world
(TODO)

## Contributing
At present the engine is very alpha. Engine and player are the only files required to execute a game.

Methods should be documented with TomDoc wherever possible. Ruby standards should be common formatting guides. See GitHub's for a good example.

### Bugs & Issues
This is an adaption from Michael Morin's game engine published Nov 2011. The following issues exist with that implementation.
* At the minute everything can be opened or closed, which leads to some weird side effects. FIXED
* At the minute everything in a room can be taken.
