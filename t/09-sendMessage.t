########################################################################
# Verifies messaging
#   notepad()
#   editor1()
#   editor2()
#   console()
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;

use Win32::Mechanize::NotepadPlusPlus::Notepad;
BEGIN {
    my $MUT = 'Win32::Mechanize::NotepadPlusPlus::__hwnd';      # module under test
    use_ok( $MUT ) or diag "Couldn't even load $MUT";
}

use Win32::Mechanize::NotepadPlusPlus::__npp_msgs;  # exports %nppm, which contains the messages used by Notepad++

my $npp = Win32::Mechanize::NotepadPlusPlus::Notepad->new();
isa_ok $npp, 'Win32::Mechanize::NotepadPlusPlus::Notepad', 'NPP object created';
ok $npp->{_hwnd}, 'NPP object has non-zero hwnd' or diag explain $npp;

my $w = Win32::Mechanize::NotepadPlusPlus::__hwnd->new($npp->{_hwnd});
isa_ok $w, 'Win32::Mechanize::NotepadPlusPlus::__hwnd', 'NPP object created';

my $view = $w->SendMessage($nppm{NPPM_GETCURRENTVIEW}, 0, 0);
like $view, qr/^[01]$/, 'GetCurrentView (should be 0 or 1): '. ($view//'<undef>');

my $ival = $w->SendMessage_get32u($nppm{NPPM_GETCURRENTLANGTYPE}, 0);
ok defined $ival, 'SendMessage_get32u: ' . ($ival//'<undef>');

my $sval = $w->SendMessage_getUcs2le($nppm{NPPM_GETLANGUAGEDESC}, $ival);
ok defined $sval, 'GetLanguageDesc('.($ival//'<undef>').'): "' . ($sval//'<undef>') . '"';

done_testing();