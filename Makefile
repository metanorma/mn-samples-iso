SRC  := $(wildcard iso-*.adoc)
XML  := $(patsubst %.adoc,%.xml,$(SRC))
HTML := $(patsubst %.adoc,%.html,$(SRC))
DOC  := $(patsubst %.adoc,%.doc,$(SRC))

SHELL := /bin/bash

all: $(HTML) $(XML) $(PDF) $(DOC)

clean: clean-doc clean-xml clean-html

clean-doc:
	rm -f $(DOC)

clean-xml:
	rm -f $(XML)

clean-html:
	rm -f $(HTML)

bundle:
	bundle

%.xml %.html %.doc:	%.adoc | bundle
	bundle exec metanorma -t iso -x doc,xml,html $^

html: clean-html $(HTML)

open:
	open $(HTML)

.PHONY: bundle all open
