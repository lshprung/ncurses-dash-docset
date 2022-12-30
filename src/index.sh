#!/usr/bin/env sh

DB_PATH="$1"
shift

get_title() {
	FILE="$1"

	PATTERN="<[tT][iI][tT][lL][eE]>.*</[tT][iI][tT][lL][eE]>"

	#Find pattern in file
	grep -Eo "$PATTERN" "$FILE" | 
		#Remove tag
		sed 's/<[^>]*>//g' | \
		#Remove '(automake)'
		sed 's/(Autoconf)//g' | \
		#Remove trailing space
		sed 's/[ ]*$//g' | \
		#Remove trailing man categories
		sed 's/[0-9][mx]\?$//g' | \
		#Replace '&amp' with '&'
		sed 's/&amp/&/g' | \
		# ReplACE '&ndash;' with '-'
		sed 's/&ndash;/-/g' | \
		#Replace '&lt;' with '<'
		sed 's/&lt;/</g'
}

get_type() {
	FILE="$1"
	CATEGORY="$(echo "$FILE" | grep -Eo "\.[0-9].?\.html$")"

	if [ -n "$CATEGORY" ]; then
		case "$CATEGORY" in
			.1*) echo "Command"  ;;
			.2*) echo "Service"  ;;
			.3*) echo "Function" ;;
			*)  echo "Object"   ;;
		esac
	fi
}

insert() {
	NAME="$1"
	TYPE="$2"
	PAGE_PATH="$3"

	sqlite3 "$DB_PATH" "INSERT INTO searchIndex(name, type, path) VALUES (\"$NAME\",\"$TYPE\",\"$PAGE_PATH\");"
}

skip_check() {
	NAME="$1"

	case "$NAME" in
		[A-Z])               return 1 ;;
		"Source Browser")    return 1 ;;
		terminal_interface*) return 1 ;;
	esac
}

# Get title and insert into table for each html file
main() {
	while [ -n "$1" ]; do
		unset PAGE_NAME
		unset PAGE_TYPE

		#echo "FILE: $1"
		# Recurse into subdirectories
		if [ -d "$1" ]; then
			main "$1"/*
		else
			PAGE_NAME="$(get_title "$1")"
			if skip_check "$PAGE_NAME"; then
				if [ -n "$PAGE_NAME" ]; then
					PAGE_TYPE="$(get_type "$1")"
					#get_type "$1"
					if [ -z "$PAGE_TYPE" ]; then
						PAGE_TYPE="Guide"
					fi
					#echo "$PAGE_NAME"
					#echo "$PAGE_TYPE"
					insert "$PAGE_NAME" "$PAGE_TYPE" "$(echo "$1" | sed 's/^ncurses.docset\/Contents\/Resources\/Documents\///')"
				fi
			fi
		fi

		shift
	done
}

# Create table
sqlite3 "$DB_PATH" "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
sqlite3 "$DB_PATH" "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"

main "$@"
