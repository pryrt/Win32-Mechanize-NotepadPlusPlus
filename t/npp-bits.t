########################################################################
# Try to determine Notepad++'s bitness, and compare it to Perl's
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';     # 1.64 required for 64-bit SendMessage

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

use FindBin;
use lib $FindBin::Bin;
use myTestHelpers qw/:userSession/;
use Path::Tiny 0.018 qw/path tempfile/;

#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.
my $EmergencySessionHash;
BEGIN { $EmergencySessionHash = saveUserSession(); }
END { restoreUserSession( $EmergencySessionHash ); }

BEGIN {
    notepad()->closeAll();
}

SetForegroundWindow( notepad->{_hwnd} );
sleep(1);
is GetForegroundWindow(), notepad->{_hwnd}, 'right foreground window';
diag sprintf "\tGetForegroundWindow(): %s\n", GetForegroundWindow()//'<undef>';

notepad()->menuCommand($nppidm{IDM_DEBUGINFO});
sleep(1);
isnt GetForegroundWindow(), notepad->{_hwnd}, 'Debug Info should be foreground window';
diag sprintf "\tGetForegroundWindow(): %s\n", GetForegroundWindow()//'<undef>';
is my $dlgname = WMGetText(GetForegroundWindow()), 'Debug Info', 'Debug Info: check dialog name';
diag sprintf "\tWM_GETTEXT = \"%s\"\n", $dlgname;

# need some way to click the "Copy debug info into clipboard" button...
#PushButton("Copy debug info into clipboard");
#sleep(1);

# done with dialog
PushButton("OK", 0.5);
sleep(1);

# get it to someplace useable
editor()->paste();
sleep(2);

# cleanup
editor()->undo();

# verify
like notepad->getPerlBits(), qr/^(32|64)$/, 'getPerlBits()';
diag sprintf "\tgetPerlBits() = %s\n", notepad->getPerlBits()//'<undef>';
done_testing;