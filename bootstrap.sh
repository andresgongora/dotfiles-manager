#!/bin/sh

# 1 TAB = 8 SPACES // LINE LENGTH = 100 CHARACTERS //

#	+-----------------------------------+-----------------------------------+
#	|                                                                       |
#	| Copyright (c) 2016, Andres Gongora <andresgongora@uma.es> 		|
#	|                                                                       |
#	| This program is free software: you can redistribute it and/or modify  |
#	| it under the terms of the GNU General Public License as published by  |
#	| the Free Software Foundation, either version 3 of the License, or     |
#	| (at your option) any later version.                                   |
#	|                                                                       |
#	| This program is distributed in the hope that it will be useful,       |
#	| but WITHOUT ANY WARRANTY; without even the implied warranty of        |
#	| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
#	| GNU General Public License for more details.                          |
#	|                                                                       |
#	| You should have received a copy of the GNU General Public License     |
#	| along with this program. If not, see <http://www.gnu.org/licenses/>.  |
#	|                                                                       |
#	+-----------------------------------------------------------------------+

#	AUTHOR'S NOTE:
#	-------------------------------------------------------------------------
#	This script is inspired by "holman does dotfiles", an excellent dotfiles
#	managment script I encourage you to check out if this one does not fit
#	your needs.
#	GIT: https://github.com/holman/dotfiles



####################################################################################################
#                                          FUNCTIONS                                               #
####################################################################################################

## Printing functions are from Zach Holman's dotfiles
## I really liked their aesthetics

printInfo () 
{
	printf "\r	[ \033[00;34m..\033[0m ] $1\n"
}

printUser () 
{
	printf "\r	[ \033[0;33m??\033[0m ] $1\n"
}

printSuccess () 
{
	printf "\r\033[2K	[ \033[00;32mOK\033[0m ] $1\n"
}

printFail () 
{
	printf "\r\033[2K	[\033[0;31mFAIL\033[0m] $1\n"
	echo ''
	exit
}




## linke_file() is heavily copied from Zach Holman's dotfiles. <https://github.com/holman/dotfiles>
## Copyright (c) Zach Holman, http://zachholman.com
## The MIT License
link_file () {
	local src=$1 dst=$2

	local overwrite= backup= skip=
	local action=

	## CHECK IF FILE ALREADY EXISTS
	if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
	then
		## IF GLOBAL CONFIGURATION NOT SET
		if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
		then
			local currentSrc="$(readlink $dst)"

			## IF ALREADY LINKED: SKIP
			if [ "$currentSrc" == "$src" ]
			then
				skip=true;
			else
				printUser "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
				[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
				read -n 1 action

				case "$action" in
					o )
						overwrite=true;;
					O )
						overwrite_all=true;;
					b )
						backup=true;;
					B )
						backup_all=true;;
					s )
						skip=true;;
					S )
						skip_all=true;;
					* )
						;;
				esac
				echo ''
			fi
		fi


		## USE GLOBAL CONFIGURATION IF SET
		overwrite=${overwrite:-$overwrite_all}
		backup=${backup:-$backup_all}
		skip=${skip:-$skip_all}


		## USER WANTS TO OVERWRITE
		if [ "$overwrite" == "true" ]
		then
			rm -rf "$dst"
			printSuccess "removed $dst"
		fi

		## USER WANTS TO OVERWRITE & BACKUP
		if [ "$backup" == "true" ]
		then
			mv "$dst" "${dst}.backup"
			printSuccess "moved $dst to ${dst}.backup"
		fi

		## SKIP THIS FILE
		if [ "$skip" == "true" ]
		then
			printSuccess "skipped $src"
		fi
	fi

	## UNLESS SKIP (SYMLINK DOES NOT EXISTS OR FILE MAS REMOVED), CREATE SYMLINK
	if [ "$skip" != "true" ]	# "false" or empty
	then
		ln -s "$1" "$2"
		printSuccess "linked $1 to $2"
	fi
}


## I rewrote install_dotfiles () from scarth to fit my needs
install_dotfiles () {
	local overwrite_all=false backup_all=false skip_all=false

	echo ''
	printInfo 'Installing dotfiles'



	## LINK TO DOTFILES FOLDER IN CASE THEY ARE NOT LOCATED IN ~/.dotfiles
	dotfiles="$HOME/.dotfiles"
	if [ -f "$dotfiles" -o -d "$dotfiles" -o -L "$dotfiles" ]
	then
		echo ''
	else
		local message="Linking $DOTFILES_ROOT to $dotfiles"
		printInfo "$message"
		ln -s "$DOTFILES_ROOT" "$dotfiles"
		echo ''
	fi



	## LINK DOT-FILES IN USER DIRECTORIE
	printInfo ~
	for src in $(find -H "$DOTFILES_ROOT/symlink" -maxdepth 1 -name '*.symlink' -not -path '*.git*')
	do
		dst="$HOME/.$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
	echo ''



	## LINK INSIDE DOT_FOLDERS INSIDE USER DIRECTORIE
	for folder in $(find $DOTFILES_ROOT/symlink/* -maxdepth 0 -type d )
	do
		dotfolder="$HOME/.$(basename $folder)"
		printInfo $dotfolder
		for src in $(find -H "$DOTFILES_ROOT/symlink/config" -maxdepth 1 -name '*.symlink' -not -path '*.git*')
		do
			dst="$dotfolder/$(basename "${src%.*}")"
			link_file "$src" "$dst"
		done
		echo ''
	done


	echo '	All installed!'
	echo ''
}



####################################################################################################
#                                            SCRIPT                                                #
####################################################################################################


## IF ANYTHING FAILS: EXIT
set -e

## ENTER FOLDER CONTAINING THIS SCRIPTS. FILES TO BE BOOTSTRAPPED ARE EXPECTED TO BE IN SUBFOLDERS
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)		# Store physical address, avoid symlinks


## LINK ALL
install_dotfiles


# EOF

