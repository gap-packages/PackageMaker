.PHONY: doc html regen check

GAP ?= gap
GAP_ARGS = -q --quitonbreak --packagedirs $(abspath .)

doc:
	$(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

html:
	NOPDF=1 $(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

check:
	$(GAP) $(GAP_ARGS) tst/testall.g

regen:
	$(GAP) $(GAP_ARGS) regen_tests.g
