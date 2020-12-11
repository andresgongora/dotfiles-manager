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
##	DESCRIPTION:
##	Run this script to symlink all your config files under "dotfiles".
##
##	`symlink.sh` will traverse `./config` and all subdirectories in search
##	for any config file whose name matches `$USER@$HOME.config`. Any valid
##	config file will be parsed line by line. Each line must contain two
##	paths. The first path is where you want to link your file to
##	(i.e. where your system expects to find a given file, like for example
##	`~/.bashrc`). The second path is relative to this folder's `./dotfiles/`
##	and indicates the "original" file you want to link. Both paths must be
##	spearated by spaces or tabs. If you want to add spaces _within_ any of
##	the path, you must escape them with `\` 
##	(e.g. `/home/user/folder\ with\ many\ spaces/`).
##	
##	Your symlink-config files may also have include statements to other
##	config files that may no longer match `$USER@$HOME.config`. This is
##	useful if you want to share the configuration among several machines.
##	To include a config file, just add a line that starts with `include`
##	followed by the relative path (under `./config/`) to the configuration
##	file. For example, you can have `.config/bob@pc.config` and 
##	`.config/bob@laptopt.config` both containing a  single line
##	`include shared/home.config`, and then a file
##	`.config/shared/home.config` with your actual symlink configuration.
##
##



