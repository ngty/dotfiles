PWD=$(shell pwd)

all: clean setup reload

clean:
	rm -f ~/.tmux.conf

setup:
	ln -s $(PWD)/tmux.conf ~/.tmux.conf

reload:
	tmux source-file ~/.tmux.conf

macos/deps:
	brew install reattach-to-user-namespace
