#!/bin/bash
BREWFILE_LOCATION=~/.dotfiles/Brewfile
brew bundle dump --file=$BREWFILE_LOCATION --force

NVM_DIR=~/.dotfiles/directories/.nvm/

git add $BREWFILE_LOCATION $NVM_DIR
git commit -m "Update Brewfile, nvm"
git push origin main
