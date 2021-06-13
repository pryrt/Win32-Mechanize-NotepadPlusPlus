########################################################################
# Verifies Notepad.pm::getShortcutByCmdId() / removeShortcutByCmdId
#   prompts the user to manually change the shortcut, for use in
#   debugging
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

#use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# getShortcutByCmdId()/removeShortcutByCmdId()
# appears to only work on plugin commands... and none of them default to having a shortcut
# for the manual version (in xt\ hierarchy), I will just prompt the tester to make the
# appropriate changes
 

# in my testing rig, 22000 is Plugins > MIME Tools > Base64 Encode
my $safeCmdId = 22000;
my $pluginText = "MIME Tools > Base64 Encode";

diag "\n\nPlease change shortcut of '$pluginText' (id=$safeCmdId) to Ctrl+Alt+Shift+E, then hit ENTER here\n\n";
<STDIN>;

my $ret = [notepad->getShortcutByCmdId( $safeCmdId )];
my $exp = [1,1,1,'E'];
is_deeply $ret, $exp, 'getShortcutByCmdId(MIMETools > Base64 Encode) manually set to Ctrl+Alt+Shift+E'
    or diag "\t[", join(", ", @$ret), "] vs [", join(", ", @$exp), "]";

$ret = notepad->removeShortcutByCmdId( $safeCmdId );
ok $ret, 'removeShortcutByCmdId(MIMETools > Base64 Encode) -- should return true'
    or diag "\t[", join(", ", @$ret), "] vs [", join(", ", @$exp), "]";

$ret = [notepad->getShortcutByCmdId( $safeCmdId )];
$exp = [0,0,0,''];
is_deeply $ret, $exp, 'getShortcutByCmdId(MIMETools > Base64 Encode) should be cleared now'
    or diag "\t[", join(", ", @$ret), "] vs [", join(", ", @$exp), "]";

done_testing;
