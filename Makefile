#!make
SHELL := /bin/bash

IGNORE := $(shell mkdir -p $(HOME)/.cache/xml2rfc)

SRC := $(shell yq r metanorma.yml metanorma.source.files | cut -c 3-999)
ifeq ($(SRC),ll)
SRC := $(filter-out README.adoc, $(wildcard sources/*.adoc))
endif

FORMAT_MARKER := mn-output-
FORMATS := $(shell grep "$(FORMAT_MARKER)" $(SRC) | cut -f 2 -d " " | tr "," "\\n" | sort | uniq | tr "\\n" " ")

INPUT_XML  := $(patsubst %.adoc,%.xml,$(SRC))
OUTPUT_XML  := $(patsubst sources/%,documents/%,$(patsubst %.adoc,%.xml,$(SRC)))
OUTPUT_HTML := $(patsubst %.xml,%.html,$(OUTPUT_XML))

ifdef METANORMA_DOCKER
  PREFIX_CMD := echo "Running via docker..."; docker run -v "$$(pwd)":/metanorma/ $(METANORMA_DOCKER)

else
  PREFIX_CMD := echo "Running locally..."; bundle exec
endif

_OUT_FILES := $(foreach FORMAT,$(FORMATS),$(shell echo $(FORMAT) | tr '[:lower:]' '[:upper:]'))
OUT_FILES  := $(foreach F,$(_OUT_FILES),$($F))

all: documents.html

documents:
	mkdir -p $@

documents/%.xml: documents sources/%.xml
	mv sources/$*.{xml,html,doc,rxl} documents

%.xml %.html:	%.adoc | bundle
	pushd $(dir $^); \
	FILENAME=$(notdir $^); \
	${PREFIX_CMD} metanorma $$FILENAME; \
	popd

documents.rxl: $(OUTPUT_XML)
	${PREFIX_CMD} relaton concatenate \
	  -t "$(shell yq r metanorma.yml relaton.collection.name)" \
		-g "$(shell yq r metanorma.yml relaton.collection.organization)" \
		documents $@

documents.html: documents.rxl
	${PREFIX_CMD} relaton xml2html documents.rxl

%.adoc:

define FORMAT_TASKS
OUT_FILES-$(FORMAT) := $($(shell echo $(FORMAT) | tr '[:lower:]' '[:upper:]'))

open-$(FORMAT):
	open $$(OUT_FILES-$(FORMAT))

clean-$(FORMAT):
	rm -f $$(OUT_FILES-$(FORMAT))

$(FORMAT): clean-$(FORMAT) $$(OUT_FILES-$(FORMAT))

.PHONY: clean-$(FORMAT)

endef

$(foreach FORMAT,$(FORMATS),$(eval $(FORMAT_TASKS)))

open: open-html

clean:
	rm -rf documents published *_images sources/*.{rxl,xml,html,doc}

bundle:
	if [ "x" == "${METANORMA_DOCKER}x" ]; then bundle; fi

.PHONY: bundle all open clean

#
# Watch-related jobs
#

.PHONY: watch serve watch-serve

NODE_BINS          := onchange live-serve run-p
NODE_BIN_DIR       := node_modules/.bin
NODE_PACKAGE_PATHS := $(foreach PACKAGE_NAME,$(NODE_BINS),$(NODE_BIN_DIR)/$(PACKAGE_NAME))

$(NODE_PACKAGE_PATHS): package.json
	npm i

watch: $(NODE_BIN_DIR)/onchange
	make all
	$< $(ALL_SRC) -- make all

define WATCH_TASKS
watch-$(FORMAT): $(NODE_BIN_DIR)/onchange
	make $(FORMAT)
	$$< $$(SRC_$(FORMAT)) -- make $(FORMAT)

.PHONY: watch-$(FORMAT)
endef

$(foreach FORMAT,$(FORMATS),$(eval $(WATCH_TASKS)))

serve: $(NODE_BIN_DIR)/live-server revealjs-css reveal.js images
	export PORT=$${PORT:-8123} ; \
	port=$${PORT} ; \
	for html in $(HTML); do \
		$< --entry-file=$$html --port=$${port} --ignore="*.html,*.xml,Makefile,Gemfile.*,package.*.json" --wait=1000 & \
		port=$$(( port++ )) ;\
	done

watch-serve: $(NODE_BIN_DIR)/run-p
	$< watch serve

#
# Deploy jobs
#
publish: published
published: documents.html
	mkdir -p published && \
	cp -a documents $@/ && \
	cp $< published/index.html; \
	if [ -d "images" ]; then cp -a images published; fi

.PHONY: publish
