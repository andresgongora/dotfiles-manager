#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2016-2020, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+



##
##
##
##	DESCRIPTION:
##	Run this script to symlink all your config files under "dotfiles".
##
##	This script will traverse "./dotfiles" and all subdirectories. 
##	If it finds a "targets" manifest file, it will check if the current
##	$USER@$HOST is listed. If "targgets" exists and there is no match, said
##	directory and further subdirectories will be ignored. If there is
##	a match, or no "targets" file is present, the it will parse them.
##
##	In every directory to be parse, the script will search for a "link.*"
##	file. Every link file is paired with either a config file (aka dotfile)
##	or a direcotory (e.g. link.bashrc and bashrch), and contains the path
##	of where said file should be linked to. Files without a "link" are
##	either ignored, or in thec ase fo directories, treated as
##	subdirectories.
##
##
##
##	EXAMPLE:                         
##	Directory tree			File content
##
##	dotfiles
##	└── andresgongora		
##	    ├── misc
##	    │   ├── link.locale.conf ─── ~/.config/locale.conf
##	    │   └── locale.conf
##	    ├── ssh
##	    │   └──  ···
##	    ├── bashrc
##	    ├── link.basrch ──────────── ~/.bashrc
##	    ├── link.ssh ─────────────── ~/.ssh
##	    ├── loose_file
##	    └── targets ──────────────── andresgongora@pc
##	
##	Assuming the user is called andresgongora, and the host is pc, this
##	will enter dotfiles, see no targets manifest, and so enter the next
##	subfolder, in this case, andresgongora. Here, it checks the targets
##	manifest, and so decides to parse the folder (this is useful if
##	you have separete configs for separate accounts). Here, it will link
##	bashrc and the ssh dir. Then, it will look for files and dirs without
##	a "link." file. "loose_file" will be ignored, and "misc" will be
##	treated as a subfolder, repeating the process all over again (in this
##	case it will only link "~/.config/locale.conf").
##	
##
##





