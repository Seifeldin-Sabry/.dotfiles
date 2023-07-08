#!/bin/bash

function brew(){
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Install brew packages
  brew bundle install --file=~/.dotfiles/Brewfile
}

function help(){
  echo "Usage: sudo ./setup.sh"
  echo "for mac only works with m1 chip"
}

function copy_dot_files() {
  echo "=====================
  Copying dotfiles...
  ====================="
  ln -s ~/.dotfiles/.bash_profile ~/.bash_profile
  ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
  ln -s ~/.dotfiles/.iterm2_shell_integration.zsh ~/.iterm2_shell_integration.zsh
}

function zsh() {
  echo "=====================
  Installing zsh...
  ====================="
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  mv ~/.zshrc ~/.zshrc.bak
  ln -s ~/.dotfiles/.zshrc ~/.zshrc
}

function check_help() {
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]
  then
    help
    exit 0
  fi
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

  touch ~/.ssh/config
  echo -e "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" > ~/.ssh/config

  unset IFS
}

function xcode() {
  echo "=====================
  Installing xcode...
  ====================="
  if [ "$OS" == "macos" ]
  then
    xcode-select --install
  else
    echo "Skipping xcode install for linux...."
  fi
}

check_help "$1"
echo "=====================
Installing dotfiles for $OS...
====================="
xcode
copy_dot_files
brew
copy_ssh_keys
zsh

# nodejs stable
nvm install --lts

echo -e "=====================
For Raycast, open raycast and type \"Import Settings & Data\" and select the file \"raycast.config\" in the dotfiles directory
====================="

