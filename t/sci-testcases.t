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
{
    # prep
    notepad->newFile();

    # original #14: getLine(1) for empty line should NOT return \0
    my $txt = editor->getLine(1);
    isnt $txt, "\0", 'ISSUE#14: getLine() for empty line should NOT return \0'
        or diag sprintf "\t!!!!! getLine = \"%s\" !!!!!\n", dumper($txt);
    is $txt, "", 'ISSUE#14: getLine() for empty line SHOULD return empty string';

    # reopen #14: ditto for getSelText()
    $txt = editor->getSelText();
    isnt $txt, "\0", 'ISSUE#14: getSelText() for empty selection should NOT return \0'
        or diag sprintf "\t!!!!! getLine = \"%s\" !!!!!\n", dumper($txt);
    is $txt, "", 'ISSUE#14: getSelText() for empty selection SHOULD return empty string';

    TODO: {
        # debug: can I tell the difference between the empty string of getSelText and actually finding a NUL character in the selection?
        local $TODO = "NUL to SPACE probably caused by Scintilla";
        editor->addText("\0");
        editor->selectAll();
        $txt = editor->getSelText();
        is $txt, "\0", 'getSelText() for actual NUL \\0 SHOULD return \\0 string' or
            diag sprintf "\t!!!!! getLine = \"%s\" intentional \\0 !!!!!\n", dumper($txt);
        editor->undo();
    }

    # cleanup
    notepad->close();
}

done_testing;
