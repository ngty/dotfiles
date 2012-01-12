#!/bin/bash
source `dirname $0`/../helpers

DIR=`dirname $0`
DIR=`cd $DIR && pwd`

create_symlink $DIR/rc ~/.zshrc
create_symlink $DIR/profile ~/.zprofile
create_symlink $DIR/dir ~/.zsh

# __END__
