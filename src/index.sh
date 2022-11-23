#!/usr/bin/env sh

DB_PATH="$1"
shift

get_title() {
	FILE="$1"

	PATTERN="<title>.*\(Autoconf\).*</title>"

	#Find pattern in file
	grep -Eo "$PATTERN" "$FILE" | 
		#Remove tag
		sed 's/<[^>]*>//g' | \
		#Remove '(automake)'
		sed 's/(Autoconf)//g' | \
		#Remove trailing space
		sed 's/[ ]*$//g' | \
		#Replace '&amp' with '&'
		sed 's/&amp/&/g' | \
		#Replace '&lt;' with '<'
		sed 's/&lt;/</g'
}

get_type() {
	FILE="$1"
	PATTERN="The node you are looking for is at.*Limitations-of-.*\.html;Builtin
	The node you are looking for is at;Macro"

	echo "$PATTERN" | while read -r line; do
		#echo "$line"
		if grep -Eq "$(echo "$line" | cut -d ';' -f 1)" "$FILE"; then
			echo "$line" | cut -d ';' -f 2
			break
		fi
	done
}

insert() {
	NAME="$1"
	TYPE="$2"
	PAGE_PATH="$3"

	sqlite3 "$DB_PATH" "INSERT INTO searchIndex(name, type, path) VALUES (\"$NAME\",\"$TYPE\",\"$PAGE_PATH\");"
}

# Create table
sqlite3 "$DB_PATH" "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
sqlite3 "$DB_PATH" "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"

# Get title and insert into table for each html file
while [ -n "$1" ]; do
	unset PAGE_NAME
	unset PAGE_TYPE
	PAGE_NAME="$(get_title "$1")"
	if [ -n "$PAGE_NAME" ]; then
		PAGE_TYPE="$(get_type "$1")"
		#get_type "$1"
		if [ -z "$PAGE_TYPE" ]; then
			PAGE_TYPE="Guide"
		fi
		#echo "$PAGE_TYPE"
		insert "$PAGE_NAME" "$PAGE_TYPE" "$(basename "$1")"
	fi
	shift
done
