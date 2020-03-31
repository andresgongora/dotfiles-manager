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
##	DESCRIPTION:
##	Run this script to symlink all your config files in place.
##
##	This script will look under the dir ./dotfiles/ where, if it finds
##	a "targets" text file, it will check if the current $USER@$HOST 
##	is in the list. If no file is present, it will continue.
##
##	Then, for every file, if said text file is accompanied by
##	a text file with the same name but preceded by ".link", it will link said
##	file to wherever the path/name in the "link." file specifies. This means
##	that the files and the symlink can have different names.
##	If the specified path ends in "/", the script will assume you want
##	the same name.
##
##	Symlinking also works for dirs. Just make sure they are accompanied
##	by a path-file with the same name but preceded by ".link".
##
##	If symlinking detects a conflict (e.g. the target file already exists)
##	it will prompt you.
##
##	Finally, if inside the current dir is another dir and it does not
##	have a "link.", the script will call itself recursively.
##


symlink()
{
	## CONFIGURATION
	#local verbose=true #Comment to reduce verbosity
	local target_file_name="targets"
	local user_dotfiles_basename="dotfiles"





	########################################################################
	##	parseDir
	##
	##	Artguments
	##	1. dir to parse
	##
	## 	parseDir searches for a target manifest file. It will check
	##	if the current $USER@$HOST is listed to decide if said dir
	##	and all its content is to be parsed. If it finds no targets
	##	manifest file, it will continue as if a match was found.
	##
	##	Once parsing a folder, it will search for any link.* file and,
	##	if the file/dir with the same name exist, use the content of
	##	said link.* file to call the link functio (see further below)
	##	on it. Note that the link.* file must contain a path.
	##	If, while parsing a dir, another sub_dir is found without a
	##	link.*, the script continues downwards.
	## 
	########################################################################
	parseDir()
	{
		local dir=$1
		local dir=$(echo "${dir/\./$PWD}")
		[ $verbose ] && printInfo "Parsing $dir"


		## CHECK TARGETS-MANIFETS FILE
		## * If it does not exist -> Parse dir
		## * If it exists and
		##   * $USER@$HOST is listed -> Parse dir
		##   * $USER@$HOST is NOT listed -> Exit function
		##
		if [ -f "${dir}/${target_file_name}" ]; then
			## CHECK FOR HOSTNAME
			local match=false
			while read line; do
				if [[ "${USER}@${HOSTNAME}" == "$line" ]]; then
					local match=true
					[ $verbose ] && printSuccess "${USER}@${HOSTNAME} found in targets file. Parsing $dir..."
					break
				fi
			done < "${dir}/${target_file_name}"

			## CHECK IF MATCH FOUND
			if [ $match == true ]; then
				: #nop
			else
				[ $verbose ] && printWarn "${USER}@${HOSTNAME} not in target file. Skipping..."
				return
			fi
		else
			[ $verbose ] && printWarn "No targets file found. Default behaviour: continue parsing..."		
		fi


		## PARSE DIRECTORY CONTENT
		## * For every $file in dir
		##   * If link.$file exists -> Link
		##   * If link does not exist
		##     * If it is a dir -> Enter recursively (parseDir)
		##     * It is another sort of file -> Ignore
		##
		for file in "$dir"/*; do
			[ -e "$file" ] || continue
			local link_file="$(dirname "$file")/link.$(basename "$file")"

			## IF PAIRED WITH LINK_FILE EXISTS -> LINK
			if [ -e "$link_file" ]; then
				local link_target=$(head -n 1 "$link_file")
				link "$file" "$link_target"

			## IF FOLDER WITHOUT LINK_FILE -> PARSE
			elif [ -d "$file" ]; then
				parseDir "$file"
			fi
		done
	}






	########################################################################
	##	LINK
	##
	##	Artguments
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


		## CREATE PARENT DIRECTORIES IF NEEDED
		dst_parent_dir=$(dirname "$dst")
		if [ ! -d "$dst_parent_dir" ]; then
			printInfo "Creating new directory to link dotfiles into: $dst_parent_dir."
			mkdir -p "$dst_parent_dir"
		fi


		## DECIDE ACTION TO EXECUTE (by default link, "l")
		## * If dst exists
		##   * If dst already points to src, do nothing, "a"
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
			if [ "$dst_link" == "$src" ]; then
				local action="a"

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
	local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$script_dir/bash-tools/bash-tools/user_io.sh"
	printHeader "Linking your dotfiles files..."
	parseDir "$script_dir/$user_dotfiles_basename"	
}


## CALL SCRIPT
symlink 

