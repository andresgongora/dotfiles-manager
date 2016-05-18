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

## Printing functions are like Zach Holman's dotfiles
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




## linke_file() is heavily inspired by Zach Holman's dotfiles. <https://github.com/holman/dotfiles>
## Copyright (c) Zach Holman, http://zachholman.com
## The MIT License
## Modified to work when reading files
## Smaller fixes
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


				## THIS IS NECESSARY BECAUSE LESE THE INPUT IS TAKEN FROM THE CONFIG FILE
				exec 6<&0
				exec 0<"$THISTTY"
				read -n 1 action
				exec 0<&6 6<&-
				

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
						printFail "$action is not a valid option";;
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
		ln -s "$src" "$dst"
		printSuccess "linked $src to $dst"
	fi
}



## Processes a configuration file passed as argument
## Original function by Andres Gongora
## Seaches inside /configuration folder for either a configuration file name like this host
## or alternatively a default configuraiton file if the previous is not found.
processConfigFile()
{
	local config_file=$1
	local overwrite_all=false backup_all=false skip_all=false
	
	echo ''
	printInfo "reading "$config_file""
	
	## READ LINE BY LINE
	while read line || [[ -n "$line" ]]; do
	
		## SKIP CERTAIN LINES
		[[ -z $line ]] && continue 		# empty line
		[[ "$line" =~ ^#.*$ ]] && continue	# commented line
		
		
		## CUT OUT COMMENTS
		line=$(echo $line | cut -d "#" -f 1 | tr -d '\n')
	
		
		## LINE DATA
		word_count=$(echo $line | wc -w)
		word_1=$(echo $line | cut -d " " -f 1)
		word_2=$(echo $line | cut -d " " -f 2)
	
		
		## CHECK IF IT IS A INCLUDE STATEMENT
		if [ "$word_count" -eq 2 ] && [ "$word_1" = "include" ]
		then
			include_file="$(dirname ${config_file})/$word_2"
			
			if [ -f "$include_file" ]
			then
				printInfo "include "$include_file""
				processConfigFile "$include_file"
				echo ''
				printInfo "reading "$config_file""
				
			else
				printFail "Could not include file: "$new_include_file""
			fi
		
		
		## CHECK IF IT IS A SYMLINK STATEMENT
		elif [ "$word_count" -eq 2 ]
		then
			dst="${word_1/'~'/$HOME}"
			src="$DOTFILES_ROOT/symlink/$word_2"
			
			link_file $src $dst
		
		
		## THIS LINE COULD NOT BE PROCESSED
		else
			printInfo "This line could not be processed:"
			echo "               > $line"
		fi
		
		
		
	done < "$config_file"
	
}



## Main function called by bootstrap. All the magic happens here
## By Andres Gongora
symlink()
{
	echo ''
	printInfo 'Installing dotfiles!'


	## LINK TO ~/.dotfiles
	dotfiles_home="$HOME/.dotfiles"
	if ! [ -f "$dotfiles_home" -o -d "$dotfiles_home" -o -L "$dotfiles_home" ]
	then 
		link_file $DOTFILES_ROOT $dotfiles_home
	fi
	
	
	## SEARCH FOR CONFIGURATION FILE
	printInfo "Searching for configuration file:"
	echo "               "$DOTFILES_ROOT/configuration/$(hostname)".conf"
	
	if [ -f "$DOTFILES_ROOT/configuration/$(hostname).conf" ]; then
		configuration_file="$DOTFILES_ROOT/configuration/$(hostname).conf"
	else
		printInfo "Not found. Searching now for:"
		echo "               "$DOTFILES_ROOT/configuration/default""
		
		if [ -f "$DOTFILES_ROOT/configuration/default.conf" ]; then
			printInfo "Found!"
			configuration_file="$DOTFILES_ROOT/configuration/default.conf"
		fi
	fi
	
	
	## PROCESS CONFIGURATION FILE	
	if [ ! -z $configuration_file ]; then
		printInfo "Found!"
		processConfigFile "$configuration_file"
	else	
		printFail "No configuration file found"
	fi

	
	echo ''
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
THISTTY=$(tty)

symlink


# EOF

