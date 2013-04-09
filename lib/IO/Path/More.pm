class IO::Path::More is IO::Path;

use File::Spec;
use File::Find;
my $Spec;

has Str $.basename;
has Str $.directory;
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

# Constructors.  Need to override IO::Path due to $:volume.
multi method new(Str:D $path is copy, :$OS = $*OS, :$raw = False) {
	$Spec := File::Spec.os($OS);
	$path = $Spec.canonpath($path) unless $raw;
	my ($volume, $directory, $basename) = $Spec.split($path);
	self.new(:$basename, :$directory, :$volume, :$OS);
}

submethod BUILD(:$!basename, :$!directory, :$!volume, :$dir, :$OS = $*OS) {
	die "Named paramter :dir in IO::Path.new deprecated in favor of :directory"
	    if defined $dir;
	$Spec := File::Spec.os($OS);
}

# TODO: Another IO::Path override to make .path return self.
#method path {   self   }
# TODO: until IO::Path is updated to spec:
method path(IO::Path::More:D:) {
	$.Str
}

#method path(IO::Path::More:D: ) { self.Str }
# Final override, until IO::Path is fixed
#  specifically due to the $volume, and the use of join
multi method Str(IO::Path::More:D:) {
	$Spec.join($.volume, $.directory, $.basename);
}


method is-absolute {
	$Spec.file-name-is-absolute(~self);
}

method is-relative {
	! $Spec.file-name-is-absolute(~self);
}

method cleanup {
	return self.new($Spec.canonpath(~self));
}

method resolve {
	fail "Not Yet Implemented: requires readlink()";
}

method absolute ($base = Str) {
	return self.new($Spec.rel2abs(~self, $base))
}

method relative ($relative_to_directory = Str) {
	return self.new($Spec.abs2rel(~self, $relative_to_directory));
}

method parent {
	if self.is-absolute {
		return self.new($Spec.join($.volume, $.directory, ''));
		# empty instead of basename.
	}
	elsif all($.basename, $.directory) eq $Spec.curdir {
		return self.new($Spec.updir);
	}
	elsif $.basename eq $Spec.updir && $.directory eq $Spec.curdir 
	   or !grep({$_ ne $Spec.updir}, $Spec.splitdir($.directory)) {  # All updirs, then add one more
		return self.new($Spec.join($.volume, $Spec.catdir($.directory, $Spec.updir), $.basename));
	}
	else {
		return self.new( $Spec.join($.volume, $.directory, '') );
	}
}

method append (*@nextpaths) {
	my $lastpath = @nextpaths.pop // '';
	self.new($Spec.join($.volume, $Spec.catdir($.directory, $.basename, @nextpaths), $lastpath));
}


method remove {
	if self.d { rmdir  ~self }
	else      { unlink ~self }
}


method rmtree {
	fail "Not Yet Implemented: requires File::Path";
}

method mkpath {
	fail "Not Yet Implemented: requires File::Path";
}

method touch {
	fail "Not Yet Implemented: requires utime()";
}

method stat {
	fail "Not Yet Implemented: requires stat()";
}

method find (:$name, :$type, Bool :$recursive = True) {
	#find(dir => ~self, :$name, :$type, :$recursive);
	find(dir => ~self, :$name, :$type)
}

# Some methods added in the absence of a proper IO.stat call
method inode() {
	$*OS ne any(<MSWin32 os2 dos NetWare symbian>)   #this could use a better way of asking "am I posixy?
	&& self.e
	&& nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), pir::const::STAT_PLATFORM_INODE))
}

method device() {
	self.e && nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), pir::const::STAT_PLATFORM_DEV))
}

