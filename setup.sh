#!/bin/bash
##################################################
# Script to setup symlinks in ~ for my dotfiles
# Run in the root dotfiles directory
# Basic idea and format stolen from http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/
##################################################

DOTFILES_DIR=$(pwd -P)
BACKUP_DIR=~/.old_dotfiles
DIRECTORIES="vim bash zsh various"

echo -n "Creating backup directory for dotfiles at $BACKUP_DIR..."
mkdir -p $BACKUP_DIR
echo 'done'

for dir in $DIRECTORIES; do
    echo "Setting up symlinks for all items in $dir"
    for file in $(ls $dir); do

        if [ -L ~/.$file ]; then # No need to backup symbolic links, and they cause weird circular issues.
            echo "Removing symbolic link at ~/.$file"
            rm ~/.$file 
        elif [ -e ~/.$file ]; then
            echo "Backing up $file"
            mv ~/.$file $BACKUP_DIR
        fi

        echo "Creating symlink for $file"
        ln -s $DOTFILES_DIR/$dir/$file ~/.$file

    done
    echo -e "Done setting up symlinks for $dir\n"
done

echo "Done setting up symlinks"

echo "Touching files for local machine settings"
touch ~/.dotfiles_config # Local machine settings for terminal
touch ~/.pentadactyl/pentadactylrc # Local machine settings for browser
echo "Done"
