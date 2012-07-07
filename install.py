#!/usr/bin/env python
"""
Little installer script for these dotfiles, only uses dirs that end in _
and creates symlinks in HOME for each non private file in each dir.  Dirs are used
just for organization.
"""

import os
import os.path as path
import subprocess
HOME = os.getenv("HOME")
CWD = os.getcwd()

OLD_DIR_PATH = path.join(HOME, ".old_dotfiles")

def kill_old_backupdir():
    subprocess.call(['sudo', 'rm', '-r', OLD_DIR_PATH])

def make_new_backupdir():
    os.mkdir(OLD_DIR_PATH)

def remake_backupdir():
    try:
        kill_old_backupdir()
    except OSError:
        pass
    else:
        print "Killed dir at %s, making new dir" % OLD_DIR_PATH
    make_new_backupdir()
    print "Created new dir"


def get_dotfile_dirs():
    return (d for d in os.listdir(CWD) if d.endswith("_"))

def get_dotfiles(dotfile_dir):
    return (f for f in os.listdir(dotfile_dir) if not f.startswith("."))


def backup_dotfile(dotfile_name):
    current_dotfile_path = path.join(HOME, "." + dotfile_name)
    backup_dotfile_path = path.join(OLD_DIR_PATH, dotfile_name)
    os.rename(current_dotfile_path, backup_dotfile_path)

def link_dotfile(dotfile_dir, dotfile_name):
    link_src_file = path.join(CWD, dotfile_dir, dotfile_name)
    link_dst_file = path.join(HOME, "." + dotfile_name)
    os.symlink(link_src_file, link_dst_file)
    print "\t%s -> %s" % (link_dst_file, link_src_file)

def backup_link_dotfile(dotfile_dir, dotfile_name):
    try:
        backup_dotfile(dotfile_name)
    except OSError:
        pass
    link_dotfile(dotfile_dir, dotfile_name)


def main():
    remake_backupdir()
    for dotfile_dir in get_dotfile_dirs():
        print "Linking files in %s" % dotfile_dir
        for dotfile_name in get_dotfiles(dotfile_dir):
            backup_link_dotfile(dotfile_dir, dotfile_name)

if __name__ == "__main__":
    main()
