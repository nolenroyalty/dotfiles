import os
import sys

#dot_dirs = ["/dotprivate", "/dotvim", "/dotbash"]
dot_dirs = ["/dotvim"]
old_dir_name = "/old_dotfiles"

home = os.getenv("HOME")
cwd = os.getcwd()
old_dir_path = home + old_dir_name + "/"
should_clobber_old = len(sys.argv) > 1 and sys.argv[1].lower() == "-f"


if os.path.exists(old_dir_path) and should_clobber_old:
    print("Killing old dir at " + old_dir_path)
    for f in os.listdir(old_dir_path):
        os.remove(old_dir_path + f)
    os.rmdir(old_dir_path)


try:
    os.mkdir(old_dir_path)
except OSError, e:
    print("Could not create directory: {0}\nExiting".format(e))
    sys.exit(1)
else:
    print("Created directory at " + old_dir_path)


src_dirs = [cwd + dr for dr in dot_dirs]


for src, dst, old in ((src_dir + "/" + fname, home + "/." + fname[1:], old_dir_path + fname) for src_dir in src_dirs for fname in os.listdir(src_dir)):
    try:
        os.rename(dst, old)
    except OSError, e:
        if os.path.exists(dst):
            print("Could not move {0} to {1}: {2}\nExiting".format(dst, old, e))
            sys.exit(1)
    else:
        print("Moved {0} to {1}".format(dst, old))
    os.symlink(src, dst)
    print("{1} -> {0}".format(src, dst))
