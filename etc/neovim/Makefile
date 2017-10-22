PWD=$(shell pwd)

all: clean setup

clean:
	mkdir -p ~/.config/nvim

setup:
	ln -sf $(PWD)/init.vim ~/.config/nvim/init.vim
	nvim +BundleInstall +qall

macos/deps:
	brew install fzf the_silver_searcher
