all: clean setup

clean:
	for d in `ls */Makefile`; do \
		make -C `dirname $$d` $@; \
	done

setup:
	for d in `ls */Makefile`; do \
		make -C `dirname $$d` $@; \
	done
