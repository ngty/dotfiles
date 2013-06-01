PWD=$(shell pwd)
DEST=~/bin/gen/dwm

all: clean setup

clean:
	rm -f $(DEST)
	cd src && make clean

setup: src/dwm
	ln -s $(shell pwd)/src/dwm $(DEST)

src/dwm:
	cd src && make

