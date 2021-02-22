########################################################################
# HWND: Coverage for hidden functions and special cases
#   to try to get better code coverage using `*make testcover`
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Win32;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

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

# check hwnd tracing
{
    editor->setText("Line 1\r\nLine 2");
    is editor->{_hwobj}->__trace_raw_string(), 1, 'coverage: enable tracing';
    my $call = editor()->{_hwobj}->SendMessage_getRawString( $SCIMSG{SCI_GETLINE}, 1, { trim => 'retval' } );
    ok $call, 'coverage: tracing didn\'t fail'
        or diag sprintf "call:'%s'\n", $call//'<undef>';
    is editor->{_hwobj}->__untrace_raw_string(), 0, 'coverage: disable tracing';
    editor->setText("");

    # cleanup -- make sure it doesn't try to save changes on exit
    editor->setSavePoint();
}

# SendMessage
{
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage(undef) } qr/\Qno object sent\E/, '__hwnd::SendMessage(undef): missing object';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage({}, undef) } qr/\Qno message id sent\E/, '__hwnd::SendMessage({}) missing message id';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage({}, 0, []) } qr/\Qwparam must be a scalar\E/, '__hwnd::SendMessage({},0,[]) invalid wparam';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage({}, 0, 0, []) } qr/\Qlparam must be a scalar\E/, '__hwnd::SendMessage({},0,0,[]) invalid lparam';
}

# SendMessage_get32u
{
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_get32u(undef) } qr/\Qno object sent\E/, '__hwnd::SendMessage_get32u(undef): missing object';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_get32u({}, undef) } qr/\Qno message id sent\E/, '__hwnd::SendMessage_get32u({}) missing message id';
}

# SendMessage_getUcs2le
{
    my $retval;
    throws_ok { $retval = Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getUcs2le(undef) } qr/\Qno object sent\E/, '__hwnd::SendMessage_getUcs2le(undef): missing object';
    $retval = notepad->{_hwobj}->SendMessage_getUcs2le($NPPMSG{NPPM_GETLANGUAGEDESC}, 21 );
    like $retval, qr/^\QPerl source file\E\0*$/, '__hwnd::SendMessage_getUcs2le(): missing trim setting';
    $retval = notepad->{_hwobj}->SendMessage_getUcs2le($NPPMSG{NPPM_GETLANGUAGEDESC}, 22, {trim => 'retval', charlength => 2} );
    like $retval, qr/^\QPython file\E$/, '__hwnd::SendMessage_getUcs2le(): include charlength parameter';
}

# getRawString
{
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getRawString(undef); } qr/\Qno object sent\E/, '__hwnd::SendMessage_getRawString(undef): missing object';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getRawString({}, undef); } qr/\Qno message id sent\E/, '__hwnd::SendMessage_getRawString({}) missing message id';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getRawString({}, 0, 0); } qr/\Qunblessed reference\E/, '__hwnd::SendMessage_getRawString({},0,0) no optional args (for coverage) and fails for unblessed reference {}';
    throws_ok { Win32::Mechanize::NotepadPlusPlus::__hwnd::SendMessage_getRawString({}, 0, 0, { charlength=>0, trim=>'retval' }); } qr/\Qunblessed reference\E/, '__hwnd::SendMessage_getRawString(...,{charlength=>0}) 0 charlength and fails for unblessed reference {}';
}

done_testing;
