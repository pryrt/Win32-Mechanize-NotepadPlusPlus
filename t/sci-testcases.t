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

# setText("")
#   empty string would cause "WriteProcessMemory failed with error 87: the parameter is incorrect"
#       during appveyor tests, though not on my local machine
#   no separate bug report filed, though it was discovered during https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/15
{
    # prep
    notepad->newFile();

    editor->beginUndoAction();

    # add data
    editor->setText("Hello World");
    my $got = editor->getText();
    is $got, "Hello World", 'setText("Hello World") should set text';

    # set blank
    $got = undef;
    eval { editor->setText(""); 1; } or do { $got = "<crash: $@>"; };
    $got //= editor->getText();
    is $got, "", 'setText("") should clear text';

    # cleanup
    editor->endUndoAction();
    editor->undo();
    notepad->close();
}

# getTargetText()
#   2020-Apr-12: getTargetText seems to be dropping the last character, so add a test, and work on debugging until this passes
#   no separate bug report filed, though it was discovered during https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/15
#   In PythonScript, `editor.setTargetRange(6,11); editor.getTargetText()` on the text 'Hello World' will grab 'World'
#   Similarly, NppExec gives:
#       ================ READY ================
#       sci_sendmsg SCI_SETTARGETRANGE 6 11
#       SCI_SENDMSG: SCI_SETTARGETRANGE 6 11
#       ================ READY ================
#       sci_sendmsg SCI_GETTARGETTEXT 0 @"<str>"
#       SCI_SENDMSG: SCI_GETTARGETTEXT 0 @"<str>"
#       ================ READY ================
#       echo $(MSG_RESULT) $(MSG_WPARAM) $(MSG_LPARAM)
#       5  World
TODO: {
    # prep
    notepad->newFile();

    editor->beginUndoAction();

    # add data
    editor->setText("Hello World");
    my $got = editor->getText();
    is $got, "Hello World", 'setText("Hello World") should set text';

    # debug: manual version
    if(1) {
        # try manual messaging
        printf STDERR "SendMessage(SCI_SETTARGETRANGE,1,7) = %s\n",
            editor->SendMessage( $SCIMSG{SCI_SETTARGETRANGE}, 1, 7) // '<undef>';
        printf STDERR "SendMessage(SCI_GETTARGETSTART,0,0) = %s\n",
            my $sta = editor->SendMessage( $SCIMSG{SCI_GETTARGETSTART}, 0, 0) // '<undef>';
        printf STDERR "SendMessage(SCI_GETTARGETEND,0,0) = %s\n",
            my $end = editor->SendMessage( $SCIMSG{SCI_GETTARGETEND}, 0, 0) // '<undef>';
        printf STDERR "SendMessage(SCI_GETTARGETTEXT,0,0) = %s\n",
            my $len = editor->SendMessage( $SCIMSG{SCI_GETTARGETTEXT}, 0, 0) // '<undef>';

        my $buf = Win32::GuiTest::AllocateVirtualBuffer( editor->hwnd, 100+$len );
        Win32::GuiTest::WriteToVirtualBuffer( $buf, "\0"x$len );
        my $rslt = editor->SendMessage( $SCIMSG{SCI_GETTARGETTEXT}, 0, $buf->{ptr});
        my $rbuf = Win32::GuiTest::ReadFromVirtualBuffer( $buf, $len );
        printf STDERR "SendMessage(SCI_GETTARGETTEXT,0,0x%08x) = %s => '%s'\n",
            $rslt, $buf->{ptr}, $rbuf;
        Win32::GuiTest::FreeVirtualBuffer( $buf );

        # the manual debug version _worked_, so it's definitely something with the wrapper
    }

    # test
    my $exp = 'World';  # position 6-11
    $got = undef;
    editor->setTargetRange(6,11);
    is editor->getTargetStart, 6, 'getTargetStart() should be 6';
    is editor->getTargetEnd, 11, 'getTargetEnd() should be 11';
    eval { $got = editor->getTargetText(); 1; } or do { $got = "<crash: $@>"; };
    local $TODO = "off-by-one on stringlength";
    is $got, $exp, 'getTargetText() from (6,11) should be "World"';

    # cleanup
    editor->endUndoAction();
    editor->undo();
    notepad->close();
}


done_testing;