symlink()
{
	########################################################################
	## @brief Process either a config file or traverse a config directory
	##
	## @param config file or directory
	##
	########################################################################
	parseConfig()
	{
		local config=$1
		
		if [ -z $config ]; then
			printError "No config target specified"
			exit 1
		elif [ -d $config ]; then
			parseConfigDir $config	
		else # is file
			parseConfigFile $config
		fi	
	}
	
	
	
	


	########################################################################
	## @brief Traverse directory resursively in search for any configuration
	##        file whose name matches "${USER}@${HOSTNAME}.config".
	##
	## @param dir to parse
	##
	########################################################################
	parseConfigDir()
	{
		local dir=$1
		[ $VERBOSE == true ] && printInfo "Parsing directory $dir"


		for file in "$dir"/*; do
			[ -e "$file" ] || continue

			## IF FILE
			## - Check if it matches ${USER}@${HOSTNAME} -> Parse
			if [ -f "$file" ]; then
				local file_name=$(basename "$file" | sed 's/\*/\.\+/g')
				if [[ "${USER}@${HOSTNAME}.config" =~ $file_name ]]; then
					[ $verbose ] && printSuccess "Valid configuration file for ${USER}@${HOSTNAME} found: $file"
					parseConfigFile "$file"
				fi

			## IF DIR
			elif [ -d "$file" ]; then
				parseConfigDir "$file"
			fi
		done
	}






	########################################################################
	## @brief Parse configuration file to extract link instruction and
	##        recursive file inclusions.
	##
	## Parses configuration file. For each line, if it contains a pair
	## of paths, it creates a simlink from the first to the second. If
	## the line starts with an "include" statement followed by a path
	## to another configuration file, said file is parsed as well.
	##
	## The path of the configuration files to be included and
	## any src file (original to create link to) are relative to
	## to dotfiles/config/ and dotfiles/doftfiles respectively.
	## 
	## To ensure orderly processing, all includes and links are first
	## added to separate arrays. At the end of this function, these
	## arrays are processed (links before includes).
	##
	## @param configuration file to parse
	##
	########################################################################
	parseConfigFile()
	{
		local config_file=$1
		local srcs=()
		local dsts=()
		local include_configs=()
		
		
		printInfo "Parsing configuartion-file $config_file"
					
		
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
			if [ $word_count -eq 2 ] && [ "$word_1" = "include" ]; then
				new_include_config="$(dirname ${config_file})/$word_2"				
				if [ -f "$new_include_config" ]; then
					[ $VERBOSE == true ] && printInfo "Found include statement $line"
					include_configs=("${include_configs[@]}" "$new_include_config")
				else
					printError "Could not include file: $include_file"
				fi

			elif [ $word_count -eq 2 ]; then
				[ $VERBOSE == true ] && printInfo "Found link statement $line"
				local dst="${word_1/'~'/$HOME}"
				local src="$DOTFILES_ROOT/dotfiles/$word_2"	
				dsts=("${dsts[@]}" "$dst")
				srcs=("${srcs[@]}" "$src")

			else
				printWarn "Can not parse line in $config_file: $line"
			fi


		done < "$config_file"
		
		
		## PROCESS LINK LIST
		if [ $LIST_FILES_ONLY == true ]; then
			## STORE LISTS
			[ $VERBOSE == true ] && printInfo "Storing link list for $config_file"
			echo $config_file >> $DOTFILES_CFG_LIST_FILE
		
			for i in ${!dsts[@]}; do 
				local src=${srcs[$i]}
				local dst=${dsts[$i]}		
				echo $src >> $DOTFILES_SRC_LIST_FILE
				echo $dst >> $DOTFILES_DST_LIST_FILE
			done
		
		
		else
			## CREATE LINKS
			[ $verbose == true ] && printInfo "Create links..."
			for i in "${!dsts[@]}"; do 
				local src="${srcs[$i]}"
				local dst="${dsts[$i]}"			
				link "$src" "$dst"
			done	
		fi
		
		
		## PARSE ALL INCLUDES STORED IN ARRAY
		[ $VERBOSE == true ] && printInfo "Parsing cofiguration files included by $config_file"
		for include_config in "${include_configs[@]}"; do
			echo ""
			parseConfigFile $include_config
		done
	}







	########################################################################
	## @brief create symlink between source and destiny.
	##
	## This function creates a symlink from dst to src. However,
	## before linking, it creates the full path to src and
	## then checks if the file already exists. If the file is already
	## a link (i.e. you have run this script before) it continues
	## as normal. If not, it will ask the user what to do.
	##
	## @param src file/dir (original)
	## @param dst file/dir (symlink to create)
	##
	########################################################################
	link()
	{
		local src=$1 dst=$2
		local dst=$(echo "${dst/\~/$HOME}" )
		[ $VERBOSE == true ] && printInfo "Trying to link $dst -> $src"


		## CHECK THAT SOURCE FILE EXISTS
		if [ ! -e "$src" ]; then
			printError "Failed linking $dst because $src does not exist"
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
			if [ -e "$dst" -a "$dst_link" == "$src" ]; then
				local action="a"

			## CHECK IF SAME FILE
			elif [ "$dst" == "$src" ]; then
				printError "Trying to link to tiself $dst -> $src"
				local action="s"

			## IF NOT SYMLINKED, ASK USER WHAT TO DO
			elif [ -z "$GLOBAL_ACTION" ]; then

				local action=$(promptUser \
				               "File already exists: $dst ($(basename "$src"))" \
				               "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?" "sSoObB" "")
				               
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
	## @brief Copy dotfiles and create symlinks on remote machine.
	##
	## Copies with rsync/unison all your files to the specified target and
	## symlinks the configuartion in place. This function relies heavily
	## on `rsync`'s include and exclude rules.
	##
	## @param target "username@host" to connect to
	##
	########################################################################
	sshSymlink()
	{
		local host=$1
		local local_dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
		local remote_dotfiles_dir=".dotfiles"
		local include_filter_file="/tmp/andresgongora_dotfiles_include.filter"		
		

		## INCLUDE ALL FILES LISTED BY `parseConfig`
		## Edit file/dir paths to convert into filters
		echo "" > $include_filter_file
		cat $DOTFILES_CFG_LIST_FILE >> $include_filter_file
		cat $DOTFILES_SRC_LIST_FILE >> $include_filter_file
		sed -i '/^$/d;s/$//;s/\.\///' $include_filter_file
		sed -i "s:$local_dotfiles_dir/::" $include_filter_file	
		[ $VERBOSE == true ] && \
			printInfo "Local files to be copied:\n" &&\
			cat $include_filter_file && echo ""
			
		
		syncWithRsync()
		{
			sed -i 's/$/**/' $include_filter_file
			
						
			printInfo "Sending local files to '$host' with rsync, this is unidirectional"			
			rsync \
			-rlptDhP \
			--prune-empty-dirs \
			--exclude=".git**" \
			--include="*/" \
			--include="symlink.sh" \
			--include="bash-tools/**" \
			--include-from=$include_filter_file \
			--exclude="*" \
			"$local_dotfiles_dir/" \
			"${host}:~/$remote_dotfiles_dir" \
			&& printSuccess "rsync successful" && return 0 \
			|| printError "rsync failed" && return 1		
		}
		
		
		syncWithUnison()
		{
			local unison_profile="andresgongora_dotfiles_unison_config.prf"
			local unison_dir="$HOME/.unison"
			local unison_config_file="$unison_dir/$unison_profile"			
			local local_path=$local_dotfiles_dir
			local remote_path="ssh://${host}/$remote_dotfiles_dir"	
						
			
			## CREATE UNISON RULES
			mkdir -p $unison_dir && echo "" > $unison_config_file
			echo "# Roots of the synchronization" >> $unison_config_file
			echo "root = $local_path" >> $unison_config_file
			echo "root = $remote_path" >> $unison_config_file
			
			echo "" >> $unison_config_file
			echo "# Config" >> $unison_config_file
			echo "times = true" >> $unison_config_file
			echo "auto = true" >> $unison_config_file
			echo "owner = false" >> $unison_config_file
			echo "prefer = newer" >> $unison_config_file
			echo "batch = true" >> $unison_config_file
			[ $VERBOSE == false  ] && echo "silent = true" >> $unison_config_file
			
			echo "" >> $unison_config_file
			echo "# Sync" >> $unison_config_file
			echo "path = bash-tools" >> $unison_config_file
			echo "path = symlink.sh" >> $unison_config_file
			while read line; do
				echo "path = $line" >> $unison_config_file
			done <$include_filter_file
			
			
			[ $VERBOSE == true ] && \
				printInfo "unison config" &&\
				cat $unison_config_file && echo ""
				
				
			printInfo "Syncing local files with '$host' with unison"
			printInfo "unison must be installed on the remote machine"
			unison $unison_profile && rm $unison_config_file \
			&& printSuccess "Unison successful" && return 0 \
			|| printError "Unison failed" && return 1				
		}	
		
		case "$SSH_SYNC_METHOD" in
			"rsync")
				syncWithRsync || exit 1
				;;
				
			"unison")
				syncWithUnison || exit 1
				;;			

			*)		
				printError "Sync method '$SSH_SYNC_METHOD' not supported"; exit 1
		esac
		
		rm "$include_filter_file"
		
		printInfo "Running symlink script remotely..."
		ssh "$host" "~/$remote_dotfiles_dir/symlink.sh --backup" \
		&& printSuccess "SSH connection successful" \
		|| printError "Failed to connect over SSH"	
	}
	





	########################################################################
	## MAIN
	########################################################################
	local DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	[ -L "$DOTFILES_ROOT" ] &&  local DOTFILES_ROOT=$(readlink "$DOTFILES_ROOT")
	source "$DOTFILES_ROOT/bash-tools/bash-tools/user_io.sh"
	
	GLOBAL_ACTION=""
	VERBOSE=false
	LIST_FILES_ONLY=false
	
	DOTFILES_CFG_LIST_FILE="/tmp/andresgongora_dotfiles_cfgs.txt"
	DOTFILES_SRC_LIST_FILE="/tmp/andresgongora_dotfiles_srcs.txt"
	DOTFILES_DST_LIST_FILE="/tmp/andresgongora_dotfiles_dsts.txt"
	
	echo "" > $DOTFILES_CFG_LIST_FILE
	echo "" > $DOTFILES_SRC_LIST_FILE
	echo "" > $DOTFILES_DST_LIST_FILE
	
	
	## RUNTIME VARIABLES
	local verbose=false
	local run_cmd="parseConfigDir"
	local use_ssh=false
	local ssh_sync_method=""
	local ssh_arg=""
	local global_action=""
	local config="$DOTFILES_ROOT/config"
	
	
	## PROCESS ARGUMENTS
	while (( "$#" )); do
		local cmd="$1"
		shift
		case "$cmd" in
			"--ssh")
				local use_ssh=true
				local ssh_arg=$1
				shift
				;;
				
			"--unison")
				if [ -z "$ssh_sync_method" ]; then
					local ssh_sync_method="unison"
				else
					printError "SSH sync methond already set, can not use --unison as well" 
					exit 1
				fi
				;;
				
			"--rsync")
				if [ -z "$ssh_sync_method" ]; then
					local ssh_sync_method="rsync"
				else
					printError "SSH sync methond already set, can not use --rsync as well" 
					exit 1
				fi
				;;

			"-v"|"--verbose")
				local verbose=true
				;;
			
			"-B"|"--backup")
				if [ -z "$global_action" ]; then
					local global_action="B"
				else
					printError "Global action already set, can not use --backup as well" 
					exit 1
				fi
				;;
				
			"-O"|"--overwrite")
				if [ -z "$global_action" ]; then
					local global_action="O"
				else
					printError "Global action already set, can not use --overwrite as well" 
					exit 1
				fi
				;;
				
			"-c"|"--config")
				local config=$1
				shift
				;;				

			*)		
				printError "Invalid argument '$cmd'"; exit 1
		esac
	done
	
	
	## APPLY ARGUMENTS
	GLOBAL_ACTION=$global_action
	VERBOSE=$verbose	
	
		
	if [ $use_ssh == true ]; then
		if [ -z "$ssh_sync_method" ]; then
			printError "When syncing over SSH, you must specify a sync method. Currently supported:"
			printText "--rsync: unidirectional, remote files will be overwritten"
			printText "--unison: bidirectional, requires unison to be installed on remote machine"
		else
			printHeader "Linking your dotfiles over SSH..."
			SSH_SYNC_METHOD=$ssh_sync_method
			LIST_FILES_ONLY=true
			parseConfig $config
			sshSymlink $ssh_arg
		fi	
	else
		printHeader "Linking your dotfiles files..."
		[ $VERBOSE == true ] && printInfo "Parsing $config"
		parseConfig $config
	fi
		
	
	## CREATE `~/.dotfiles`
	## If linking was successful, and your dotfiles folder is not stored
	## under `~/.dotfiles`, create a symlink at said location .
	local dotfiles_symlink="$HOME/.dotfiles"
	if [ ! -d "$dotfiles_symlink" ]; then 
		link "$DOTFILES_ROOT" "$HOME/.dotfiles"
	fi
	

}

(symlink $@)









