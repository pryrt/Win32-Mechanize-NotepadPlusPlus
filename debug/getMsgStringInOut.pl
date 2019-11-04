use 5.010;
use strict;
use warnings;
use Encode qw'encode';
use lib '../lib';
use lib './lib';
use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;
use Win32::GuiTest 1.64 ();

notepad()->newFile();

local $\ = "\n";
print my $hn = notepad()->{_hwnd};
print my $e1 = editor1()->{_hwnd};
print my $e2 = editor2()->{_hwnd};
print my $he = editor()->{_hwnd};

my $send_buf = Win32::GuiTest::AllocateVirtualBuffer( $he , 1000 );
my $recv_buf = Win32::GuiTest::AllocateVirtualBuffer( $he , 1000 );
Win32::GuiTest::WriteToVirtualBuffer( $send_buf, "Hello World" );

##############
# verify I can send a message to populate the active file
##############
#editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, "Yo There!" );
#sleep(1);
my $ret = Win32::GuiTest::SendMessage( $he, $scimsg{SCI_SETTEXT}, 0, $send_buf->{ptr} );
#sleep(1);
#editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, "Go away!" );

##############
# verify I can read a string
##############
my $len = Win32::GuiTest::SendMessage( $he, $scimsg{SCI_GETTEXT}, 0, 0 ) || 1;   # get the needed length first
$ret = Win32::GuiTest::SendMessage( $he, $scimsg{SCI_GETTEXT}, $len, $recv_buf->{ptr} );
my $get = Win32::GuiTest::ReadFromVirtualBuffer( $recv_buf, $len-1);
printf "getText => '%s' [%d]\n", $get, $len;

##############
# clear the buffers
##############
Win32::GuiTest::WriteToVirtualBuffer( $send_buf, "\0"x1000 );   # clear the buffers
Win32::GuiTest::WriteToVirtualBuffer( $recv_buf, "\0"x1000 );   # clear the buffers

##############
# the actual goal:
#   to be able to implement eqivalent of python:
#       editor.encodedFromUTF8(u"START\x80")
#       'START\xc2\x80'
#   SCI_ENCODEDFROMUTF8( const char* src, char* dst ) -> length
##############
use Data::Dumper; $Data::Dumper::Useqq++;
Win32::GuiTest::WriteToVirtualBuffer( $send_buf, "START\xc2\x80" );
#$ret = Win32::GuiTest::SendMessage( $he, $scimsg{SCI_SETTEXT}, 0, $send_buf->{ptr} );sleep(1);
$ret = Win32::GuiTest::SendMessage( $he, $scimsg{SCI_ENCODEDFROMUTF8}, $send_buf->{ptr}, $recv_buf->{ptr});           # first try with NULL pointers for both
printf "ret = %d\n", $ret;
$get = Win32::GuiTest::ReadFromVirtualBuffer( $recv_buf, 100);
$get =~ s/\0*$//;
printf "converted text => '%s' [%d]\n", Dumper($get), $ret;

##############
# cleanup
##############
sleep(1);
editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, "" );
notepad()->close();
Win32::GuiTest::FreeVirtualBuffer( $_ ) for $send_buf, $recv_buf;