import os
import sys
import subprocess

#dot_dirs = ["/various", "/zsh_", "/vim_", "/bash_"]
home = os.getenv("HOME")
cwd = os.getcwd()
dirs = [d for d in os.listdir(cwd) if d[-1] == "_"]
old_dir_name = ".old_dotfiles"

#old_dir_path = home + old_dir_name + "_/"
old_dir_path = os.path.join(home, old_dir_name)
should_clobber_old = len(sys.argv) > 1 and sys.argv[1].lower() == "-f"


if os.path.exists(old_dir_path) and should_clobber_old:
    print("Killing old dir at " + old_dir_path)
    subprocess.call(['rm', '-r', old_dir_path])
    #for f in os.listdir(old_dir_path):
        #os.remove(old_dir_path + f)
    #os.remove(old_dir_path + "/*")
    #os.rmdir(old_dir_path)


try:
    os.mkdir(old_dir_path)
except OSError, e:
    print("Could not create directory: {0}\nExiting".format(e))
    sys.exit(1)
else:
    print("Created directory at " + old_dir_path)


src_dirs = [cwd + dr for dr in dirs]
src_dirs = [os.path.join(cwd, dr) for dr in dirs]

#for src, dst, old in ((src_dir + "/" + fname, home + "/." + fname[1:], old_dir_path + fname) for src_dir in src_dirs for fname in os.listdir(src_dir)):
for src, dst, old in ((os.path.join(src_dir, fname), os.path.join(home, "." + fname[1:]), os.path.join(old_dir_path , fname)) for src_dir in src_dirs for fname in os.listdir(src_dir)):
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
