PWD=$(shell pwd)

all: setup

setup: setup/vundle
	ln -sf $(PWD)/vimrc ~/.vimrc && \
		vi +BundleInstall +qall ; exit 0

macos/deps:
	brew install fzf the_silver_searcher vim

setup/vundle:
	mkdir -p ~/.vim/bundle && \
		if [ ! -d ~/.vim/bundle/vundle ]; then \
			git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle ; \
		fi
			
