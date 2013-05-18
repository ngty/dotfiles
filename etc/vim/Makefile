PWD=$(shell pwd)

all: clean setup

clean:
	rm ~/.vimrc

setup:
	ln -s $(PWD)/vimrc ~/.vimrc
	vim +BundleInstall +qall

