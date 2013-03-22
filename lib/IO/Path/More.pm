class IO::Path::More is IO::Path;

use File::Spec;
my $Spec = File::Spec.new;

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
multi method new(Str:D $path) {
	my ($volume, $directory, $basename) = $Spec.splitpath($Spec.canonpath($path));
	$directory = $Spec.curdir if $directory eq '';
	self.new(:$basename, :$directory, :$volume);
}

#multi method new(Str:D $path, :$OS) {
#	$Spec = File::Spec.new(:$OS);
#	my ($volume, $directory, $basename) = $Spec.splitpath($Spec.canonpath($path));
#	$directory = $Spec.curdir if $directory eq '';
#	self.new(:$basename, :$directory, :$volume, :$OS);
#}
	

submethod BUILD(:$!basename, :$!directory, :$!volume, :$dir, :$OS) {
	die "Named paramter :dir in IO::Path.new deprecated in favor of :directory"
	    if defined $dir;
	$Spec = File::Spec.new(:$OS);
}

# Another IO::Path override due to the $volume, and the use of catpath.
method path(IO::Path:D:) {
	$Spec.catpath($.volume, ($.directory eq '.' ?? '' !! $.directory), $.basename);
}
# Final override, because I like full path on stringification better
#   and it seems like less of a surprise.
multi method Str(IO::Path:D:) {
	self.path;
}


method is_absolute {
	$Spec.file_name_is_absolute($.path);
}

method is_relative {
	! $Spec.file_name_is_absolute($.path);
}

method cleanup {
	return self.new($Spec.canonpath($.path));
}

method resolve {
	fail "Not Yet Implemented: requires readlink()";
}

method absolute {
	return self.new($Spec.rel2abs($.path))
}

method relative ($relative_to_directory as Str = Str) {
	return self.new($Spec.abs2rel($.path, $relative_to_directory));
}

method parent {
	my @dirs = $Spec.splitdir($.directory);
	if self.is_absolute {
		return self.new($Spec.catpath($.volume, $Spec.catdir(@dirs), ''));
		# catdir to get rid of trailing slash; '' instead of basename.
	}
	elsif all($.basename, $.directory) eq $Spec.curdir {
		return self.new($Spec.updir);
	}
	elsif $.basename eq $Spec.updir && $.directory eq $Spec.curdir 
	   or !grep({$_ ne $Spec.updir}, @dirs) {  # All updirs, then add one more
		return self.new($Spec.catpath($.volume, $Spec.catdir(@dirs, $Spec.updir), $.basename));
	}
	else {
		return self.new($Spec.catpath($.volume, $Spec.catdir(@dirs), ''));
	}
}

multi method append (*@nextpaths) {
	my $lastpath = @nextpaths.pop // '';
	self.new($Spec.catpath($.volume, $Spec.catdir($.directory, $.basename, @nextpaths), $lastpath));
}


method touch {
	fail "Not Yet Implemented: requires utime()";
}

method stat {
	fail "Not Yet Implemented: requires stat()";
}

# Some methods added in the absence of a proper IO.stat call
method inode() {
	$*OS ne 'Win32'   #this could use a better way of asking "am I posixy?
	&& self.e
	&& nqp::p6box_i(nqp::stat(nqp::unbox_s($.path), pir::const::STAT_PLATFORM_INODE))
}

method device() {
	self.e && nqp::p6box_i(nqp::stat(nqp::unbox_s($.path), pir::const::STAT_PLATFORM_DEV))
}

