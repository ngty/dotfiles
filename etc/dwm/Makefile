PWD=$(shell pwd)

all: clean setup

clean:
	rm -f ~/bin/dwm
	cd src && make clean

setup: src/dwm
	ln -s $(shell pwd)/src/dwm ~/bin/dwm

src/dwm:
	cd src && make

