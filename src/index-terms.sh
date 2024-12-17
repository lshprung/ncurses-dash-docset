#!/usr/bin/env sh

# shellcheck source=../../../scripts/create_table.sh
. "$(dirname "$0")"../../../scripts/create_table.sh
# shellcheck source=../../../scripts/insert.sh
. "$(dirname "$0")"../../../scripts/insert.sh
# shellcheck source=./lib/get_type
. "$(dirname "$0")"/lib/get_type

DB_PATH="$1"
shift

insert_index_terms() {
	# Get each term from an index page and insert
	while [ -n "$1" ]; do
		grep -Eoi "^[a-zA-Z_ ]{45}<STRONG><A HREF=\"[^\"]*\">[^<]*</A></STRONG>" "$1" | while read -r line; do
			insert_term "$line"
		done

		shift
	done
}

insert_term() {
	LINK="$1"
	#NAME="$(echo "$LINK" | pup -p 'a text{}' | sed 's/\"\"//g' | tr -d \\n)"
	NAME="$(echo "$LINK" | cut -d ' ' -f 1)"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"

	TYPE=$(get_type "$PAGE_PATH")
	if [ -z "$TYPE" ]; then
		TYPE="Guide"
	fi

	insert "$DB_PATH" "$NAME" "$TYPE" "man/$PAGE_PATH"
}

create_table "$DB_PATH"
insert_index_terms "$@"
