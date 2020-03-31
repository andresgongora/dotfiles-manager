**andresgongora's dotfiles** is an ultra simple multi-system dotfiles manager
  
Dotfiles are how you personalize and configure your system. Be it your bashrc
file where you write your favorite aliases or run scripts, or your applications'
user configuration.

Instead of reconfiguring each of your machines independently or copying your
configuration files manually, you can simply use this "dotfiles" helper
to keep all your sysmtems (or part of them) syncrhonized. These brings the
following benefits.

- All configuration files that are important to _you_ are in a single place
  rather than all over your system. The included `symlink.sh` script will
  create symbolink links (aka shortcuts) in all the needed places.
- Dotfiles can be easily synchronized as a git repository.
- You can easily sync several machines with the same configuration, or decide
  what parts they should share and what parts are unique. These also applies
  for different users on the same machine. Now you have full control over your
  user's configuration and root's configuration.






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                                     Setup
<!--------------------------------------+-------------------------------------->

To install and use my dotfiles, simply clone this repository anywhere you want 
(recommended under ~/.dotfiles) with the following command.

```sh
git clone --recursive https://github.com/andresgongora/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then, place all the configuartion files you want under `~/.dotfiles`, fill in
your `targets` manifest file (if you want) and specify where the links should go
in the `link.*` files (you have to create them individually). Once everything is 
setup, symply run `symlink.sh` and follow the instructions on scree.

```sh
./symlink.sh
```


### Sync with github

If you want to synchronize your files with github, instead of cloning my
repository, fork it and then clone yours (do not forget to do it recursively,
as this depends on [bash-tools](https://github.com/andresgongora/bash-tools)).
Then follow the installation and configuration procedure just as before, and 
you will be able to push your files to Github or any other site you like.
This might look like:

Then:

```sh
git clone --recusrive https://github.com/YOURGITHUBUSER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles                                                          # cd to new folder
```
Add your files, links, targets, etc. and link them

```sh
./symlink.sh
```

Now, you may also sync all your files with Github

Now, if you want to update changes to your own dotfiles on github

```sh
cd ~/.dotfiles
git add .
git commit -m "Updating my dotfiles"
git push
```






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                                    Overview
<!--------------------------------------+-------------------------------------->

`symlink.sh` will traverse `./dotfiles` and all subdirectories. 
If it finds a `targets` manifest file, it will check if the current
`$USER@$HOST` is listed. If "targgets" exists and there is no match, said
directory and further subdirectories will be ignored. If there is
a match, or no "targets" file is present, the it will parse them.

In every directory to be parse, the script will search for a `link.*`
file. Every link file is paired with either a config file (aka dotfile)
or a direcotory (e.g. `link.bashrc` and `bashrch` are a pair), and contains 
the path of where said file should be linked to. Files without a `link.` are
either ignored, or in the case fo directories, treated as subdirectories.

For example:
```
Directory tree			File content

dotfiles
└── andresgongora		
    ├── misc
    │   ├── link.locale.conf ─── ~/.config/locale.conf
    │   └── locale.conf
    ├── ssh
    │   └──  ···
    ├── bashrc
    ├── link.basrch ──────────── ~/.bashrc
    ├── link.ssh ─────────────── ~/.ssh
    ├── loose_file
    └── targets ──────────────── andresgongora@pc
```

Assuming the user is called `$USER=andresgongora`, and the host is `$HOST=pc`, 
this will enter the direrctory `dotfiles`, see no targets manifest, and so enter
the next subfolder, in this case, `andresgongora`. Here, it checks the `targets`
manifest, and so decides to parse the folder (this is useful if
you have separete configs for separate accounts). Here, it will link
`bashrc` and `ssh/`. Then, it will look for files and dirs without
a `link.` file. `loose_file` will be ignored, and `misc` will be
treated as a subfolder, repeating the process all over again (in this
case it will only link `~/.config/locale.conf`).






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                                   Contribute
<!--------------------------------------+-------------------------------------->

This project is only possible thanks to the effort and passion of many, 
including developers, testers, and of course, our beloved coffee machine.
You can find a detailed list of everyone involved in the development
in [AUTHORS.md](AUTHORS.md). Thanks to all of you!

If you like this project and want to contribute, you are most welcome to do so.



### Help us improve

* [Report a bug](https://github.com/andresgongora/synth-shell/issues/new/choose): 
  if you notice that something is not right, tell us. We'll try to fix it ASAP.
* Suggest an idea you would like to see in the next release: send us
  and email or open an [issue](https://github.com/andresgongora/synth-shell/issues)!
* Become a developer: fork this repo and become an active developer!
  Take a look at the [issues](https://github.com/andresgongora/synth-shell/issues)
  for suggestions of where to start. Also, take a look at our 
  [coding style](coding_style.md).
* Spread the word: telling your friends is the fastes way to get this code to
  the people who might enjoy it!






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                                     About
<!--------------------------------------+--------------------------------------> 

My first version of the script was heavily inspired by 
[Zach Holman](https://github.com/holman)' dotfiles.
I modified it to work with configuration files and, over time, added more
features like multi-user and multi-system compatibility. However, keeping
track of all the configuration files became very tedious when I had lots of
machines. As a result, I've rewritten my dotfiles from scratch and this time
rely on the very directory structure of where I store my files to separate
(or sahre) my configration between machines. Note that there are many great
dotfile scripts out there. Mine is just yet another of them. But I had lots
of fun writing it :)

