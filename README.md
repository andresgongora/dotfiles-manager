# Andy's dotfiles

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



## Fast installation

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
search for a configuartion file named `default`.
- **symlink**: store all dotfiles you want to be symlinked in this folder. All configuration files
use these folder as symlink root.
- **functions/**: this folder contains some bash functions I like carrying arround, like for example
colorizing your bash promt. You might delete the whole folder if you dont want it.



## How to





## Thanks

I used to fork [Zach Holman](https://github.com/holman)' excellent
[dotfiles](https://github.com/holman/dotfiles) in the past. But after some time following
his example, I wrote my won implementation to better fit my own needs inspiring myself
on his code.
