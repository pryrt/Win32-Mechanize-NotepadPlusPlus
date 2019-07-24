#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Win32::API;
use Win32::GuiTest ':FUNC';
use Encode;
use Data::Dumper; $Data::Dumper::Useqq++;
use Test::More;

# TO USER: make sure Notepad++ is already running before running this script
my $npp_hwnd = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5)
    or die "could not find an open Notepad++ application";
ok $npp_hwnd, 'Notepad++ hwnd = ' . ($npp_hwnd//'<undef>');

# http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
# if website is still down, use http://webcache.googleusercontent.com/search?q=cache:http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications

# first, show that I understand how to get a single string back from the LPARAM side
my $ret = GetFileName($npp_hwnd);
ok defined $ret, "GetFileName: " . ($ret//'<undef>');

# next, I want to try one that uses wparam = out TCGAR **, lparam = in int
#   NPPM_GETOPENFILENAMES
$ret = GetOpenFileNames($npp_hwnd);
ok defined $ret, sprintf "GetOpenFileNames: %s", Dumper($ret);

done_testing;

sub GetFileName {
    # derived from example 2.3 and 2.6 from http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html
    my $hwnd = shift;
    my $msgid = NPPM_GETFILENAME();
        # wParam:	[in] size_t fileNameLen
        # lParam:	[out] TCHAR * fileName
    my $wparam = 1024;

    my $buf = AllocateVirtualBuffer( $hwnd, 1024 );   # 1024 byte string maximum
    WriteToVirtualBuffer( $buf, "\0"x1024 );                # pre-populate
    my $rslt = SendMessage( $hwnd, $msgid, $wparam, $buf->{ptr});
    diag "SendMessage_getStr($hwnd, $msgid, $wparam, @{[explain $buf]} ) = $rslt";
    my $rbuf = ReadFromVirtualBuffer( $buf, 1024 );
    FreeVirtualBuffer( $buf );
    (my $str = Encode::decode('ucs2-le', $rbuf)) =~ s/\0//g;
    return  $str;  # return the valid characters from the raw string
}

sub GetOpenFileNames {
    # derived from example 2.3 and 2.6 from http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html
    my $hwnd = shift;
    my $msgid = NPPM_GETOPENFILENAMES();
        # wParam:	[out] TCHAR ** fileNames
        # lParam:	[in] int nbFile

    my $count = SendMessage( $hwnd , NPPM_GETNBOPENFILES() , 0 , ALL_OPEN_FILES() );
    ok $count, "NPPM_GETNBOPENFILES(): $count";

    # if I'm reading example 2.6 correctly, I need a virtual buffer for the structure,
    # and then $count virtual buffers for the $count open files...

    # allocate the structure buffer
    my $structure_buf = AllocateVirtualBuffer( $hwnd , 4*$count );  # 4 bytes for each of the $count 32-bit pointers...

    # allocate a string buffer for each of the $count strings
    my @allocs;
    for (1 .. $count) {
        push @allocs, AllocateVirtualBuffer( $hwnd , 1024 ); # allow 1024-byte strings
        WriteToVirtualBuffer( $allocs[-1] , "\0"x1024 );    # initialize to all NULLs
    }
    diag "[structure_buf, allocs] => ", explain [$structure_buf, @allocs];

    # pack the $count string pointers into one string
    my $pack_n = pack 'L!*', map { $_->{ptr} } @allocs;
    diag "pack_n = ", Dumper $pack_n;

    # write the pack_n (string pointer list) into the structure
    WriteToVirtualBuffer( $structure_buf, $pack_n);

    # send the message
    my $ret = SendMessage( $hwnd , $msgid , $structure_buf->{ptr} , $count);
    is $ret, $count, "SendMessage(NPPM_GETOPENFILENAMES)=$ret should match count=$count";
    diag "... so, up to this point, it's worked";

    # verify structure buf still has what was written
    my $bufstr = ReadFromVirtualBuffer( $structure_buf , 4*$count );
    is $bufstr, $pack_n, sprintf "structure_buf:\n\twas=%s\n\tnow=%s", Dumper($pack_n), Dumper($bufstr);

    # try to read the $count strings
    my $str_arr = [];
    foreach my $buf ( @allocs ) {
        my $r = ReadFromVirtualBuffer( $buf , 1024 );
        diag sprintf "read buffer(%s) = '%s'", map {Dumper $_} $buf, $r;
        $r =~ s/\0//g;
        ok $r, sprintf "read buffer(%s) = '%s'", map {Dumper $_} $buf, $r;
        push @$str_arr, $r;
    }

    # clean up virtual buffers
    FreeVirtualBuffer( $_ ) for $structure_buf, @allocs;

    # done
    return $str_arr;
}



# https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
#   simplified from h2ph run on Notepad_plus_msgs
    sub WM_USER () { 0x400; }
    sub NPPMSG () {( &WM_USER + 1000);}
#    sub NPPM_GETCURRENTSCINTILLA () {( &NPPMSG + 4);}
#    sub NPPM_GETCURRENTLANGTYPE () {( &NPPMSG + 5);}
#    sub NPPM_SETCURRENTLANGTYPE () {( &NPPMSG + 6);}
    sub NPPM_GETNBOPENFILES () {( &NPPMSG + 7);}
    sub ALL_OPEN_FILES () {0;}
    sub PRIMARY_VIEW () {1;}
    sub SECOND_VIEW () {2;}
    sub NPPM_GETOPENFILENAMES () {( &NPPMSG + 8);}
    sub RUNCOMMAND_USER () {( &WM_USER + 3000);}
    sub NPPM_GETFILENAME () {( &RUNCOMMAND_USER +  &FILE_NAME);}
    sub VAR_NOT_RECOGNIZED () {0;}
    sub FULL_CURRENT_PATH () {1;}
    sub CURRENT_DIRECTORY () {2;}
    sub FILE_NAME () {3;}
    sub NAME_PART () {4;}
    sub EXT_PART () {5;}
    sub CURRENT_WORD () {6;}
    sub NPP_DIRECTORY () {7;}
    sub CURRENT_LINE () {8;}
    sub CURRENT_COLUMN () {9;}
    sub NPP_FULL_FILE_PATH () {10;}
    sub GETFILENAMEATCURSOR () {11;}
