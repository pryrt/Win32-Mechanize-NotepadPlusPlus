#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <stdlib.h>

// using http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html as a guide, because it shows both C and Win32::GuiTest

#define NPPMSG (WM_USER + 1000)
#define NPP_GETNBOPENFILES (NPPMSG + 7)
#define NPP_GETOPENFILENAMES (NPPMSG + 8)
#define NPP_GETOPENFILENAMESPRIMARY (NPPMSG + 17)
#define NPP_GETOPENFILENAMESSECOND (NPPMSG + 18)

int main(int argc, char**argv) {
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

    // first need to verify I can do simple messages in C. Since I'll need it, grab the

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPP_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_all = ret;

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPP_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=1));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_one = ret;

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPP_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=2));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_two = ret;

    fprintf(stderr, "all=%d, one=%d, two=%d\n", n_all, n_one, n_two);

    // now get process info
    DWORD pid = 0;
    GetWindowThreadProcessId( hWnd , & pid );
    HANDLE hProcHnd = OpenProcess( PROCESS_ALL_ACCESS, FALSE, pid );
    fprintf(stderr, "pid = %ld, hProcHnd = 0x%016I64x\n", pid, (LRESULT)hProcHnd);

#if 1
    // I think this allocates virtual space for an array of LPVOID elements
    LPVOID* fileNames = calloc( n_all , sizeof(LPVOID) );
    LPVOID pVirtFileNames = VirtualAllocEx( hProcHnd, NULL, sizeof( LPVOID* ), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
    fprintf(stderr, "pVirtFileNames = %p\n", pVirtFileNames);

    SIZE_T copied = 0;
    char fileName[1025];

    // for each filename, allocate real and virtual for 1025 TCHAR
    for(int i=0; i<n_all; i++) {
        fileNames[i] = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
        snprintf(fileName, 1024, "DummyString#%d", i);

        WriteProcessMemory( hProcHnd, fileNames[i], fileName, 1025*sizeof(TCHAR), &copied );
            //fprintf(stderr, "WriteProcessMemory(fileNames[%d], \"%s\"): %016I64d\n", i, fileName, copied);

        snprintf(fileName, 1024, "This Overwrites Whatever Was There Before");
            //fprintf(stderr, "fileName cleared = \"%s\"\n", fileName);

        ReadProcessMemory( hProcHnd, fileNames[i], (LPVOID)fileName, 1025, &copied );
            //fprintf(stderr, "ReadProcessMemory(buf0): \"%s\", copied %016I64d\n", fileName, copied);
            //for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    }

    // now the local fileNames array should be populated...
    // so write that array into process memory
    WriteProcessMemory( hProcHnd, pVirtFileNames, fileNames, n_all*sizeof(LPVOID), &copied );
    fprintf(stderr, "WriteProcessMemory(fileNames): %016I64d \n", copied);

    // now that the process memory has been defined and loaded, let's try the SendMessage...
    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPP_GETOPENFILENAMES), w=(WPARAM)pVirtFileNames, l=(LPARAM)0);
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);

    // read them back
    for(int i=0; i<n_all; i++) {
        snprintf(fileName, 1024, "DummyString#%d", i);
        ReadProcessMemory( hProcHnd, fileNames[i], (LPVOID)fileName, 1025, &copied );
        // it's not overwriting the dummy-string
    }

    // free virtual memory
    for(int i=0; i<n_all; i++) {
        VirtualFreeEx( hProcHnd, fileNames[i] , 0, MEM_RELEASE );
            fprintf(stderr, "ReadProcessMemory(fileNames[%d]): \"%s\", copied %016I64d\n", i, fileName, copied);
    }
    VirtualFreeEx( hProcHnd, pVirtFileNames , 0, MEM_RELEASE );
#else
    // I'm going to try something different... use a structure (to begin with)
    typedef struct st_tcharpp { // allow up to 10 strings
        TCHAR* buf0;
        TCHAR* buf1;
        TCHAR* buf2;
        TCHAR* buf3;
        TCHAR* buf4;
        TCHAR* buf5;
        TCHAR* buf6;
        TCHAR* buf7;
        TCHAR* buf8;
        TCHAR* buf9;
    } t_charpp;

    LPVOID pVirtFileNames = VirtualAllocEx( hProcHnd, NULL, sizeof( t_charpp ), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);

    t_charpp charp_item;
    charp_item.buf0 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf0: %016I64x\n", (LRESULT)charp_item.buf0);
    charp_item.buf1 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf1: %016I64x\n", (LRESULT)charp_item.buf1);
    charp_item.buf2 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf2: %016I64x\n", (LRESULT)charp_item.buf2);
    charp_item.buf3 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf3: %016I64x\n", (LRESULT)charp_item.buf3);
    charp_item.buf4 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf4: %016I64x\n", (LRESULT)charp_item.buf4);
    charp_item.buf5 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf5: %016I64x\n", (LRESULT)charp_item.buf5);
    charp_item.buf6 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf6: %016I64x\n", (LRESULT)charp_item.buf6);
    charp_item.buf7 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf7: %016I64x\n", (LRESULT)charp_item.buf7);
    charp_item.buf8 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf8: %016I64x\n", (LRESULT)charp_item.buf8);
    charp_item.buf9 = VirtualAllocEx( hProcHnd, NULL, 1025*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);  fprintf(stderr, "buf9: %016I64x\n", (LRESULT)charp_item.buf9);

    SIZE_T copied = 0;
    WriteProcessMemory( hProcHnd, pVirtFileNames, &charp_item, sizeof( charp_item ), &copied );
    fprintf(stderr, "WriteProcessMemory(charp_item): %016I64d (should be sizeof(charp_item)=%016I64d)\n", copied, sizeof(charp_item));

    // now that the process memory has been defined and loaded, let's try the SendMessage...
    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPP_GETOPENFILENAMES), w=(WPARAM)pVirtFileNames, l=(LPARAM)0);
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);

    // didn't crash!  try to read the buffers...
    char fileName[1025];
    ReadProcessMemory( hProcHnd, charp_item.buf0, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf0): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf1, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf1): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf2, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf2): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf3, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf3): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf4, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf4): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf5, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf5): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf6, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf6): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf7, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf7): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf8, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf8): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");
    ReadProcessMemory( hProcHnd, charp_item.buf9, (LPVOID)fileName, 1025, &copied );  fprintf(stderr, "ReadProcessMemory(buf9): \"%s\", copied %016I64d\n", fileName, copied); for(int i=0; i<1025; i++) fprintf(stderr, "%02x ", fileName[i]); fprintf(stderr, "\n");

    // nope, 1025 NULLS, just like in Perl Win32::GuiTest. :-(
    // 2019-Sep-20: one last thought before giving up and just looping on getBufferFilename: go back to an array of VirtualMemory buffers, and actually implement that.
    VirtualFreeEx( hProcHnd, charp_item.buf0 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf1 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf2 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf3 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf4 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf5 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf6 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf7 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf8 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, charp_item.buf9 , 0 , MEM_RELEASE );
    VirtualFreeEx( hProcHnd, pVirtFileNames , 0, MEM_RELEASE );
#endif
    return 0;

}

