#!/bin/bash
DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

source $DIR/../helpers
source $DIR/os/$(machine_os)

create_symlink $DIR/basic ~/.screenrc

# __END__
