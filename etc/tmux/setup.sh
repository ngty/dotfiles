#!/bin/bash
DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

source `dirname $0`/../helpers
create_symlink $DIR/conf ~/.tmux.conf

# __END__
