#!/bin/bash

function brew(){
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Install brew packages
  brew bundle install --file=~/.dotfiles/Brewfile
}


function copy_dot_files() {
  echo "=====================
  Copying dotfiles...
  ====================="
  IFS='
  '
  for file in $(ls -a ~/.dotfiles/files); do
    if [ "$file" != "." ] && [ "$file" != ".." ] && [ "$file" != ".ssh" ]
    then
      ln -s ~/.dotfiles/files/"$file" ~/"$file"
    fi
  done
  unset IFS
}

function copy_ssh_keys() {
  echo "=====================
  Copying ssh keys...
  ====================="
  mkdir ~/.ssh
  IFS='
  '
  for file in $(ls -a ~/.dotfiles/directories/.ssh); do
    if [ "$file" != "." ] && [ "$file" != ".." ]
    then
      cp ~/.dotfiles/directories/.ssh/"$file" ~/.ssh/"$file"
      ansible-vault decrypt ~/.ssh/"$file"
      chmod 700 ~/.ssh/"$file"
      ssh-add -K ~/.ssh/"$file"
    fi
  done
  eval "$(ssh-agent -s)"
  unset IFS

  cat ssh-config.txt > ~/.ssh/config
}

function xcode() {
  echo "=====================
  Installing xcode...
  ====================="
  xcode-select --install
}

function zsh(){
  echo "=====================
  Installing zsh...
  ====================="
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "=====================
  Downloading antigen...
  ====================="
  curl -L git.io/antigen > ~/antigen.zsh
}

echo "=====================
Installing dotfiles for $OS...
====================="
xcode
copy_dot_files
brew
copy_ssh_keys
zsh

echo "=====================
Installing node stable...
====================="
# nodejs stable
nvm install --lts

echo -e "=====================
For Raycast, open raycast and type \"Import Settings & Data\" and select the file \"raycast.config\" in the dotfiles directory
Make sure to also restart your terminal for the changes to take effect
====================="

