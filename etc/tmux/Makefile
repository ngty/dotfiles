PWD=$(shell pwd)

all: clean setup

clean:
	rm -f ~/.tmux.conf

setup:
	ln -s $(PWD)/tmux.conf ~/.tmux.conf

reload:
	tmux source-file ~/.tmux.conf

