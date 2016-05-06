## Installation

To install and use my dotfiles, simply clone this repository anywhere you want and run the bootstrap
script. I recommend clonning the repository into ~/.doftiles, but if you anywhere else, bootstrap
will create ~/.doftiles as a simlink pointing to your installation. 

```sh
git clone https://github.com/andresgongora/dotfiles.git ~/.dotfiles	# clone in ~/.dotfiles
cd ~/.dotfiles								# cd to new folder
chmod +x ./bootstrap							# make script executable
./bootstrap								# run script
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
cd ~/.dotfiles								# cd to new folder
chmod +x ./bootstrap							# make script executable
./bootstrap								# run script
```
Now, if you want to update changes to your own dotfiles on github




This will symlink the appropriate files in `.dotfiles/home` to your home directory.



## Thanks

I forked [Zach Holman](https://github.com/holman)' excellent
[dotfiles](https://github.com/holman/dotfiles) before, the same as he did,
writing my own. Specially the file-linking part of the script is inspired by his code.
