#!/bin/bash
DIR=`dirname ${BASH_SOURCE[0]}`
DIR=`cd $DIR && pwd`
DEST=~/.config/subtle

source ${DIR}/../helpers
source ${DIR}/os/$(machine_os)

sudo gem install archive-tar-minitar ffi --no-rdoc --no-ri
sur install `cat $DIR/sublets.list`

[[ -d $DEST ]] || mkdir $DEST
create_symlink $DIR/subtle.rb $DEST/subtle.rb
create_symlink $DIR/config $DEST/config

# __END__
