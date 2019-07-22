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

# http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
use constant WM_GETTEXT => 0x0d;                    # from example 2.3, above
use constant WM_USER => 0x400;                      # https://msdn.microsoft.com/en-us/library/windows/desktop/ms644931(v=vs.85).aspx
use constant NPPMSG => WM_USER + 1000;
use constant NPPM_SAVECURRENTFILE => NPPMSG + 38;
use constant NPPM_GETNBOPENFILES => NPPMSG + 7;         # args(0, nbType)
use constant NPPM_GETCURRENTLANGTYPE => NPPMSG + 5;     # args(0, out int *)
use constant NPPM_GETLANGUAGENAME => NPPMSG + 83;       # args(int LangType, out char*)
use constant NPPM_GETLANGUAGEDESC => NPPMSG + 84;       # args(int LangType, out char*)
use constant NPPM_GETCURRENTVIEW => NPPMSG + 88;        # args(0,0)


my $npp = Win32::Mechanize::NotepadPlusPlus::Notepad->new();
isa_ok $npp, 'Win32::Mechanize::NotepadPlusPlus::Notepad', 'NPP object created';
ok $npp->{_hwnd}, 'NPP object has non-zero hwnd' or diag explain $npp;

my $w = Win32::Mechanize::NotepadPlusPlus::__hwnd->new($npp->{_hwnd});
isa_ok $w, 'Win32::Mechanize::NotepadPlusPlus::__hwnd', 'NPP object created';

my $view = $w->SendMessage(NPPM_GETCURRENTVIEW, 0, 0);
like $view, qr/^[01]$/, 'GetCurrentView (should be 0 or 1)';

my $ival = $w->SendMessage_get32u(NPPM_GETCURRENTLANGTYPE, 0);
ok defined $ival, 'SendMessage_get32u: ' . ($ival//'<undef>');

my $sval = $w->SendMessage_getUcs2le(NPPM_GETLANGUAGEDESC, $ival);
ok defined $sval, 'GetLanguageDesc('.($ival//'<undef>').'): "' . ($sval//'<undef>') . '"';

done_testing();