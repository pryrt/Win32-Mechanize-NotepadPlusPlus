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
#   -> listviewctrl(), need to pass it an hwnd from WinSpy
#   Why did I think it would help?  I'm looking for 64bits from SendMessage output, not from a structure internally.
#       Might need to start somewhere like http://www.winprog.org/tutorial/start.html , and write a windows app from scratch,
#       and see if I can use it as a dummy message-receiver, to return whatever I want...

listviewctrl(0x00040F3C);   # doesn't seem to work... but WinSpy doesn't claim that the file pane from the File|Open window _is_ a listview;
                            # it may be something that has changed as windows evolved.

__DATA__
__C__
#define szo(v) printf("sizeof(%s) = %d\n", #v, sizeof(v)*8)
void sizes() {
    szo(LRESULT);
    szo(WPARAM);
    szo(LPARAM);
    szo(HWND);
    szo(UINT);
    szo(DWORD);
    szo(SIZE_T);
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

    #include <windows.h>
    #include <commctrl.h>
    #include <stdio.h>

long listviewctrl(long lhwnd)
{
    HWND hWnd = (HWND) lhwnd;

    LVITEM lvitem;
    char buffer[ 200 ];

    DWORD pid = 0;
    GetWindowThreadProcessId( hWnd, &pid );
    HANDLE hProcHnd = OpenProcess( PROCESS_ALL_ACCESS, FALSE, pid );
    LPVOID pLVI = VirtualAllocEx( hProcHnd, NULL, sizeof( LVITEM ),
                   MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
    LPVOID pBuffer = VirtualAllocEx( hProcHnd, NULL, 200,
                   MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);

    lvitem.mask = 0;
    lvitem.iItem = 0;
    lvitem.iSubItem = 0;
    lvitem.state = 0;
    lvitem.stateMask = 0;
    lvitem.pszText = ( char *)pBuffer;
    lvitem.cchTextMax = 200;
    lvitem.iImage = 0;
    lvitem.lParam = 0;
    lvitem.iIndent = 0;
    SIZE_T copied = 0;
    szo(LVITEM);
    WriteProcessMemory( hProcHnd, pLVI, &lvitem, sizeof( LVITEM ), &copied );
    SendMessage( hWnd, LVM_GETITEMTEXT, (WPARAM)0, (LPARAM)pLVI );
    ReadProcessMemory( hProcHnd, pBuffer, (LPVOID)buffer, 200, &copied );
    VirtualFreeEx( hProcHnd, pBuffer, 0, MEM_RELEASE );
    VirtualFreeEx( hProcHnd, pLVI, 0, MEM_RELEASE );
    printf( "The item is \"%s\"\n", buffer );
    return 0;
}
