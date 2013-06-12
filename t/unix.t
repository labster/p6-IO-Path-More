use v6;
use IO::Path::More;
use Test;



if $*OS ne any( <MSWin32 dos VMS MacOS> ) {

plan 10;

is IO::Path::More.new("hello").Str,	"hello",	"class loaded";
is path("foo/bar"),			"foo/bar",	"path() works";
is path("."),				".",		"current directory";
is path(".."),				"..",		"parent directory";
# is path(''),				".",		"empty is current directory";
is path("//usr/////local/./bin/././perl/").cleanup, "/usr/local/bin/perl", "canonpath called";

is path("/").append('foo'),		"/foo",			"append to root";
is path(".").append('foo', 'bar'),	"foo/bar",		"append multiple";

say "# IO tests";
ok path(~$*CWD).e,		"cwd exists, inheritance ok";

ok path(~$*CWD).inode,		"inode works";
ok path(~$*CWD).device,		"device works";

}
else { plan 1; skip "all unix tests for now", 1; }

done;

