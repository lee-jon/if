if
==

An interactive fiction game engine. RDoc available in the [docs](./docs) folder.

## Use
There are currently sample 'games' inanother repo . To play the games open a terminal and issue the following commands:

    git clone git@github.com:lee-jon/if.git
    git clone git@github.com:lee-jon/if-games.git
    ln -s if/games if-games

Make sure the yaml library is installed - this is required for saving and loading. If you want to use the data visualisation tools for development you will also need to install graph to output graphviz format, and svg2png. This may be replaced with a different form of serialisation & deserialisation when Ruby 2.0 comes out.

    gem install yaml

Run the game using:

    ruby if.rb

Run the game in debug mode to get access to the visualisation and debug commands

    ruby if.rb d

## Basics

### Data
The engine uses OpenStruct to create a tree of data. Each node has a parent node and can have multiple-child nodes. Rooms are the first child of the root node. Things in a room are hence children of that room, this includes the player node. Items that are children of the player are considered in inventory. Moving an item, or the player, removes it from the children of one node and adds it to another node. A good effect of this structure is there are no instance variables. `engine.rb` contains all the logic behind tree manipluation, visualisation, and searching.

### Describing the world
Game files are contained in a separate repo. At present there are no fully formed games, just fragments.

## Contributing
At present the engine is very alpha. Engine and player are the only files required to execute a game.

Methods should be documented with TomDoc wherever possible. Ruby standards should be common formatting guides. See GitHub's for a good example.
