# Andy's dotfiles

### Ultra simple dotfile manager with even simpler configuration files

Dotfiles are how you personalize and configure your system. Be it your bashrc file
where you write your favorite aliases or run scripts, or your program's user configuration.

Instead of reconfiguring each of your machines independently, you could manually copy
all dotfiles from one to another. Or... 

Or you could sync your dotfiles to github and use this simple script to link them in place.
This way you also have get following benefits:

- You have all your dotfiles in the same place instead of having them spread all over.
The bootstrap script creates all needed symlinks in the correct places.
- You have a backup of your dotfiles.
- You can easily sync several machines with the same configuration.



## Fast installation: recommended

To install and use my dotfiles, simply clone this repository anywhere you want and run the bootstrap
script. I recommend clonning the repository into ~/.doftiles, but if you anywhere else, bootstrap
will create ~/.doftiles as a simlink pointing to your installation. 

```sh
git clone https://github.com/andresgongora/dotfiles.git ~/.dotfiles     # clone in ~/.dotfiles
cd ~/.dotfiles                                                          # cd to new folder
chmod +x ./bootstrap                                                    # make script executable
./bootstrap                                                             # run script
```


## Forked installation: sync your own dotfiles with github

Alternatively, if you wish to sync your dotfiles to github (in case you want to sync several
machines), do the following:

"FORK" this repository on github. If you don't know what forking is, it basically creates
a separate copy of a git project that does not sync with the original, but with itself instead.
That is, you get a copy of my dotfiles on your github repository that you can change and update
at your will.

Then:

```sh
git clone https://github.com/YOURGITHUBUSER/dotfiles.git ~/.dotfiles	# clone your dotfiles in ~/.dotfiles
cd ~/.dotfiles                                                          # cd to new folder
chmod +x ./bootstrap                                                    # make script executable
./bootstrap                                                             # run script
```
Now, if you want to update changes to your own dotfiles on github

```sh
cd ~/.dotfiles                                                          # cd to your dotfiles folder
git add .                                                               # add changes
git commit -m "WRITE YOUR COMMENT HERE"                                 # commit changes
git push                                                                # push them to github
```


## File and folder structure

- **boostrap.sh**: this is the core of any dotfiles implementation. This script is in charge of 
linking all your actual dotfiles in place where the system expects to find them.
- **/configuration**: `bootstrap.sh` searches for configuration files inside this folder. It will
first search for a file with the same name as the host you are on, and if not found, it will
search for a configuartion file named `default`. This is useful when you want slightly different
configurations for different machines. Note that configuration files can "include" other 
configuration files for greater flexibility.
- **/symlink**: store all dotfiles you want to be symlinked in this folder. All configuration files
use these folder as symlink root.
- **/functions/**: this folder contains some bash functions I like carrying arround, like for example
colorizing your bash promt. You might delete the whole folder if you dont want it.



## How to

In six simple steps you will be set up! :)

Because I know you wont read this ;) simply check out my configuration files and how I use them.
Note that `dell` and `light` are the name of some of my machines.

When reffereing to the `dotfile/` folder, it will be located wherever you have cloned this repository,
which will be (if you did the fast installation) in `~/.doftiles`. 
`~` denotes your user's home folder. For example /home/john/.dotfiles/



1. **Copy all files you want to symlink**: copy them into `dotfiles/symlink/`. You may create
subfolders as required
2. **Configure your symlinks**: go to `dotfiles/configuration/` and create a file named either
`default.conf` or alternatively YOUR-HOSTS-NAME.conf.
Dotfiles will always look for a configuraiton file with the same name as the hosts, 
and if it finds none it then looks for a default configuration file.
3. **Include additional configuration files**: inside your main configuration file (created in
step 2) you may add other configuration files using the `include` directive. You may specify
a full path to the configuration path relative to `dotfiles/configuration/`.
4. **Create symlinks**: simply write inside your configuration, in one line, where to create the
symlink (full path) and which file to symlink to (path relative to `dotfiles/symlink/`).
5. **Execute bootstrap**: the script may prompt you if any conflict is detected.
6. **Optionally create a backup of your dotfiles**: either by pushing your fork to github
or by simply copying your doftiles folder to a secure place. 




## Thanks

I used to fork [Zach Holman](https://github.com/holman)' excellent
[dotfiles](https://github.com/holman/dotfiles) in the past. But after some time following
his example, I wrote my won implementation to better fit my own needs inspiring myself
on his code.
