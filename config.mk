DOCSET_NAME = ncurses

ifdef VERSION
MANUAL_URL  = https://invisible-island.net/archives/ncurses/ncurses-$(VERSION).tar.gz
else
MANUAL_URL  = https://invisible-island.net/archives/ncurses/ncurses.tar.gz
endif

MANUAL_ARCHIVE = tmp/ncurses.tar.gz
MANUAL_SRC = tmp/ncurses-*
MANUAL_PATH = ncurses-*/doc/html
MANUAL_FILE = $(MANUAL_SRC)/doc/html

ERROR_DOCSET_NAME = $(error DOCSET_NAME is unset)
WARNING_MANUAL_URL = $(warning MANUAL_URL is unset)
ERROR_MANUAL_FILE = $(error MANUAL_FILE is unset)
.phony: err warn

$(MANUAL_ARCHIVE): tmp
	curl -o $@ $(MANUAL_URL)

$(MANUAL_FILE): $(MANUAL_ARCHIVE)
	tar --wildcards -x -z -f $(MANUAL_ARCHIVE) -C tmp $(MANUAL_PATH)

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

$(INDEX_FILE): $(SOURCE_DIR)/src/index_pages.py $(SOURCE_DIR)/src/index_terms.py $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index_pages.py $@ $(shell find $(DOCUMENTS_DIR)/ -iname *.html)
	$(SOURCE_DIR)/src/index_terms.py $@ $(DOCUMENTS_DIR)/man/ncurses.3x.html
