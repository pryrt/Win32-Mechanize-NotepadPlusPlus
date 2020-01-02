#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <stdlib.h>

#include "../src/Scintilla.h"

int main(int argc, char**argv)
{
    LRESULT ret, msg, w, l;
    HWND npp_hWnd, sci_hWnd;
    int i;
    for(i = 0; i<argc; i++) {
        fprintf(stderr, "`%s` ", argv[i]);
    }
    fprintf(stderr, "\n");

    if(argc<3) {
        fprintf(stderr, "usage: %s _npp_hWnd_ _sci_hWnd_\n", argv[0]);
        fprintf(stderr, "perl -Ilib -MWin32::Mechanize::NotepadPlusPlus=:main -le \"print $_, qq( => ), notepad()->{$_} for qw/_hwnd _exe _pid/\"\n");
        return 255;
    }

    npp_hWnd = (HWND)strtoull( argv[1], (char**)NULL, 0 );
    sci_hWnd = (HWND)strtoull( argv[2], (char**)NULL, 0 );

    // now get process info
    DWORD pid = 0;
    GetWindowThreadProcessId( npp_hWnd , & pid );
    HANDLE hProcHnd = OpenProcess( PROCESS_ALL_ACCESS, FALSE, pid );
    fprintf(stderr, "NPP pid = %ld, hProcHnd = 0x%016I64x\n", pid, (LRESULT)hProcHnd);


    ret = SendMessage((HWND)sci_hWnd, (UINT)(msg=SCI_GETTEXT), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)sci_hWnd, msg, w, l, ret);
    {
        w = ret + 1;

        LPVOID* virtual_buffer = VirtualAllocEx( hProcHnd, NULL, w*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
        SIZE_T copied = 0;
        char* realText = (char*) calloc(w, sizeof(char));


        ret = SendMessage((HWND)sci_hWnd, (UINT)(msg=SCI_GETTEXT), (WPARAM)(w), (LPARAM)(l=(LRESULT)virtual_buffer));
        fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)sci_hWnd, msg, w, l, ret);
        if(ret) {
            ReadProcessMemory( hProcHnd, virtual_buffer, (LPVOID)realText, w, &copied);
            fprintf(stderr, "ReadProcessMemory()=\n>>>>>>\n%s\n<<<<<< [%d]\n", realText, copied);
        }
        VirtualFreeEx( hProcHnd, virtual_buffer, 0, MEM_RELEASE);
    }

    return(0);
}