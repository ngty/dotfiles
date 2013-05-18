PWD=$(shell pwd)
FILES=bash_logout bash_profile bashrc

all: clean setup

clean:
	for f in $(FILES); do \
		rm ~/.$$f; \
	done

setup:
	for f in $(FILES); do \
		ln -s $(PWD)/$$f ~/.$$f; \
	done


