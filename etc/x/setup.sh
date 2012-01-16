#!/bin/bash
source `dirname $0`/../helpers

DIR=`dirname $0`
DIR=`cd $DIR && pwd`

source $DIR/os/$(machine_os)
create_symlink $DIR/initrc ~/.xinitrc
create_symlink $DIR/defaults ~/.Xdefaults

# __END__
