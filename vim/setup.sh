#!/bin/bash

VIM_DIR=`dirname $0`
VIM_DIR=`cd $VIM_DIR && pwd`
REPO_DIR=${VIM_DIR}/vimfiles

# Install system dependencies
sudo pacman -S --needed ctags vim

# Clone vimfiles repo & update submodules
[ -d $REPO_DIR ] || git clone https://github.com/scrooloose/vimfiles.git
cd $REPO_DIR
git submodule init && git submodule update

# Install extra plugins
cd $REPO_DIR
git clone https://github.com/kana/vim-textobj-user.git bundle/vim-textobj-user
git clone https://github.com/nelstrom/vim-textobj-rubyblock.git bundle/vim-textobj-rubyblock
git clone https://github.com/kana/vim-vspec.git bundle/vim-vspec

# Remove not required plugins
cd $REPO_DIR
mv bundle/gundo bundle/.gundo

# Symlinking to vim path
rm ~/.vimrc && ln -s ${VIM_DIR}/vimrc ~/.vimrc
rm ~/.vim && ln -s ${VIM_DIR}/vimfiles ~/.vim

# __END__
