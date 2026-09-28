.PHONY: help run doc html clean check test regen

PKGNAME = PackageMaker
TESTFILE = tst/testall.g

# directory containing this Makefile, so 'make -f path/to/Makefile' works too
PKGDIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GAP ?= gap
GAP_ARGS = -q --quitonbreak --packagedirs "$(PKGDIR)"

.DEFAULT_GOAL := help

# list every target annotated with a '## description' comment
help: ## show this help
	@echo "The following make targets are available:"
	@awk -F ':.*## ' '/^[a-zA-Z_-]+:.*## / { t[++n] = $$1; d[n] = $$2; if (length($$1) > w) w = length($$1) } \
		END { for (i = 1; i <= n; i++) printf "  make %-" w "s  %s\n", t[i], d[i] }' $(MAKEFILE_LIST)
	@echo
	@echo "To use a different GAP executable than '$(GAP)', set GAP, e.g.:"
	@echo "  make check GAP=/path/to/gap"
	@echo "  make check GAP=gap-4.16"

run: ## start GAP and load the package
	$(GAP) --packagedirs "$(PKGDIR)" -c 'LoadPackage("$(PKGNAME)");'

# AutoDoc writes into doc/ relative to the current directory
doc: ## build the documentation (HTML, text and PDF)
	cd "$(PKGDIR)" && $(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

html: ## build the documentation without PDF
	cd "$(PKGDIR)" && NOPDF=1 $(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

clean: ## remove generated documentation files
	cd "$(PKGDIR)/doc" && rm -f *.aux *.bbl *.blg *.brf *.css *.dvi *.html *.idx *.ilg *.ind *.js *.lab *.log *.out *.pdf *.pnr *.ps *.six *.tex *.toc *.txt *.xml.bib _*.xml title.xml

check: ## run the test suite
	$(GAP) $(GAP_ARGS) "$(PKGDIR)/$(TESTFILE)"

test: check ## alias for check

regen: ## regenerate the expected test output
	cd "$(PKGDIR)" && $(GAP) $(GAP_ARGS) regen_tests.g