symlink()
{
	########################################################################
	##	parseDir
	##
	##	Artguments
	##	1. dir to parse
	##
	##	Traverse directory resursively in search for any configuration
	##	file whose name matches "${USER}@${HOSTNAME}.config".
	## 
	########################################################################
	parseDir()
	{
		local dir=$1
		local dir=$(echo "${dir/\./$PWD}")
		[ $verbose == true ] && printInfo "Parsing $dir"


		for file in "$dir"/*; do
			[ -e "$file" ] || continue

			## IF FILE
			## - Check if it matches ${USER}@${HOSTNAME} -> Parse
			if [ -f "$file" ]; then
				local file_name=$(basename "$file")			
				if [ "$file_name" == "${USER}@${HOSTNAME}.config" ]; then
					[ $verbose ] && printSuccess "Valid configuration file for ${USER}@${HOSTNAME} found: $file"
					parseConfigFile "$file"
				fi

			## IF DIR
			elif [ -d "$file" ]; then
				parseDir "$file"
			fi
		done
	}






	########################################################################
	##	parseConfigFile
	##
	##	Arguments
	##	1. configuration file to parse
	##
	##	Parses configuration file. For each line, if it contains a pair
	##	of paths, it creates a simlink from the first to the second. If
	##	the line starts with an "include" statement followed by a path
	##	to another configuration file, said file is parsed as well.
	##
	##	The path of the configuration files to be included and
	##	any src file (original to create link to) are relative to
	##	to dotfiles/config/ and dotfiles/doftfiles respectively.
	## 
	##	To ensure orderly processing, all includes and links are first
	##	added to separate arrays. At the end of this function, these
	##	arrays are processed (links before includes).
	##
	########################################################################
	parseConfigFile()
	{
		local config_file=$1
		local srcs=()
		local dsts=()
		local include_configs=()
		printInfo "Parsing $config_file"
		

		## READ LINE BY LINE
		## -r do not interpret escape characters
		while read -r line; do

			## REMOVE COMMENTS, DOUBLE SPACES, AND SKIP EMPTY LINES
			local line=$(echo "$line" | sed 's/#.*$//g; s/\s\s*/ /g')
			[ -z "$line" ] && continue


			## SEPARATE LINES
			## - To avoid issues with escaped whitespaces, replace them with '\a'
			## - Separate words
			## - Restore escaped whitespaces
			local line=$(echo "$line" | sed 's/\\\ /\a/g')	
			local word_count=$(echo "$line" | wc -w)
			local word_1=$(echo "$line" | cut -d " " -f 1 | sed 's/\a/ /g')
			local word_2=$(echo "$line" | cut -d " " -f 2 | sed 's/\a/ /g')
		
		
			## PROCESS LINE
			## - Check if include -> Save in array for later
			## - Symlink
			## - Warn if could not process
			if [ "$word_count" -eq 2 ] && [ "$word_1" = "include" ]; then
				new_include_config="$(dirname ${config_file})/$word_2"				
				if [ -f "$new_include_config" ]; then
					[ $verbose == true ] && printInfo "Found include statement $line"
					include_configs=("${include_configs[@]}" "$new_include_config")
				else
					printError "Could not include file: $include_file"
				fi

			elif [ "$word_count" -eq 2 ]; then
				[ $verbose == true ] && printInfo "Found link statement $line"
				local dst="${word_1/'~'/$HOME}"
				local src="$DOTFILES_ROOT/dotfiles/$word_2"	
				dsts=("${dsts[@]}" "$dst")
				srcs=("${srcs[@]}" "$src")

			else
				printWarn "Can not parse line in $config_file: $line"
			fi


		done < "$config_file"


		## CREATE LINKS
		[ $verbose == true ] && printInfo "Create links..."
		for i in "${!dsts[@]}"; do 
			local src="${srcs[$i]}"
			local dst="${dsts[$i]}"			
			link "$src" "$dst"
		done				


		## PARSE ALL INCLUDES IN ARRAY
		[ $verbose == true ] && printInfo "Parse included cofiguration files"
		for include_config in "${include_configs[@]}"; do
			echo ""
			parseConfigFile "$include_config"
		done
	}






	########################################################################
	##	LINK
	##
	##	Arguments
	##	1. src file/dir (original)
	##	2. dst file/dir (symlink to create)
	##
	##	This function creates a symlink from dst to src. However,
	## 	before linking, it creates the full path to src and
	##	then checks if the file already exists. If the file is already
	##	a link (i.e. you have run this script before) it continues
	##	as normal. If not, it will ask the user what to do.
	## 
	########################################################################
	link()
	{
		local src=$1 dst=$2
		local dst=$(echo "${dst/\~/$HOME}" )
		[ $verbose == true ] && printInfo "Trying to link $dst -> $src"


		## CHECK THAT SOURCE FILE EXISTS
		if [ ! -e "$src" ]; then
			printError "Failed linking $dst because I couldn't find $src"
			return
		fi


		## CREATE PARENT DIRECTORIES IF NEEDED
		dst_parent_dir=$(dirname "$dst")
		if [ ! -d "$dst_parent_dir" ]; then
			printInfo "Creating new directory to link dotfiles into: $dst_parent_dir"
			mkdir -p "$dst_parent_dir"
		fi


		## DECIDE ACTION TO EXECUTE (by default link, "l")
		## * If dst exists
		##   * If dst already points to src, do nothing, "a"
		##   * If same file (loopback), skip, "s"
		##   * If dst is a different file/dir
		##     * If global action not specified -> Ask user
		##     * If global action defined -> Retrieve gloabl action
		##
		local action="l"
		if [ -e "$dst" -o  -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

			## CHECK IF ALREADY SYMLINKED
			## readlink: print symbolic link or canonical file name
			##
			local dst_link=$(readlink "$dst")
			if [  -e "$dst" -a "$dst_link" == "$src" ]; then
				local action="a"

			## CHECK IF SAME FILE
			elif [ "$dst" == "$src" ]; then
				printErr "Trying to link to tiself $dst -> $src"
				local action="s"

			## IF NOT SYMLINKED, ASK USER WHAT TO DO
			elif [ -z "$GLOBAL_ACTION" ]; then

				local action=$(promptUser "File already exists: $dst ($(basename "$src"))" "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?" "sSoObB" "")
				case "$action" in
					S|O|B )		GLOBAL_ACTION="$action" ;;
					s|o|b )		;;
					*)		printError "Invalid option"; exit 1
				esac

			## UPDATE ACTION WITH GLOBAL IF DEFINED
			else
				local action="${GLOBAL_ACTION:-$action}"

			fi			
		fi


		## EXECUTE ACTION & LINK
		## * Handle action
		##   * Handle conflicting file, if any
		##   * Infor user
		##   * Return early if no symlink needed
		## * Create symlink
		##
		case "$action" in
			a)		printSuccess "Already linked $dst" 
					return;;

			s|S)		printInfo "Skipped $src"
					return ;;

			b|B )		mv "$dst" "${dst}.backup"
					printInfo "Moved $dst to ${dst}.backup" ;;

			o|O )		rm -rf "$dst"
					printWarn "Removed original $dst" ;;

			l)		;; #link

			*)		printError "Invalid option '$action'"; exit 1
		esac
		ln -s "$src" "$dst" && printSuccess "$dst -> $src"
	}






	########################################################################
	## MAIN
	########################################################################
	local verbose=false #Comment to reduce verbosity
	local DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$DOTFILES_ROOT/bash-tools/bash-tools/user_io.sh"
	printHeader "Linking your dotfiles files..."
	parseDir "$DOTFILES_ROOT/config"	
}


## CALL SCRIPT
symlink 

