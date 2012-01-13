#!/bin/bash
source `dirname $0`/../helpers

DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

create_symlink $DIR/rc ~/.bashrc
create_symlink $DIR/profile ~/.bash_profile

# __END__
