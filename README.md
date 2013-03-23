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

## INTERFACE

There are two ways to create an IO::Path::More object.  Either though the object interface, or via the path function.
	IO::Path::More.new( $mypath );
	path $mypath;
While you can create a path object with named arguments, you probably shouldn't, unless you don't want path cleanup to happen.

Note that the methods do not actually transform the object, but rather return a new IO::Path::More object.  Therefore, if you want to change the path, use a mutating method, like `$path.=absolute`.

## METHODS
This module provides a class based interface to all sorts of filesystem related functions on paths.

Which I'm just going to list for now:

#### path and Str
Returns the entire path, put together, as a string.

#### basename
Returns the name of the file as a string.

#### directory
Returns the directory portion of the file path as a string.  For example, for `/usr/bin/perl`, the result would be `"/usr/bin"`.

#### volume
Returns the volume portion of the file path, if such a thing has meaning on the current platform; otherwise it returns an empty string.  For example, with `C:\\WINDOWS\\SYSTEM32`, the string `"C:"` will be returned.

#### is\_absolute
Takes no arguments.  Returns True if the path is an absolute path, false otherwise.

#### is\_relative
Takes no arguments.  Returns True if the path is an relative path, false otherwise.  This is always the opposite result of is\_absolute.

#### absolute( Str $base = $*CWD )
Transforms the path into an absolute path (if it is not already absolute), and returns a new IO::Path::More object.  If you supply a base path, it will transform relative to that directory -- otherwise, it will just use the current working directory.  Returns a new IO::Path::More object.

If you're doing this on a foreign file system, you had better provide the base, or you'll end up with something wierd like `C:\\WINDOWS\\local/bin/perl6`.

#### relative( Str $relative\_to\_directory = $*CWD)
Transforms the path into a relative path, and returns the result in an IO::Path::More.  If no parameter is supplied, as above, the current working directory will be used as a default.

The same caveat on foreign file systems applies here.

#### parent()
Returns the parent of the current path as a new object.  Warning, this does not check for symbolic links -- only the written path as given will be considered.

On a Unix/POSIX filesystem, it will work like so:
	parent level          relative       absolute
	Starting Path (0)     foo/bar        /foo/bar
	1                       foo            /foo
	2                        .              /
	3                        ..             /
	4                      ../..            /
	5                     ../../..          /

#### append( *@parts )
Concatenates anything passed onto the end of the path, and returns the result in a new object.  For example, `(path "/foo").append(<bar baz/zig>)` will return a path of `/foo/bar/baz/zig`.

#### find(:$name, :$type, Bool :$recursive = True)
Calls File::Find with the given options, which are explained in the File::Find documentation.  Note that File::Find is not 100% cross-platform yet, so beware on systems where '/' is not a path separator.

#### remove
Deletes the current path.  Calls unlink if the path is a file, or calls rmdir if the path is a directory.  Fails if there are files in the directory, or if you do not have permission to delete the path.

To remove an entire directory with its contents, see `rmtree`.

#### cleanup
Cleans up the path, using File::Spec.canonpath to do the work, and returns a new path.  Paths created with without named parameters (`basename` and the like) cleanup by default, so you shouldn't typically have to do this.

### IO methods
Methods included in IO::Path (notably .open, .close, and .contents) are available here.  See [S32/IO](http://perlcabal.org/syn/S32/IO.html) for details.

### NYI Methods
Not yet implemented due to missing features in Rakudo:
* touch   (needs utime)
* resolve (needs readlink)
* stat    (needs stat)

Not yet implemented due to missing modules:
* mkpath (needs File::Path)
* rmtree (needs File::Path)

### Filetest methods

#### .e, .d, .l, etc...
Builtin methods are reproduced here.  Because we inherit from IO::Path, IO::Path::More does IO::Filetestable.

#### inode
Returns the inode number of the current path as an Int.  If you're not on a POSIX system, returns False.  Inode numbers uniquely identify files on a given device, and all hard links point to the same inode.

#### device
Returns the device number of the current path.

## TODO

* NYI above
* Foreign paths

## SEE ALSO

* [File::Spec](https://github.com/FROGGS/p6-File-Spec)
* [File::Tools](https://github.com/tadzik/perl6-File-Tools/) - the source of File::Find

## AUTHOR

Brent "Labster" Laabs, 2013.

Contact the author at bslaabs@gmail.com or as labster on #perl6.  File [bug reports](https://github.com/labster/p6-IO-Path-More/issues) on github.

## COPYRIGHT

The code under the same terms as Perl 6; see the LICENSE file for details.
