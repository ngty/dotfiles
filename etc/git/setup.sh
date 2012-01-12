#!/bin/bash
source `dirname $0`/../helpers

DIR=`dirname $0`
DIR=`cd $DIR && pwd`

create_symlink $DIR/config ~/.gitconfig

# __END__
