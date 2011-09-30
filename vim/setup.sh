#!/bin/bash

REPO_URL=https://github.com/scrooloose/vimfiles.git
BASE_DIR=`dirname $0`
BASE_DIR=`cd $BASE_DIR && pwd`
REPO_DIR=${BASE_DIR}/`echo $REPO_URL | sed -e 's|.*/\(.*\).git|\1|'`

# Install system dependencies
sudo pacman -S --needed ctags vim

# Clone vimfiles repo & update submodules
[ -d $REPO_DIR ] || git clone $REPO_URL
cd $REPO_DIR
git submodule init && git submodule update

# Install extra plugins
cd $REPO_DIR
for url in `cat ${BASE_DIR}/extra_plugins`; do
  name=`echo $url | sed -e 's|.*/\(.*\).git|\1|'`
  git clone $url bundle/${name}
done

# Remove not required plugins
cd $REPO_DIR
mv bundle/gundo bundle/.gundo.disabled

# Symlinking to vim path
rm ~/.vimrc && ln -s ${BASE_DIR}/vimrc ~/.vimrc
rm ~/.vim && ln -s ${BASE_DIR}/vimfiles ~/.vim

# __END__
