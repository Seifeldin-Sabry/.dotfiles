#!/bin/bash
USER_NOW=$(whoami)
DIR="/Users/$USER_NOW/.dotfiles"
# format date example: Mon 01 Jan 2021 12:00:00 PM
DATE=$(date +"%a %d %b %Y %I:%M:%S %p")
echo "Updating dotfiles on $DATE"

LOGFILE="$DIR/logs/$DATE.log"

# make sure the log file exists if not create it
echo "Creating log file at $LOGFILE"

if [ ! -f "$LOGFILE" ]; then
  touch "$LOGFILE"
fi

BREWFILE_LOCATION=$DIR/.dotfiles/Brewfile
brew bundle dump --file=$BREWFILE_LOCATION --force 2> "$LOGFILE"

NVM_DIR=$DIR/.dotfiles/directories/.nvm/ 2> "$LOGFILE"
cd $DIR
git pull origin main 2> "$LOGFILE"
git add . 2> "$LOGFILE"
git commit -m "Update Brewfile, nvm" 2> "$LOGFILE"
git push origin main 2> "$LOGFILE"
cd -