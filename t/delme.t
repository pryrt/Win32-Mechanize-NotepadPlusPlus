########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for GUI manipulation
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

# getShortcutByCommandId()/getShortcutByCmdId()
# appears to only work on plugin commands... and none of them default to having a shortcut
TODO: {
    local $TODO = "getShortcutByCmdId still being implemented/debugged";
    # manually set shortcut; TODO = need to figure out how to set that via my test suite without changing config files
    myTestHelpers::setShortcutMapper('Plugin commands', 1, 1,1,1,'E');
    my $ret = [notepad->getShortcutByCmdId( 22000 )]; # needs to be a plugin cmdID
    my $exp = [1,1,1,'E'];
    is_deeply $ret, $exp, 'getShortcutByCmdId(MIMETools > Base64 Encode) should be Ctrl+Alt+Shift+E'
        or diag "\t[", join(", ", @$ret), "] vs [", join(", ", @$exp), "]";
}

done_testing;
