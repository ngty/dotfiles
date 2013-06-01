all: clean setup

clean:
	for d in `ls */Makefile`; do \
		make -C `dirname $$d` clean; \
	done

setup:
	for d in `ls */Makefile`; do \
		make -C `dirname $$d` setup; \
	done

