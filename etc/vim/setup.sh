#!/bin/bash

BASE_DIR=`dirname $0`
BASE_DIR=`cd $BASE_DIR && pwd`
REPO_URL=https://github.com/scrooloose/vimfiles.git
REPO_DIR=${BASE_DIR}/`echo $REPO_URL | sed -e 's|.*/\(.*\).git|\1|'`

# //////////////////////////////////////////////////////////////////
# Install system dependencies
# //////////////////////////////////////////////////////////////////
source ${BASE_DIR}/../helpers
source ${BASE_DIR}/platforms/$(platform)

# //////////////////////////////////////////////////////////////////
# Clone vimfiles repo & update submodules
# //////////////////////////////////////////////////////////////////
echo -n ">> Initializing base config from $REPO_URL ... "

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
  echo -n ">> Cloning extra plugin $url ... "
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
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.0
[ -f ~/.vim ] && mv ~/.vim ~/.vim.0
ln -s ${BASE_DIR}/vimrc ~/.vimrc
ln -s ${BASE_DIR}/vimfiles ~/.vim

# __END__