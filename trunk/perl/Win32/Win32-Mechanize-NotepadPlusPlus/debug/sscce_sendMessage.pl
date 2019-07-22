#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Win32::API;
use Win32::GuiTest ':FUNC';
use Test::More;

if(0) {
    # first, make sure calc.exe is runninng.
    # see example 2.3 from http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html
    my $msg_id = 0xd;   # WM_GETTEXT
    #my $hwnd = 0x204ba;# this is the edit control hwnd... to be replaced by:
        my $hwnd = WaitWindowLike( 0, '^Calc', undef, undef, undef, 5)
            or die "could not find calculator";
    my $buffer = " " x 100;                 # pre-allocate space
    my $buf_ptr = pack( 'P', $buffer );     # pack/unpack pair required:    creates a pointer to $buffer
    my $ptr = unpack( 'L!', $buf_ptr );     # creates a native-unsigned-32-bit from the pointer
    SendMessage( $hwnd, $msg_id, 100, $ptr );
    print "The result from Calculator is $buffer\n";    # this is actually the title... 0x204ba must've been the result window id... but new calc doesn't work that way

    $msg_id = 0x0e; # WM_GETTEXTLENGTH
    my $l = SendMessage( $hwnd, $msg_id, 0, 0);
    print "the length of the same is $l\n";
    exit;
}


# TO USER: make sure Notepad++ is already running before running this script
my $npp_hwnd = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5)
    or die "could not find an open Notepad++ application";
