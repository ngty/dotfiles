#!/bin/bash

BASE_DIR=`dirname $0`
BASE_DIR=`cd $BASE_DIR && pwd`
REPO_URL=https://github.com/scrooloose/vimfiles.git
REPO_DIR=${BASE_DIR}/`echo $REPO_URL | sed -e 's|.*/\(.*\).git|\1|'`

# //////////////////////////////////////////////////////////////////
# Install system dependencies
# //////////////////////////////////////////////////////////////////
source ${BASE_DIR}/../helpers
source ${BASE_DIR}/os/$(machine_os)

# //////////////////////////////////////////////////////////////////
# Clone vimfiles repo & update submodules
# //////////////////////////////////////////////////////////////////
echo -n "* initializing base config from $REPO_URL ... "

if [[ -d $REPO_DIR ]]; then
  echo "skipped"
else
  echo
  cd $BASE_DIR && git clone $REPO_URL
  cd $REPO_DIR && git submodule init && git submodule update
fi

# //////////////////////////////////////////////////////////////////
# Install extra plugins
# //////////////////////////////////////////////////////////////////
cd $REPO_DIR
for url in `cat ${BASE_DIR}/extra_plugins`; do
  echo -n "* cloning extra plugin $url ... "
  name=`echo $url | sed -e 's|.*/\(.*\).git|\1|'`

  if [ -d bundle/${name} ]; then
    echo "skipped"
  else
    echo
    git clone $url bundle/${name}
  fi
done

# //////////////////////////////////////////////////////////////////
# Remove not required plugins
# //////////////////////////////////////////////////////////////////
cd $REPO_DIR
for plugin in `cat ${BASE_DIR}/disabled_plugins`; do
  [ -d bundle/${plugin} ] && \
    mv bundle/${plugin} bundle/.${plugin}.disabled
done

# //////////////////////////////////////////////////////////////////
# Symlink to vim path
# //////////////////////////////////////////////////////////////////
create_symlink ${BASE_DIR}/vimrc ~/.vimrc
create_symlink ${BASE_DIR}/vimfiles ~/.vim

# __END__
