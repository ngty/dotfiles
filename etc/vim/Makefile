PWD=$(shell pwd)

all: clean setup

clean:
	rm -f ~/.vimrc

setup:
	ln -s $(PWD)/vimrc ~/.vimrc
	vim +BundleInstall +qall

