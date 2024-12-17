#!/usr/bin/env sh

# shellcheck source=../../../scripts/create_table.sh
. "$(dirname "$0")"../../../scripts/create_table.sh
# shellcheck source=../../../scripts/insert.sh
. "$(dirname "$0")"../../../scripts/insert.sh
# shellcheck source=./lib/get_type
. "$(dirname "$0")"/lib/get_type

DB_PATH="$1"
shift

get_title() {
	FILE="$1"

	pup -p -f "$FILE" 'title text{}' | \
		tr -d \\n | \
		#Remove trailing man categories
		sed 's/ [0-9][mx]\?.*$//g' | \
		sed 's/\"/\"\"/g'
}

insert_pages() {
	# Get title and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		unset PAGE_TYPE

		PAGE_NAME="$(get_title "$1")"
		if [ -n "$PAGE_NAME" ]; then
			PAGE_TYPE="$(get_type "$1")"
			if [ -z "$PAGE_TYPE" ]; then
				PAGE_TYPE="Guide"
			fi
			insert "$DB_PATH" "$PAGE_NAME" "$PAGE_TYPE" "$(echo "$1" | sed 's/^ncurses.docset\/Contents\/Resources\/Documents\///')"
		fi
		shift
	done
}

create_table "$DB_PATH"
insert_pages "$@"
