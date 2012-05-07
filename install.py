import os
import sys

dot_files = {"/.test":"/test/test", "/.testrc":"/test/testrc"}
#dot_files = ["test", "test/testrc"]
old_dir_name = "/old_dotfiles"

home = os.getenv("HOME")
old_dir_path = home + old_dir_name
src_path = os.getcwd()

try:
    os.mkdir(old_dir_path)
except OSError, e:
    print("Could not create directory: {0}\nExiting".format(e))
    sys.exit(1)

for fname, fpath in dot_files.iteritems():
    try:
        os.rename(home + fname, old_dir_path + fname)
    except OSError, e:
        if os.path.exists(home + fname):
            print("Could not rename {0} to {1}: {2}\nExiting".format(home + fname, old_dir_path + fname, e))
    else:
        print("Moved {0} to {1}".format(home + fname, old_dir_path + fname))

    print("Linking {0} to {1}".format(home + fname, os.getcwd() + fpath))
    os.symlink(os.getcwd() + fpath, home + fname)
