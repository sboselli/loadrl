### DB

Game information is stored in a JSON db as a file.

The idea is for it to be easy to read, extend and update,
by anyone.

loadRL will attempt to use the latest online copy when
available, straight from the Github raw repo file.


### Schema

Every game in the db is stored as property of the main object.

Its key should be a unique slug for that specific game (and no other 
restrictions except no spaces).

The entry should comply with the following structure:

{
  "**slug**": { // (String) A slug with no spaces that uniquely identifies 
                          the game. (required) (unique)
    "name": (String) The game's full name. (required)
    "dev": (String) The game's developer/s. (required)
    "desc": (String) The game's description. This can a single paragraph
            or many, separated by two escaped newlines. Please use the 
            official source when available or rely on sources like 
            RogueBasin's description otherwise. (required)
    "tags": (Array) An array containing any applicable tags. (optional)
    "links": (Object) An object containing any related links, using titles
                      as Keys. Please try to include at least one link 
                      that establishes the source website. (required)
    "verions": { // (Object) An object containing Version metadata Objects
                        that use the specific version of the game as 
                        their Key. (required)
      "**version**": {
        "url": (String) The url for the source file. (required)
        "flags": (Array) An array containing optional flags that handle
                         special cases (see details below). (optional)
        "copy_files": (Array) An array used by the "copy_files" flag, that
                              contains two items indicating the source
                              file to be copied and the destination
                              folder. (optional)
        "path": (String) If the source zipped file has all files within 
                         its root folder you can leave this field empty.
                         If the contents are however within a folder in 
                         in the root of the compressed file, set this 
                         to indicate the name of the resulting root
                         folder. (required, can be empty)
        "exec": (String) The filename (without extension) of the 
                         game executable. (required)
      }
    }
    "disabled": (Boolean) Set to true to disable this game and prevent
                          loadRL from showing it in the list. (optional)
  }
}


Example:

{
  "decker": {
    "name": "Decker",
    "dev": "Shawn Overcash",
    "desc": "Decker is the name of the ones who break into corporate mainframes to perform missions from rival companies. In this tile-based cyberpunk RL, you are one of the deckers, running in cyberspace to earn skill and money to upgrade your equipment.\n\nThe player takes on the role of a hacker who wants to earn reputation and money. To achieve this, a decker signs contracts and enters computers systems to fulfill the current mission. Objectives include disabling security devices, crashing systems, retrieval and/or deletion of data, creation of backdoors and many more. For completing a contract, the player is awarded with reputation and money. Any valuable files downloaded while in cyberspace are sold and also added to credits. On the other hand, reputation may suffer if many missions are failed. In cyberspace, the player may hack into databases, fight various ICE (Intrusion Countermeasure programs), collect information, and several more activities. Sometimes source code is found and upon downloading can prove to be a valuable tool for the hacker to use. Gained money may be used to upgrade hardware, pay for treatment, new software and rental payment.\n\nThe game is divided into two contexts: inside the Matrix, when the player is invading systems, jacked to his cyberdeck; and in the real world, where you manage the character's life: from choosing jobs (or waiting for new ones) to developing new software, hardware, resting, shopping and paying the rent.",
    "tags": ["scifi"],
    "links": {
      "home": "https://web.archive.org/web/20110926115405/http://www10.caro.net/dsi/decker/",
      "guide": "https://drfrog.wordpress.com/2009/08/04/a-brief-introduction-to-decker-part-1-a-cyberpunk-hacking-roguelike/",
      "sourceforge": "https://sourceforge.net/projects/decker/",
      "roguebasin": "http://www.roguebasin.com/index.php?title=Decker"
    },
    "versions": {
      "1.12": {
        "url": "https://sourceforge.net/projects/decker/files/latest/download",
        "flags": ["copy_files"],
        "path": "bin",
        "exec": "Decker",
        "copy_files": ["DefaultGraphics", "bin\\DefaultGraphics"]
      }
    }
  },
}


### Flags

Flags are used to handle special cases some games might need
around downloading, extracting and installing.

These cases are highly specific and a "patch" of sorts to avoid
being unable to include a game. While the method is not really
scalable, the ocurrances are low enough to warrant some special
love. They try to be as generic as possible but ultimately solve
a specific case.

Currently, the following flags are defined:

* "double_extract": Tells loadRL to run a second extract on the
                    result of the first extraction. 
                    Added because of "omegawin".
* "copy_files": When this flag is found, loadRL will use the
                contents of the "copy_files" property within the
                version, to copy the source file to the dest dir.


### Adding/modifying games and versions

To submit new games or add new (or older) versions, simply
submit a pull request with the new data.


