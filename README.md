# alwaysontop.sh

Peter Swire - swirepe.com

## What is it?

It keeps your bash prompt at the top of the screen.  It also:

* clears the screen automatically
* lists the contents of directories upon entering them
* abbreviates those contents of there would be too many.
* shows the git or svn status in directories that have them

[ascii.io cast](http://ascii.io/a/3779)


## Why?

I had a pretty long train commute, and I found that at the end of it, my neck would hurt from hunching.

## How do I use it?

Source (don't run) the file `alwaysontop.sh`.  Turn it off with unautotop.  From the help output:

    alwaysontop.sh - keep the prompt at the top of the screen.
    Included commands:

	alwaysontop_help  This screen

	autotop           Turn ON always on top and autoclear
	unautotop         Turn OFF always on top and autoclear

	alwaysontop       Turn ON always on top
	unalwaysontop     Turn OFF always on top

	autoclear         Turn ON clear-screen after each command.
	unautoclear       Turn OFF clear-screen after each command.

	alwaysontop indicator:  ↑↑
	autoclear indicator:    ◎



[ascii.io cast](http://ascii.io/a/3779)

## How can I help?

Could you port this to zsh?  I'll buy you some cookies or something.

Special thanks to [rileyberton](https://github.com/rileyberton) for adding in the svn status.
