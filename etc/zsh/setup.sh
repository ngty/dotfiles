#!/bin/bash
DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

source $DIR/../helpers
source $DIR/os/$(machine_os)

create_symlink $DIR/rc ~/.zshrc
create_symlink $DIR/profile ~/.zprofile
create_symlink $DIR/dir ~/.zsh

# __END__
