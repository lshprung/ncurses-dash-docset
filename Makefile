DOCSET_NAME = ncurses

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
#ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

#VERSION=

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

ifndef DOCSET_NAME
err: ; $(ERROR_DOCSET_NAME)
endif

ifndef MANUAL_FILE
err: ; $(ERROR_MANUAL_FILE)
endif

ifndef MANUAL_URL
warn: 
	$(WARNING_MANUAL_URL)
	$(MAKE) all
endif

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE)
ifdef SRC_ICON
DOCSET += $(ICON_FILE)
endif

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_ARCHIVE): tmp
	curl -o $@ $(MANUAL_URL)

$(MANUAL_FILE): $(MANUAL_ARCHIVE)
	tar --wildcards -x -z -f $(MANUAL_ARCHIVE) -C tmp $(MANUAL_PATH)

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index_pages.sh src/index_terms.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index_pages.sh $@ $(shell find $(DOCUMENTS_DIR)/ -iname *.html)
	src/index_terms.sh $@ $(DOCUMENTS_DIR)/man/ncurses.3x.html

#$(ICON_FILE): src/icon.png $(DOCSET_DIR)
#	cp $(SRC_ICON) $@
