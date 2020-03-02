########################################################################
# the following were added to test for specific bugs or issues found after
#   release, for things
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

use FindBin;
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

# https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/14
# getLine() for empty line should NOT return \0
{
    notepad->newFile();
    my $txt = editor->getLine(1);
    isnt $txt, "\0", 'ISSUE#14: getLine() for empty line should NOT return \0'
        or diag sprintf "\t!!!!! getLine = \"%s\" !!!!!\n", dumper($txt);
    is $txt, "", 'ISSUE#14: getLine() for empty line SHOULD return empty string';
}

done_testing;
