#!c:\usr\local\apps\berrybrew\perls\system\perl\perl -l
# used http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html#id5446446 as a starting point
use Win32::GuiTest qw'WaitWindowLike SendMessage AllocateVirtualBuffer WriteToVirtualBuffer ReadFromVirtualBuffer FreeVirtualBuffer';
use Encode;
use strict;
use Config;
use warnings;
use constant {
    NPPM_GETFULLPATHFROMBUFFERID => 1024+1000+58,
    NPPM_GETCURRENTBUFFERID => 1024+1000+60,
    NPPM_GETNBOPENFILES => 1024+1000+7,
    NPPM_GETOPENFILENAMES => 1024+1000+8,
};

my $hwnd;
BEGIN {
    $hwnd = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5 ) # wait up to 5sec
        or die "could not open the Notepad++ application; try running a new instance of notepad++.exe";  # uncoverable branch true
}

# need a bufferID for my SSCCE
print "bufid  = ", my $bufid = SendMessage( $hwnd, NPPM_GETCURRENTBUFFERID, 0, 0 );

# I can read a single string in the LPARAM
print "getstr = ", my $getstr = SendMessage_getUcs2le( $hwnd, NPPM_GETFULLPATHFROMBUFFERID, $bufid, 0 );

# but having difficulty with getting TCHAR** back from WPARAM
my @fnames = getFileNames( $hwnd );

sub SendMessage_getUcs2le {
    my $hwnd = shift; die "no hwnd sent" unless defined $hwnd;
    my $msgid = shift; die "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;

    my $buf_uc2le = Win32::GuiTest::AllocateVirtualBuffer( $hwnd, 1024 );   # 1024 byte string maximum
    Win32::GuiTest::WriteToVirtualBuffer( $buf_uc2le, "\0"x1024 );                # pre-populate
    my $rslt = SendMessage( $hwnd, $msgid, $wparam, $buf_uc2le->{ptr});
    my $rbuf = Win32::GuiTest::ReadFromVirtualBuffer( $buf_uc2le, 1024 );
    Win32::GuiTest::FreeVirtualBuffer( $buf_uc2le );
    return substr Encode::decode('ucs2-le', $rbuf), 0, $rslt;   # return the valid characters from the raw string
}

sub getFileNames {

    my $hwnd = shift;  die "no hwnd sent" unless defined $hwnd;

    print "nOpenFiles = ", my $nFiles = SendMessage( $hwnd, NPPM_GETNBOPENFILES , 0 , 0 );

    # allocate remote memory for the n pointers, 8 bytes per pointer
    my $tcharpp = AllocateVirtualBuffer( $hwnd, $nFiles*$Config{ptrsize} ); #allocate 8-bytes per file for the pointer to each buffer

    # allocate remote memory for the strings, each 1024 bytes long
    my @strBufs = map { AllocateVirtualBuffer( $hwnd, 1024 ) } 1 .. $nFiles;

    # grab the pointers
    my @strPtrs = map { $_->{ptr} } @strBufs;

    # pack them into a string for writing into the virtual buffer
    my $pk = $Config{ptrsize}==8 ? 'Q*' : 'L*';     # L is 32bit, so maybe I need to pick L or Q depending on ptrsize?
    my $tcharpp_val = pack $pk, @strPtrs;

    # load the pointers into the tcharpp
    WriteToVirtualBuffer( $tcharpp , $tcharpp_val );

    # now send the message...
    # https://web.archive.org/web/20190325050754/http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
    #   wParam = [out] TCHAR ** fileNames
    #   lParam = [in] int nbFile
    print "SendMessage status: ", my $ret = SendMessage( $hwnd, NPPM_GETOPENFILENAMES, $tcharpp->{ptr}, $nFiles);

use Data::Dumper; $Data::Dumper::Useqq++;
    for my $text_buf ( @strBufs ) {
        my $rd = ReadFromVirtualBuffer( $text_buf, 1024 );
        printf "read '%s'\n", Dumper Encode::decode('ucs2-le', $rd);
        # they all turn out as "\0" x 1024
    }

    FreeVirtualBuffer($_) for @strBufs, $tcharpp;
}