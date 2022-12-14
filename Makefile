SHELL := /bin/bash

HTTPHOST ?= 127.0.0.1
PORT ?= 8001

python = /usr/bin/env python $(1)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Clean all linked resources
	for i in $$(ls css); do \
		if [ -h "css/$$i" ]; then \
			rm -f css/$$i; \
		fi \
	done
	rm -f fonts
	rm -f js
	rm -f lib
	rm -f plugin
	rm -f third_party_plugins/*
	rm -f webfonts

.PHONY: link
link: ## Link all required resources
	yarn install
	for i in $$(ls node_modules/@fortawesome/fontawesome-free-webfonts/css); do \
		ln -fs ../node_modules/@fortawesome/fontawesome-free-webfonts/css/$$i css/$$i; \
	done
	for i in $$(ls node_modules/reveal.js/css); do \
		ln -fs ../node_modules/reveal.js/css/$$i css/$$i; \
	done
	ln -fs node_modules/devicons/fonts .
	ln -fs ../node_modules/devicons/css/devicons.min.css css/devicons.min.css
	ln -fs node_modules/@fortawesome/fontawesome-free-webfonts/webfonts .
	ln -fs node_modules/reveal.js/js .
	ln -fs node_modules/reveal.js/lib .
	ln -fs node_modules/reveal.js/plugin .
	ln -fs ../node_modules/reveal.js-menu/menu.css third_party_plugins/menu.css
	ln -fs ../node_modules/reveal.js-menu/menu.js third_party_plugins/menu.js
	ln -fs ../node_modules/reveal_external/external/external.js third_party_plugins/external.js

.PHONY: serve
serve: ## Serve the slides
	@echo "Serving slides at http://$(HTTPHOST):$(PORT)/"
	@echo "Quit the server with CONTROL-C."
	@$(call python,-m http.server --bind $(HTTPHOST) $(PORT))

.PHONY: demo
demo: ## Open the reveal.js demo
	$(call python,-m webbrowser file://$$(pwd)/node_modules/reveal.js/demo.html)

.PHONY: pdf
pdf: ## Export slides as PDF
	docker-compose up decktape
	docker-compose down
