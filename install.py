#!/usr/bin/env python
"""
Little installer script for these dotfiles, only uses dirs that end in _
and creates symlinks in HOME for each non private file in each dir.  Dirs are used
just for organization.
"""

import os
import subprocess

HOME = os.getenv("HOME")
CWD  = os.getcwd()
OLD_DIR_PATH = os.path.join(HOME, ".old_dotfiles")

def remake_backupdir():
    if os.path.exists(OLD_DIR_PATH):
        subprocess.call(['sudo', 'rm', '-r', OLD_DIR_PATH])
        print "Removed dir at %s, making new dir" % OLD_DIR_PATH
    os.mkdir(OLD_DIR_PATH)
    print "Created new dir %s" % OLD_DIR_PATH

def backup_and_link_dotfile(dotfile_dir, dotfile_name):
    home_dotfile_path   = os.path.join(HOME, "." + dotfile_name)
    backup_dotfile_path = os.path.join(OLD_DIR_PATH, dotfile_name)
    real_dotfile_path   = os.path.join(CWD, dotfile_dir, dotfile_name)
    if os.path.exists(home_dotfile_path):
        os.rename(home_dotfile_path, backup_dotfile_path)
    os.symlink(real_dotfile_path, home_dotfile_path)
    print "\t%s -> %s" % (home_dotfile_path, real_dotfile_path)


def main():
    remake_backupdir()
    for dotfile_dir in (dir_ for dir_ in os.listdir(CWD) if dir_.endswith("_")):
        print "Linking files in %s" % dotfile_dir
        for dotfile_name in (name for name in os.listdir(dotfile_dir) if not name.startswith(".")):
            backup_and_link_dotfile(dotfile_dir, dotfile_name)

if __name__ == "__main__":
    main()
