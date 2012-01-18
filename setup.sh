#!/bin/bash
DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`

source $DIR/etc/helpers
for d in etc bin; do
  create_symlink $DIR/$d ~/$d
done

# __END__
