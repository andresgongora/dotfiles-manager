# Andy's dotfiles

## Installation

To install and use my dotfiles, simply clone this repository anywhere you want and run the bootstrap
script. I recommend clonning the repository into ~/.doftiles, but if you anywhere else, bootstrap
will create ~/.doftiles as a simlink pointing to your installation. 

```sh
git clone https://github.com/andresgongora/dotfiles.git ~/.dotfiles     # clone in ~/.dotfiles
cd ~/.dotfiles                                                          # cd to new folder
chmod +x ./bootstrap                                                    # make script executable
./bootstrap                                                             # run script
```

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


## Structure

- **boostrap.sh**: this is the core of any dotfiles implementation. This script is in charge of 
linking all your actual dotfiles in place where the system expects to find them.
- **functions/**: this folder contains some bash functions I like carrying arround, like for example
colorizing your bash promt. You might delete the whole folder if you dont want it.
- **symlink**: store all dotfiles you want to be symlinked in this folder. Simply rename them
removing the initial dot (.) (it will be added automatically when you run bootstrap) and append
".symlink" to the end of the file or folders name.



## How to

Any file in **symlink** get renamed and symlinked to your users folder. For example, 
`symlink/bashrc.symlink` gets linked to `~/.bashrc`. 

Also, any files in sobfolders
get symlinked to they dotfolder equivalent. For example `symlink/config/locale.conf.symlink` gets
symlinked to `~/.config/locale.conf` (note that only the first level of files or folders inside 
`symlink` get renamed with a dot (.) in front).

You can even symlink folders. `symlink/mozilla.symlink/` gets linked to `~/.mozilla/`.




## Thanks

I forked [Zach Holman](https://github.com/holman)' excellent
[dotfiles](https://github.com/holman/dotfiles) before, the same as he did,
writing my own. Specially the file-linking part of the script is inspired by his code.
