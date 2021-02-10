########################################################################
# Coverage tests for Notepad.pm application error conditions
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More ;#tests => 4;
use Test::Exception;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use myTestHelpers qw/:all/;
myTestHelpers::setChildEndDelay(2);

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# ->editor() errors
{
    throws_ok {
        no warnings qw/redefine/;
        local *Win32::Mechanize::NotepadPlusPlus::Notepad::getCurrentView = sub { -1 };
        Win32::Mechanize::NotepadPlusPlus::editor();
    } qr/^\QNotepad->editor(): unknown GETCURRENTSCIINTILLA=\E/, '->editor() unknown view';
}
# ->open() errors
{
    throws_ok {
        notepad->open();
    } qr/^\Q->open() method requires \E\$\QfileName argument\E/, '->open() without filename';

    throws_ok {
        no warnings qw/redefine/;
        local *Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_sendStrAsUcs2le = sub { die "test coverage\n" };
        notepad->open('testcoverage.txt');
    } qr/^->open\(.*?\) died with msg:/, '->open() eval failed';
}

# ->createScintilla() errors
{
    my $keep_hwnd = notepad()->{_hwnd};
    throws_ok { # also covers ||= conditions 0,0
        notepad()->{_hwnd} = undef;
        notepad()->createScintilla(undef);
    } qr/\Qrequires HWND to use as the parent, not undef or an object\E/, '->createScintilla(undef) invalid parent with false _hwnd';

    throws_ok { # also covers ||= conditions 0,1
        notepad()->{_hwnd} = [];
        notepad()->createScintilla(undef);
    } qr/\Qrequires HWND to use as the parent, not undef or an object\E/, '->createScintilla(undef) invalid parent with true _hwnd';

    throws_ok { # also covers ||= conditions 1,x
        notepad()->createScintilla([]);
    } qr/\Qrequires HWND to use as the parent, not undef or an object\E/, '->createScintilla([]) invalid parent with true argument';

    notepad->{_hwnd} = $keep_hwnd;
}

# ->runMenuCommand() ->_findActionInMenu() uncovered case
#   I don't think there's any real way to get to the "else return 0" inside _findActionInMenu, but
#       I can mock it by changing GetMenuItemID, so I'll cover that "error" condition.
TODO: {
    local $TODO = "not running the right line of code; need to add in debugging statements and figure out what _is_ running, so I can properly mock";
    no warnings qw/redefine/;
    local *Win32::Mechanize::NotepadPlusPlus::Notepad::GetMenuItemID = sub { 0 };
    my $retval = notepad()->runMenuCommand('File | New');
    ok !$retval, '->runMenuCommand() unexpected condition: getMenuCommandID returning false';
}

done_testing;
