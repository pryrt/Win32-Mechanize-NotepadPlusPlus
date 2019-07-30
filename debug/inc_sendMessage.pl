#!/usr/bin/perl
# try with Inline::C, to compare the results
use warnings;
use strict;

use Inline     qw/INFO FORCE NOCLEAN/;

use Inline C => Config =>
    #BUILD_NOISY => 1,
    ;

use Inline 'C';
sizes();

use lib "../lib";
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__npp_msgs;
my $hwnd = notepad()->{_hwnd};
printf "hwnd = 0x%016x\n", $hwnd;
printf "msg = 0x%016x\n", $nppm{NPPM_GETCURRENTBUFFERID};
my $bufid1 = notepad()->{_hwobj}->SendMessage($nppm{NPPM_GETCURRENTBUFFERID}, 0, 0);
printf "bufid1 = 0x%016x\n", $bufid1;
my $bufid2 = icSendMessage($hwnd , $nppm{NPPM_GETCURRENTBUFFERID}, 0, 0);
printf "bufid2 = 0x%016x\n", $bufid2;

# so far, what I've found is that even the C version is returning a 32bit value from the SendMessage, despite it being a 64bit
#   and it appears to be the internal SendMessage, not the external one.
# TODO = try to implement the C version of the http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html ex2.3 and following

__DATA__
__C__
#define szo(v) printf("sizeof(%s) = %d\n", #v, sizeof(v)*8)
void sizes() {
    szo(LRESULT);
    szo(WPARAM);
    szo(LPARAM);
    szo(HWND);
    szo(UINT);
    szo(long);
    szo(long long);
    szo(unsigned);
    szo(short);
    szo(float);
    szo(double);
    szo(void*);
}

int icSendMessage(long hwnd, long msg, long wParam, long lParam) {
    long long ret;
    ret = SendMessage((HWND)hwnd, (UINT)msg, (WPARAM)wParam, (LPARAM)lParam);
    fprintf(stderr, "icSendMessage: long long return = %016lx\n", ret);
    return (int)ret;
}