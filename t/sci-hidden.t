########################################################################
# Coverage for hidden functions
#   to try to get better code coverage using `*make testcover`
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use myTestHelpers qw/:userSession dumper/;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.
my $EmergencySessionHash;
BEGIN { $EmergencySessionHash = saveUserSession(); }
END { restoreUserSession( $EmergencySessionHash ); }

BEGIN {
    notepad()->closeAll();
    notepad()->open( path($0)->absolute->canonpath() );
}

# coverage: __test_autogen -- do not use this function in production code
#   normally run in xt\ ; added a quick check to the normal test suite to get to 100% LOC coverage
{
    my %h = Win32::Mechanize::NotepadPlusPlus::Editor::__test_autogen();
    ok scalar keys %h, 'internal coverage: scintilla methods correctly auto-generated';
}

# coverage: __dumper -- do not use this function in production code
#   this really only exists for debugging some of the tests
{
    is_deeply [Win32::Mechanize::NotepadPlusPlus::Editor::__dumper(undef,"a\tb")], 
        ['<undef>',"a\\x{09}b"], 
        'internal coverage: debug function (not used by end-user)';
}

# coverage: autogen tracers -- do not use these functions in production code
#   this really only exists for debugging some of the tests
{
    is Win32::Mechanize::NotepadPlusPlus::Editor::__trace_autogen(), 1, 'internal coverage: enable tracing (not used by end-user)';
    is Win32::Mechanize::NotepadPlusPlus::Editor::__untrace_autogen(), 0, 'internal coverage: disable tracing (not used by end-user)';
}
done_testing;
