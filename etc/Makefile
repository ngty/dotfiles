all: clean setup

%:
	for d in `ls */Makefile`; do \
		make -C `dirname $$d` $@; \
	done

