p6-IO-Path-More
===============

IO::Path::More - Extends IO::Path to make it more like p5's Path::Class

## SYNOPSIS

	#Create a path object
	$path1 = path 'foo/bar/baz.txt';
	$path2 = IO::Path::More.new('/usr/local/bin/perl6');

	#We can do anything that IO::Path does
	say "file exists" if $path2.e;
	my @lines = $path1.open.lines;

	# But wait, there's More!
	say $path1.absolute;                    # "/current/directory/foo/bar/baz.txt"
	say $path2.relative("/usr/local");      # "bin/perl6"
	say $path1.is_absolute;                 # False
	say $path1.is_relative;                 # True
	say $path1.parent.append('quux.txt');   # "foo/bar/quux.txt"
	$path1.=parent;                         # mutating method sets $path1 to "foo/bar"

	# path cleanup happens automatically
	say path "1///2/./3////4";              # "1/2/3/4"

	# Not quite working yet: Foreign paths
	# It should work correctly if you run Windows, though.
	$WindowsPath = IO::Path::More.new('C:\\bar\\baz\\\\', OS => 'MSWin32');
	#                                     ^ don't forget to escape your backslashes
	say $WindowsPath;                       # "C:\bar\baz"
	say $WindowsPath.volume;                # "C:"

	
## DESCRIPTION

IO::Path::More is intended to be a cross-platform replacement for the built-in IO::Path.  Internally, we use File::Spec to deal with all of the issues on differing paths on different operating systems.  Currently, only Win32 and Unix-type systems are finished (including Mac OS X) in File::Spec, but support should get better as File::Spec gains more OSes.

## METHODS
This module provides a class based interface to all sorts of filesystem related functions on paths.

Which I'm just going to list for now:

* is\_absolute()
* is\_relative()
* absolute()
* relative( Str $relative\_to\_directory) # default $*CWD
* parent() # warning, does not check for symlinks
* append( *@parts )
* inode   # POSIX only
* device
* basename
* directory
* volume
* cleanup  # usually called by default, unless you call .new with all named parameters
* find(:$name, :$type, Bool :$recursive = True)  # Calls File::Find, which is not 100% cross-platform yet.

Not yet implemented due to missing features in Rakudo:
* touch
* resolve
* stat

## TODO

* NYI above
* Foreign paths

## SEE ALSO

* [File::Spec](https://github.com/FROGGS/p6-File-Spec)

## AUTHOR

Brent "Labster" Laabs, 2013.

Contact the author at bslaabs@gmail.com or as labster on #perl6.  File [bug reports](https://github.com/labster/p6-IO-Path-More/issues) on github.

## COPYRIGHT

The code under the same terms as Perl 6; see the LICENSE file for details.