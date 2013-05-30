Dotfiles
=======
My personal dotfiles + an installer script and a few other fun things.

- bash: A few bash aliases from my pre-zsh times.  Also contains my .profile, which I rely on to set paths and whatnot.
- various: Assorted config files, primarily used for python convenience functions and my pentadactyl(firefox extension) config.
- vim: Where most of my customization has gone.  Some of my plugins could still use some organizing/weeding out, but my vimrc is readable and full of nice settings and mappings. Oh and my jellybeans theme is absolutely butchered in order to work with a transparent prompt and meet my bizarre needs.
- zsh: I use oh-my-zsh with a zshrc full of personalized mappings and a few customzied settings.  Also I use a funky two-line prompt.
- install.py: Symlinks all my dotfiles into my home directory.  It also checks for a ~/.dotfiles_config file, which is used to set machine-specific settings for things like a general "code directory".
