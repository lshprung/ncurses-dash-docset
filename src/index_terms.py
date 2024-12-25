#!/usr/bin/env python3

from bs4 import BeautifulSoup
import logging
import os
from pprint import pformat
import re
import sys

from index_pages import get_type
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from create_table import create_table
from get_title import get_title
from insert import insert

# Get each term from an index page and insert
class Index_terms:
    def __init__(self, db_path):
        self.db_path = db_path

    def insert_index_terms(self, html_path):
        # Because of lack of styling, we're reading the html like its plaintext
        with open(html_path) as f:
            matches = re.findall(r'^[a-zA-Z_ ]{45}<STRONG><A HREF="[^"]*">[^<]*<\/A><\/STRONG>', f.read(), re.MULTILINE)

        for match in matches:
            self.insert_term(match)

    def insert_term(self, match):
        name = match.lstrip().split(' ')[0]
        page_path = BeautifulSoup(match, 'html.parser').a['href']
        type = get_type(page_path)

        insert(self.db_path, name, type, os.path.join("man", page_path))

if __name__ == '__main__':
    db_path = sys.argv[1]
    html_path = sys.argv[2]

    create_table(db_path)
    main = Index_terms(db_path)
    main.insert_index_terms(html_path)
