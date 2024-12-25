#!/usr/bin/env python3

import os
import re
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from create_table import create_table
from get_title import get_title
from insert import insert

def get_type(html_path):
    category = re.search(r'\.[0-9].?\.html$', html_path)

    if category is None:
        return "Guide"

    if re.search(r'^\.1', category.group(0)):
        return "Command"
    elif re.search(r'^.2', category.group(0)):
        return "Service"
    elif re.search(r'^.3', category.group(0)):
        return "Function"
    else:
        return "Object"

def insert_page(db_path, html_path):
    page_name = get_title(html_path)
    page_name = re.sub(r'\s[0-9][mx]?.*$', r'', page_name)

    page_type = get_type(html_path)

    insert(db_path, page_name, page_type, re.sub(r'^.*ncurses\.docset\/Contents\/Resources\/Documents\/', r'', html_path))

if __name__ == '__main__':
    db_path = sys.argv[1]

    create_table(db_path)
    for html_path in sys.argv[2:]:
        insert_page(db_path, html_path)
