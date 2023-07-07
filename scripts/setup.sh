#!/bin/bash

function brew(){
  # Install brew
  if [ "$OS" == "macos" ]
  then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [ "$OS" == "linux" ]
  then
    sudo apt-get install build-essential procps curl file git -y
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
  fi

  # Install brew packages
  brew bundle install --file=~/.dotfiles/Brewfile
}

function check_root() {
  if [ "$EUID" -ne 0 ]
  then
    echo "Please run as root"
    exit 1
  fi
}

function help(){
  echo "Usage: sudo ./setup.sh <OS>"
  echo "OS: macos, linux"
  echo "for mac only works with m1 chip"
  echo "for linux only works with ubuntu"
  echo "requires root access"
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

function check_os(){
  OS=$1
  # check if parameter is passed
  if [ -z "$OS" ]; then
    echo "No OS specified. Exiting."
    help
    exit 1
  elif [ "$OS" != "macos" ] && [ "$OS" != "linux" ]; then
      echo "OS not supported. Exiting."
      help
      exit 1
  fi
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
check_root
check_os "$1"

echo "=====================
Installing dotfiles for $OS...
====================="

xcode
copy_dot_files
brew
copy_ssh_keys
zsh

echo -e "=====================
For Raycast, open raycast and type \"Import Settings & Data\" and select the file \"raycast.config\" in the dotfiles directory
====================="

