use v6;
use IO::Path::More;
use Test;



if $*OS ne any( <MSWin32 dos VMS MacOS> ) {

plan 23;

is IO::Path::More.new("hello").Str,	"hello",	"class loaded";
is ~path("foo/bar"),			"foo/bar",	"path() works";
is ~path("."),				".",		"current directory";
is ~path(".."),				"..",		"parent directory";
# is path(''),				".",		"empty is current directory";
is ~path("//usr/////local/./bin/././perl/"), "/usr/local/bin/perl", "canonpath called";

ok path("foo/bar").is_relative,		"relative path is_relative";
nok path("foo/bar").is_absolute,	"relative path ! is_absolute";
nok path("/foo/bar").is_relative,	"absolute path ! is_relative";
ok path("/foo/bar").is_absolute,	"absolute path is_absolute";

is path("foo/bar").absolute,		"$*CWD/foo/bar",	"absolute path from \$*CWD";
is path("foo/bar").absolute("/usr"),	"/usr/foo/bar",		"absolute path specified";
is path("/usr/bin").relative("/usr"),	"bin",			"relative path specified";
is path("foo/bar").absolute.relative,  "foo/bar",		"relative inverts absolute";
# is path("/foo/bar").relative.absolute.resolve, "/foo/bar",	"absolute inverts relative";

is path("foo/bar").parent,		"foo",			"parent";
is path(".").parent,			"..",			"parent of '.' is '..'";
is path("..").parent,			"../..",		"parent of '..' is '../..'";
is path("/foo").parent,			"/",			"parent at root is '/'";
is path("/").parent,			"/",			"parent of root is '/'";


is path("/").append('foo'),		"/foo",			"append to root";
is path(".").append('foo', 'bar'),	"foo/bar",		"append multiple";

say "# IO tests";
ok path($*CWD).e,		"cwd exists, inheritance ok";

ok path($*CWD).inode,		"inode works";
ok path($*CWD).device,		"device works";

}
else { plan 1; skip "all unix tests for now", 1; }

done;