ok $npp_hwnd, 'Notepad++ hwnd = ' . ($npp_hwnd//'<undef>');

my $pid = myGetPidFromHwnd($npp_hwnd);
ok $pid, 'Notepad++ pid = ' . ($pid//'<undef>');

my $sci_hwnd = myGetScintillaHwnd($npp_hwnd);
ok $sci_hwnd, 'Scintilla Component hwnd = ' . ($sci_hwnd//'<undef>');


# http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
use constant WM_GETTEXT => 0x0d;                    # from example 2.3, above
use constant WM_USER => 0x400;                      # https://msdn.microsoft.com/en-us/library/windows/desktop/ms644931(v=vs.85).aspx
use constant NPPMSG => WM_USER + 1000;
use constant NPPM_SAVECURRENTFILE => NPPMSG + 38;
use constant NPPM_GETNBOPENFILES => NPPMSG + 7;         # args(0, nbType)
use constant NPPM_GETCURRENTLANGTYPE => NPPMSG + 5;     # args(0, out int *)
use constant NPPM_GETCURRENTVIEW => NPPMSG + 88;        # args(0,0)

# scintilla messages
use constant SCI_GOTOLINE => 2024;


# scintilla message works:
#   will move scintilla pointer to this SendMessage line
my $rslt = SendMessage( $sci_hwnd , SCI_GOTOLINE, __LINE__-1 , 0);
ok defined $rslt, 'Scintilla message: cursor should be on previous line; rslt = ' . ($rslt//'<undef>');

# notepad++ message with zero arguments: save current file (will be more obvious if you have an unsaved change)
$rslt = SendMessage( $npp_hwnd , NPPM_SAVECURRENTFILE, 0 , 0);
ok defined $rslt, 'Notepad++ 0-arg message: file should be saved; rslt = ' . ($rslt//'<undef>');
    note "\tshould be 1 if file was successfully saved, 0 if file was not changed and thus didn't need to change";

# NPPM_GETNBOPENFILES(0, nbType): 0:ALL, 1:PRIMARY, 2:SECONDARY
$rslt=SendMessage( $npp_hwnd , NPPM_GETNBOPENFILES, 0 , 0);
ok defined $rslt, 'NPPM_GETNBOPENFILES(0:ALL): ' . ($rslt//'<undef>');
$rslt=SendMessage( $npp_hwnd , NPPM_GETNBOPENFILES, 0 , 1);
ok defined $rslt, 'NPPM_GETNBOPENFILES(1:PRIMARY) = first editor view: ' . ($rslt//'<undef>');
$rslt=SendMessage( $npp_hwnd , NPPM_GETNBOPENFILES, 0 , 2);
ok defined $rslt, 'NPPM_GETNBOPENFILES(2:SECONDARY) = second editor view: ' . ($rslt//'<undef>');

# Try NPPM_GETCURRENTVIEW, which should return 0 or 1 (as SendMessage return, rather than as parameter)
#   This is a potential alternative to NPPM_GETCURRENTSCINTILLA which should tell me whether editor1 or editor2 is active...
#   (good idea, if I cannot get it working to grab a LPARAM out int*)
$rslt = SendMessage( $npp_hwnd, NPPM_GETCURRENTVIEW, 0, 0);
ok defined $rslt, 'NPPM_GETCURRENTVIEW(): ' . ($rslt//'<undef>');
like $rslt, qr/^[01]$/, 'NPPM_GETCURRENTVIEW() must be 0 or 1: ' . ($rslt//'<undef>');


# TODO = need to prove that I don't know how to make SendMessage get a lparam value back
#   Maybe Win32::GuiTest::AllocateVirtualBuffer, and similar...
#   see if the test-suite for those that function how to use it...
# TODO = need to implement the Inline::C versions of sendtest4() and trying to allocate the storage location in C
$rslt = eval {
    my $maxlen = 256;
    my $buffer = "\0"x$maxlen;   # pre-allocate
    my $bptr = pack("P", $buffer);  # find the pointer to the pre-allocated buffer
    my $ptr = unpack("L!", $bptr);  # convert to native 32-bit unsigned long
    my $r = SendMessage( $npp_hwnd , WM_GETTEXT, $maxlen, $ptr);
    return [$r, $buffer, length($buffer)]
} or do { warn "eval -> $@!"};
# diag explain $rslt;
cmp_ok $rslt->[0], '>=', 9, 'SendMessage(WM_GETTEXT) should return the number of characters: ' . ($rslt->[0]//'<undef>');
like $rslt->[1], qr/\QNotepad++\E/, 'SendMessage(WM_GETTEXT) include "Notepad++": "' . ($rslt->[1]//'<undef>') . '"';
# 2019-Jul-22: so, thanks to that example, determined that if I want to read back text in Perl,
#   I need to allocate a buffer with MAX characters, then unpack 'L!' => pack 'P' => $buffer

# Based on that, let's see fi I can get an integer return from NPPM_GETCURRENTLANGTYPE (0, out integer ptr)
if(0) {
    # crashes Notepad++!
  eval {
    my $read_int = 0;   # this is an integer, I think
    my $ptr = unpack 'L!', pack 'P', $read_int;     # get a c-style pointer to the
    my $rslt = SendMessage( $npp_hwnd, NPPM_GETCURRENTLANGTYPE, 0, 0);
    ok defined $rslt, 'NPPM_GETCURRENTLANGTYPE(): ' . ($rslt//'<undef>');
    ok $ptr, 'NPPM_GETCURRENTLANGTYPE() ptr: ' . ($ptr//'<undef>');
    ok $read_int, 'NPPM_GETCURRENTLANGTYPE) read_int: ' . ($read_int//'<undef>');
    1;
  } or do { die "eval -> >>$@<<!" };
  # so, the good news is I know how to grab a string; the strange news is, I apparently don't know how to read an integer...

  # DEBUG notes: reading farther in the piotrkaluski examples:
  #   * ahh, for WM_GETTEXTLENGTH and any other message below WM_USER=1024,
  #     windows handles the "marshalling" (transferring of data across process boundaries).
  #     But for >=WM_USER, we're in charge of that.
}

# try again, with the virtual buffer methods
if(1) {
  eval {
    my $buf32u = AllocateVirtualBuffer( $npp_hwnd, 32/8 );
        diag "explain buf32u after allocate: ", explain $buf32u;
    WriteToVirtualBuffer( $buf32u , pack("L!",-1));             # pre-populate with -1, to easily recognize if the later Read doesn't work
    my $rd = ReadFromVirtualBuffer( $buf32u , 32/8 );
        diag "explain buf32u after read: ", explain $buf32u;
        diag "unpack rd: ", unpack('L!', $rd);
    my $rslt = SendMessage( $npp_hwnd, NPPM_GETCURRENTLANGTYPE, 0, $buf32u->{ptr});
    ok defined $rslt, 'NPPM_GETCURRENTLANGTYPE(): ' . ($rslt//'<undef>');
    $rd = ReadFromVirtualBuffer( $buf32u , 32/8 );
        diag "explain buf32u after SendMessage: ", explain $buf32u;
        diag "unpack rd: ", my $ival = unpack('L!', $rd);
    ok defined $ival, 'NPPM_GETCURRENTLANGTYPE() i val: ' . ($ival//'<undef>');
    FreeVirtualBuffer( $buf32u );
    # eureka!  i am able to read back the value 21
    1;
  } or do { die "eval -> >>$@<<!" };
}

done_testing();

BEGIN {
    Win32::API::->Import("user32","DWORD GetWindowThreadProcessId( HWND hWnd, LPDWORD lpdwProcessId)") or die "GetWindowThreadProcessId: $^E";
}

sub myGetPidFromHwnd
{
    my $hwnd = shift;
    my $pidStruct = pack("L", 0);
    my $gwtpi = GetWindowThreadProcessId($hwnd, $pidStruct);
    my $extractPid = unpack("L" => $pidStruct);
    # warn sprintf "%-15.15s %-39.39s %-59.59s %-15.15s\n",
    #             "h:$hwnd",
    #             'c:'.Win32::GuiTest::GetClassName($hwnd),
    #             't:'.Win32::GuiTest::GetWindowText($hwnd),
    #             'extractPid:'.$extractPid,
    #         ;
    return $extractPid;
}

sub myGetScintillaHwnd
{
    my $npp_hwnd = shift;
    my $sci_hwnd = undef;
    foreach my $hwnd ( FindWindowLike($npp_hwnd, undef, '^Scintilla$') ) {
        # warn sprintf "%-15.15s %-15.15s %-39.39s %-59.59s\n",
        #         "SCINTILLA:",
        #         "h:$hwnd",
        #         'c:'.Win32::GuiTest::GetClassName($hwnd),
        #         't:"'.Win32::GuiTest::GetWindowText($hwnd).'"#'.length(Win32::GuiTest::GetWindowText($hwnd)),
        #     ;
        # warn "\t\t\tVisible => ", IsWindowVisible($hwnd) ? 'y' : 'n', "\n";
        # warn "\t\t\tEnabled => ", IsWindowEnabled($hwnd) ? 'y' : 'n', "\n";
        local $" = ",";
        my @rect = GetWindowRect($hwnd);
        # warn "\t\t\tWindowRect => (@rect)\n";
        $sci_hwnd = $hwnd if IsWindowVisible($hwnd) && !defined $sci_hwnd;
        last if defined $sci_hwnd;
    }
    return $sci_hwnd;
}
