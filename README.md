# > loadRL @ v0.1
-----------------

A free (free) roguelike loader.

https://github.com/sboselli/loadrl

---

### Intro

Here be roguelikes.

Old and new.
All of the major ones and some obscure jewels as well.

Please find the time to support these amazing devs by
visiting their homepage, following, donating and
buying their commercial games where available.

You'll find links in each game's details.

Visit our Github to stay updated.


### About

loadRL is intended to be a simple roguelike manager, 
with multiple version capabilities.

It handles sourcing, downloading, extracting, sorting
and storing games for you.

loadRL also features and ships with an integrated DOSBox,
which allows you to play old native DOS games (like the 
original versions of Rogue or Dungeon Crawl). This all
happens behind the scenes and you do not need to take 
any extra steps.

With literally a couple clicks you can go from zero 
to playing any game on the db, easily switching between 
versions if you need to (thank the devs who made
those clearly awful changes /s :) ).


### Installation

Unzip the contents of the zip anywhere. 


### Usage

1. Scroll through the list
2. Pick a roguelike
3. Click Install
4. Click Play

Use "Set Version" to choose a different version when available.


### DB

Game information is stored in a JSON db as a file.

The idea is for it to be easy to read, extend and update,
by anyone.

To submit new games or add new (or older) versions, simply
submit a pull request with the new information.

Refer to "README-db.txt" in the "docs" folder for more
information regarding the format.

loadRL currently supports checking to use the latest online copy 
when available, straight from the Github raw repo file. This 
option is however disabled by default.

To enable, edit the "config.json" file in loadRL's root dir
and set "use_online_db" to true.


### Paths & versions

Upon first run a "games" folder is created in loadRL's directory.

Games are installed under a standardized human readable structure, 
that makes versioning simpler:

"games\slug\slug-ver"

You can check how game information is stored by taking a look at 
the "db.json" file in the source.

When a new version is available for a game you currently have 
installed, you will see an update available indicator "(U!)" in
the "Set Version" button.

loadRL will never delete a game folder, putting at risk a game
in progress or savefile.


### Tools & DOSBox

loadRL relies on the shoulder of giants and ships with the following
amazing tools to make things possible:

  + curl: to download files
  + 7z: to extract games
  + DOSBox: to emuluate DOS for the older native games

Aditionally, for development, we also use:

  + Godot (3.1): to create the program itself
  + 7z: to create releases
  + rcedit: to edit the release exe
  + batch scripts: for build tooling
  + git & github: for version control, distribution & hosting
  + GIMP: for the icon & splash

You will find additional information & licenses for all of these 
within the "docs" folder.


### Build instructions

1. Open CMD and go to "build-scripts" folder.
2. Run "build-clean.cmd"
3. Export project from Godot:
  a. Use "Export Path": "{project-path}/bin/loadRL.exe"
  b. In the "Resources" tab, use "Export Mode": "Export all resources"
  c. In the "Resources" tab, set "Filters to Export" to "db.json, README.txt"
4. Run "build-post.cmd": You now have a complete working folder in "./bin"
5. Run "build-package.cmd" to get a distributable datestamped zip 
in current "build-scripts" folder


### Contributing

Feel free to submit any PR either to enrich the DB or for 
the program itself.
