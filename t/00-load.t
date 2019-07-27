########################################################################
# Verifies the module loads are okay
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 4;

BEGIN {
    foreach my $ModUnderTest (
        'Win32::Mechanize::NotepadPlusPlus',
        'Win32::Mechanize::NotepadPlusPlus::Notepad',
        'Win32::Mechanize::NotepadPlusPlus::Editor',
        'Win32::Mechanize::NotepadPlusPlus::__hwnd',
    ) {
        use_ok( $ModUnderTest ) or diag "Couldn't even load $ModUnderTest";
    }
}
