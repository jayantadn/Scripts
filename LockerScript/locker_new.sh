#!/usr/bin/env bash

function main() {
	# get the configuration parameters
	get_config
	echo "The following configuration is found:"
	echo -e "\tMOVIE_DIR=$MOVIE_DIR"
	echo -e "\tPLAYER=$PLAYER"
	echo -e "\tSPLITTER=$SPLITTER"
	
	# create backup of database if it exists
	if [ -f "$DATABASE" ]
	then
		bakdb=`date +%D | awk -F/ '{ printf "database_20%s%s%s.csv", $3, $1, $2 }'`
		dir=`dirname "$DATABASE"`
		cp -f "$DATABASE" "$dir/$bakdb"
	fi
	
	while true
	do
		echo
		PS3="[Main Menu] Enter your choice: "
		select item in \
			"Play a random file" \
			"Play a high rated movie" \
			"Play a random Actor" \
			"Play something else" \
			"Fix movie folder" \
			"Refresh database" \
			"Other options" \
			"Exit" 
		do
			case $item in
				"Play a random Actor")
					[ -f "$DATABASE" ] || { echo "**ERROR** Database file does not exist"; continue; }
					play_random_actor
					break
					;;
					
				"Exit")
					exit
					;;
					
				*)
					echo "Invalid option"
					;;
			esac
		done	# select
	done # while true	
}

function play_random_actor() {
	echo "Playing random actor"
}

# This function will do the following:
#	- create .locker_config under home directory
#	- create default configuration
#	- set global constants
function get_config()
{
	# create the config folder
	if ! [ -e ~/.locker_config ]
	then
		mkdir ~/.locker_config
	fi
	CONFIG_DIR=~/.locker_config
	
	readonly CONFIG_FILE=~/.locker_config/config.txt
	
	# create a sample config for first time usage
	if ! [ -f "$CONFIG_FILE" ]
	then
		echo "Creating initial configuration"
		
		read -p "Enter Movie Directory: "
		echo "MOVIE_DIR=$REPLY" > "$CONFIG_FILE"
		
		read -p "Enter default media player: "
		echo "PLAYER=$REPLY" >> "$CONFIG_FILE"

		echo "SPLITTER=avidemux2.6_qt4" >> "$CONFIG_FILE"
	fi
	
	# Reading configuration file
	while read line
	do
		key=`echo $line | awk 'BEGIN{FS="="} {print $1}'`
		value=`echo $line | awk 'BEGIN{FS="="} {print $2}'`
		
		case $key in
		"MOVIE_DIR")
			if ! [ -d "$value" ]
			then
				echo "**ERROR** Movie directory is not valid"
				exit
			else
				if [ `basename "$value"` != ".Locker" ] 
				then
					echo "**ERROR** Movie directory name must be .Locker" 
					exit
				else
					readonly MOVIE_DIR="$value"
				fi
			fi
			;;
			
		"PLAYER")
			which "$value" > /dev/null
			if [ $? -ne 0 ]
			then
				echo "**WARNING** Configured Movie Player is not installed"
			fi
			readonly PLAYER="$value"
			;;
			
		"SPLITTER")
			which "$value" > /dev/null
			if [ $? -ne 0 ]
			then
				echo "**WARNING** Configured splitter is not installed"
			else
				readonly SPLITTER="$value"
			fi
			;;
			
		*)
			echo "**ERROR** Configuration file corrupted"
			exit
			;;
		esac
	done < "$CONFIG_FILE"

	# create temporary folder
	readonly TEMP_DIR="$CONFIG_DIR/temp"
	[ -e "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
	mkdir "$TEMP_DIR"
	
	# database file
	readonly DATABASE="$CONFIG_DIR/database.csv"
}


main