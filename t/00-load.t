########################################################################
# Verifies the module loads are okay
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    foreach my $ModUnderTest (
        'Win32::Mechanize::NotepadPlusPlus',
        'Win32::Mechanize::NotepadPlusPlus::Notepad',
        'Win32::Mechanize::NotepadPlusPlus::Editor',
        'Win32::Mechanize::NotepadPlusPlus::__hwnd',
        'Win32::Mechanize::NotepadPlusPlus::__npp_msgs',
    ) {
        use_ok( $ModUnderTest ) or diag "Couldn't even load $ModUnderTest";
    }
}
