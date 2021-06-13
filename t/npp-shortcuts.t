########################################################################
# Verifies Notepad.pm::getShortcutByCmdId() / removeShortcutByCmdId
#   spoofs the reply from Notepad++, for use in automated testing,
#   because automated environment cannot guarantee what plugins are
#   installed or what shortcuts are assigned
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use myTestHelpers;
myTestHelpers::setChildEndDelay(6);

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# getShortcutByCmdId()
#   mocks the SendMessage_getRawString(), which is called by getShortcutByCmdId, 
#   so that I can guarantee the "shortcut" that getShortcutByCmdId processes
#   True functionality test is in xt\npp-shortcuts-manual.t
{
    no warnings qw/redefine/;
    local *Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getRawString = sub { "\x{01}\x{01}\x{01}E" };
    my $ret = [notepad->getShortcutByCmdId( 22000 )]; # needs to be a plugin cmdID
    my $exp = [1,1,1,'E'];
    is_deeply $ret, $exp, 'getShortcutByCmdId() [mocked message]'
        or diag "\t[", join(", ", @$ret), "] vs [", join(", ", @$exp), "]";
}

# removeShortcutByCmdId()
#   mocks the SendMessage(), which is called by removeShortcutByCmdId, 
#   so that I can guarantee that it doesn't destroy the uers' shortcut,
#   and so I can know what state the SendMessage will return.
#   True functionality test is in xt\npp-shortcuts-manual.t
{
    no warnings qw/redefine/;
    local *Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage = sub { 1 };
    my $ret = notepad->removeShortcutByCmdId( 22000 ); # needs to be a plugin cmdID
    ok $ret, 'removeShortcutByCmdId() [mocked message]';
}

done_testing;
