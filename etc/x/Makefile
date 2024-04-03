PWD=$(shell pwd)
#FILES=Xdefaults xinitrc Xresources xsession xbindkeysrc
FILES=Xdefaults Xresources xsession xbindkeysrc

all: clean setup

clean:
	for f in $(FILES); do \
		rm -f ~/.$$f; \
	done

setup:
	for f in $(FILES); do \
		ln -s $(PWD)/$$f ~/.$$f; \
	done

