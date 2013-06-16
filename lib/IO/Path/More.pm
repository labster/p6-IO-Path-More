class IO::Path::More is IO::Path;

use File::Find;
use Shell::Command;

has Str $.basename;
has Str $.directory = '.';
has Str $.volume = '';

##### Functions for Export: path() variants ######
# because Str.path is already taken by IO::Path
multi sub path (Str:D $path) is export {
	IO::Path::More.new($path);
}
multi sub path (:$basename, :$directory, :$volume = '') is export {
	IO::Path::More.new(:$basename, :$directory, :$volume)
}
##################################################

method append (*@nextpaths) {
	my $lastpath = @nextpaths.pop // '';
	self.new($.SPEC.join($.volume, $.SPEC.catdir($.directory, $.basename, @nextpaths), $lastpath));
}


method remove {
	if self.d { rmdir  ~self }
	else      { unlink ~self }
}


method rmtree {
	rm_rf(~self)
}

method mkpath {
	mkpath(~self)
}

method touch {
	fail "Not Yet Implemented: requires utime()";
}

method stat {
	fail "Not Yet Implemented: requires stat()";
}

method find (:$name, :$type, Bool :$recursive = True) {
	find(dir => ~self, :$name, :$type, :$recursive);
	#find(dir => ~self, :$name, :$type)
}

# Some methods added in the absence of a proper IO.stat call
method inode() {
	$*OS ne any(<MSWin32 os2 dos NetWare symbian>)   #this could use a better way of asking "am I posixy?
	&& self.e
	&& nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_INODE))
}

method device() {
	self.e && nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_DEV))
}

method nextitem {
	my @dir := self.parent.contents;
	if self.e {
		while (@dir.shift ne self.basename) { ; }
		self.new(~@dir.shift);
        }
        else {
		self.new(~first { self.basename leg $_ ~~ Increase}, @dir.sort);
        }
}

