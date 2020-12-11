**andresgongora's dotfiles** is an ultra simple multi-system dotfiles manager
  
Dotfiles are how you personalize and configure your system. Be it your bashrc
file, where you write your favorite aliases or run scripts, or your 
applications' user configuration.

Instead of reconfiguring each of your machines independently or copying your
configuration files manually, you can simply use this "dotfiles helper"
to keep all your sysmtems (or part of them) syncrhonized. These has the
following benefits.

- You can put all dotfiles files that are important to _you_ are in a single
  place rather than having them all over your system. The included `symlink.sh`
  script will create symbolink links (aka shortcuts) in all the needed places.
- Dotfiles can be easily synchronized as a git repository, using a cloud storage
  (e.g. Nextcloud), or from a central system over SSH, among others.
- You can apply the same configuration to several machines, or decide
  what parts they should share and what parts are unique. This also applies
  for different users on the same machine. 






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                                     Setup
<!--------------------------------------+-------------------------------------->

You may find specific details about the script in the next section. This section
only covers the setup process to get stated.

To install and use my dotfiles, simply clone this repository anywhere you want 
(recommended under `~/.dotfiles`) with the following command. 

```sh
git clone --recursive https://github.com/andresgongora/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then, place all the configuartion files you want under `~/.dotfiles/config/` 
and your "original" configuration files under `~/.dotfiles/dotfiles/`.
Just have a look at the included examples, it should be straight forward. 
Feel free to delete the examples once you no longer need them. 

Finally, run `symlink.sh` and follow the instructions on screen if prompted.

```sh
./symlink.sh
```



## Sync with GitHub

If you want to synchronize your files with github, instead of cloning my
repository, fork it and then clone yours (do not forget to do it recursively,
as this depends on [bash-tools](https://github.com/andresgongora/bash-tools)).


```sh
git clone --recusrive https://github.com/YOURGITHUBUSER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then, follow the installation and configuration procedure described above. That
is, create your own `config/` and `dotfiles/` using the included examples before
linking everything with:

```sh
./symlink.sh
```

Once you are pleased with the result, you may sync everything to your git
repository. This might look as follows:

```sh
cd ~/.dotfiles
git add .
git commit -m "Updating my dotfiles"
git push
```

Finally, you can clone your forked repository on any other machine and you will
have your dotfiles at hand. Just do not forget to symlink them with 
`./symlink.sh`.

**WARNING**: For security reasons and to avoid accidental uploads, this
repository (forked or now) has a `.gitignore` file that will (should) prevent
you from adding any folder that is named `ssh` or `gnupg`. These usually contain
private keys/data that should _never_ be made public, even if you put a
passphrase on them. But you are free to edit these rules if your case scenario
requires it.



## Sync over SSH

If you do not trust a git repository with your data, you can also copy and
link all your dotfiles over ssh. Simply place all configuration and files under
`config/` and `dotfiles/`, respectively, as in the standard setup process.
Then run the following command to copy _only_ the dotfiles to be symlinked and
to the remote machine and run the script there (replace `USER` and `HOST`).

You may choose between `rsync` and `unison` for the sync process.
If your local and remote user are the same, you do not need to specify it after
`--ssh HOST`. Likewise, if you have specified an SSH alias for the remote host,
you may use that instead.

### rsync
`rsync` only needs to be installed locally. However, it is unidirectional,
  meaning that all remote files will be overwriten with your local copy.
  
```sh
symlink.sh \
	-c ./config/USER@HOST.config \
	--ssh USER@HOST
	--rsync
```

### unison
`unison` needs to be installed in both machines (i.e. local and remote),
but it is bidirectional. After the first sync, any change you mande on the
remote machine will be synced back to your local copy.
  
```sh
symlink.sh \
	-c ./config/USER@HOST.config \
	--ssh USER@HOST
	--unison
```






<br/><br/>
<!--------------------------------------+-------------------------------------->
#                              Overview and details
<!--------------------------------------+-------------------------------------->

`symlink.sh` will traverse `./config` and all subdirectories in search for any
config file whose name matches `$USER@$HOME.config`. Any valid config file will 
be parsed line by line. Each line must contain two paths. The first path is
where you want to link your file to (i.e. where your system expects to find
a given file, like for example `~/.bashrc`). The second path is relative to
this folder's `./dotfiles/` and indicates the "original" file you want to link.
Both paths must be spearated by spaces or tabs. If you want to add spaces
_within_ any of the path, you must escape them with `\`
(e.g. `/home/user/folder\ with\ many\ spaces/`).

Your symlink-config files may also have include statements to other config files
that may no longer match `$USER@$HOME.config`. This is useful if you want to
share the configuration among several machines. To include a config file, just
add a line that starts with `include` followed by the relative path (relative to
the including config file) to the configuration file. For example, you can have
`.config/bob@pc.config` and `.config/bob@laptopt.config` both containing a 
single line `include shared/home.config`, and then a file
`.config/shared/home.config` with your actual symlink configuration.

Optionally, you may run `symlink.sh` on a specific config file even if its name
does not match the `$USER@$HOME.config` pattern. To do so, simply call the
script and pass the path to the configuration file as argument. For example,
assuming you are in the `dotfiles` dir, 
`./symlink.sh ./config/example@example.config`.






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
features like multi-user and multi-system compatibility. Over time, keeping
track of all the configuration files became very tedious when I had lots of
machines. I rewrote the script from scratch to use the very directory structure
of the repository to set the configuration. It worked and was easy to sync, but
became even more tedious to manage and debug. In the end, I've rewritten the 
script again to parse configuration files one more time, but made it a bit
smarter this time. 

Note that there are many great dotfile scripts out there.
Mine is just yet another of them. But I had lots of fun (re)writing it :)






<!--------------------------------------+-------------------------------------->
#                                    License
<!--------------------------------------+-------------------------------------->

Copyright (c) 2014-2021, Andres Gongora - www.andresgongora.com

* This software is released under a GPLv3 license.
  Read [license-GPLv3.txt](LICENSE),
  or if not present, <http://www.gnu.org/licenses/>.
* If you need a closed-source version of this software
  for commercial purposes, please contact the [authors](AUTHORS.md).

