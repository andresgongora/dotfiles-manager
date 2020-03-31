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
##	a text file with the same name but ended in ".to", it will link said
##	file to wherever the path/name in the ".to" file specifies. This means
##	that the files and the symlink can have different names.
##	If the specified path ends in "/", the script will assume you want
##	the same name.
##
##	Symlinking also works for dirs. Just make sure they are accompanied
##	by a path-file with the same name but ended in ".to".
##
##	If symlinking detects a conflict (e.g. the target file already exists)
##	it will prompt you.
##
##	Finally, if inside the current dir is another dir and it does not
##	have a ".to", the script will call itself recursively.
##


symlink()
{
	parseDir()
	{
		## PARAMETERS
		local target_file_name="targets"
		local dir=$1

		
		## CHECK & FIX PARAMETERS
		local dir=$(echo "${dir/\./$PWD}")


		#printInfo "Parsing $dir"


		## CHECK TARGETS FILE
		## * If file does not exist or current host is hosted -> Continue
		## * If file does exist but current host name is not listed -> Return
		##
		if [ -f "${dir}/${target_file_name}" ]; then
			## CHECK FOR HOSTNAME
			local match=false
			while read line; do
				if [[ "${USER}@${HOSTNAME}" == "$line" ]]; then
					local match=true
					#printSuccess "${USER}@${HOSTNAME} found in targets file. Parsing $dir..."
					break
				fi
			done < "${dir}/${target_file_name}"

			## CHECK IF MATCH FOUND
			if [ $match == true ]; then
				: #nop
			else
				#printWarn "${USER}@${HOSTNAME} not in target file. Skipping..."
				return
			fi
		else
			: #printWarn "No targets file found. Default behaviour: continue parsing..."		
		fi


		## LINK FILES
		## * For every file in the dir
		##   * If .to exists, link
		##   * If not, and is dir, traverse
		##
		## Note: done in two loops to parse files before subfolders
		##
		for file in "$dir"/*; do
			[ -e "$file" ] || continue	
			if [ -e "${file}.to" ]; then
				local link_target=$(head -n 1 "${file}.to")
				link "$file" "$link_target"
			fi
		done
		for file in "$dir"/*; do
			[ -e "$file" ] || continue
			if [ -e "${file}.to" ]; then
				: #nop
			elif [ -d "$file" ]; then
				parseDir "$file"
			fi
		done

	}


	link()
	{
		local src=$1 dst=$2
		local action="l"


		## CHECK & FIX PARAMETERS
		local dst=$(echo "${dst/\~/$HOME}" )


		## CREATE PARENT DIRECTORIES IF NEEDED
		dst_parent_dir=$(dirname "$dst")
		if [ ! -d "$dst_parent_dir" ]; then
			printInfo "Creating new directory to link dotfiles into: $dst_parent_dir."
			mkdir -p "$dst_parent_dir"
		fi


		## CHECK IF FILE ALREADY EXISTS
		## If it exists:
		##	1. Check if not linked already -> Skip
		##	2. If not linked
		##		2.A If global action NOT set (e.g. overwrite all) -> ask
		##
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
			fi
		fi

		## PROCESS FILE
		local action="${GLOBAL_ACTION:-$action}"
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

		
		## LINK
		ln -s "$src" "$dst" && printSuccess "$dst -> $src"

	}

	local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$script_dir/bash-tools/bash-tools/user_io.sh"


	printHeader "Linking your dotfiles files..."
	parseDir "$script_dir/dotfiles"
}


## CALL SCRIPT
symlink 

