#!/bin/bash
source `dirname $0`/../helpers

DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

create_symlink $DIR/basic ~/.screenrc

# __END__
