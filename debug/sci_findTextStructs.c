#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <stdlib.h>

#include "../src/Scintilla.h"

int main(int argc, char**argv)
{
    LRESULT ret, msg, w, l;
    HWND hWnd;
    int i;
    for(i = 0; i<argc; i++) {
        fprintf(stderr, "`%s` ", argv[i]);
    }
    fprintf(stderr, "\n");

    if(argc<2) {
        fprintf(stderr, "usage: %s _hWnd_\n", argv[0]);
        fprintf(stderr, "perl -Ilib -MWin32::Mechanize::NotepadPlusPlus=:main -le \"print $_, qq( => ), notepad()->{$_} for qw/_hwnd _exe _pid/\"\n");
        return 255;
    }

    hWnd = (HWND)strtoull( argv[1], (char**)NULL, 0 );

    ret = SendMessage((HWND)hWnd, (UINT)(msg=SCI_GETTEXT), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    {
        char *str;
        str = (char*) calloc(1+ret, 16*sizeof(char));
        fprintf(stderr, "calloc ok: %p\n", str);
        w = ret>16 ? 16 : 0;
        ret = SendMessage((HWND)hWnd, (UINT)(msg=SCI_GETTEXT), (WPARAM)(w), (LPARAM)(l=0)); // l=str    // DUH! crashing because I didn't VirtualAlloc...
        fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
        fprintf(stderr, "got \"%s\"\n\t", !str ? "<NULL>" : !*str ? "<EMPTY>" : str);
        for(i = 0; i<(int)w; i++) {
            fprintf(stderr, "%02x ", str[i]);
        }
        fprintf(stderr, "\n");
    }

    return(0);
}