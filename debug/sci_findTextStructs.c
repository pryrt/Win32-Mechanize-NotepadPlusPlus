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
        fprintf(stderr, "perl -Ilib -MWin32::Mechanize::NotepadPlusPlus=:main -le \"print $_, qq( => ), notepad()->{$_} for qw/_hwnd/;print $_, qq( => ), editor1()->{$_} for qw/_hwnd/\"\n");
        return 255;
    }

    npp_hWnd = (HWND)strtoull( argv[1], (char**)NULL, 0 );
    sci_hWnd = (HWND)strtoull( argv[2], (char**)NULL, 0 );

    // now get process info
    DWORD pid = 0;
    GetWindowThreadProcessId( npp_hWnd , & pid );
    HANDLE hProcHnd = OpenProcess( PROCESS_ALL_ACCESS, FALSE, pid );
    fprintf(stderr, "NPP pid = %ld, hProcHnd = 0x%016I64x\n", pid, (LRESULT)hProcHnd);

    // try a normal virtual-buffer string grab:
    ret = SendMessage((HWND)sci_hWnd, (UINT)(msg=SCI_GETTEXT), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)sci_hWnd, msg, w, l, ret);
    {
        w = ret + 1;

        LPVOID virtual_buffer = VirtualAllocEx( hProcHnd, NULL, w*sizeof(TCHAR), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
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

    // https://github.com/bruderstein/PythonScript/blob/4c34bfb545a348f3f12c9ef5135ab201e81ed480/PythonScript/src/ScintillaWrapperGenerated.cpp#L1821-L1840
    // Sci_TextToFind = struct { Sci_CharacterRange chrg; const char*text; Sci_CharacterRange chrgText; }
    // Sci_CharacterRange = struct { long cpMin; long cpMax }
    // so need MSG( searchFlags, { {min,max}, "text", {min,max} )
    //   where the first is where to search, and the second is the result
    {
        // define and populate the structure
        struct Sci_TextToFind   ttf;
        ttf.chrg.cpMin = 0;
        ttf.chrg.cpMax = 9999;
        ttf.chrgText.cpMin = -1;
        ttf.chrgText.cpMax = -1;
        fprintf(stderr, "sizeof(ttf) = %d\n", sizeof(ttf));

        // copy regex into virtual text buffer
        char regex[] = "#include";
        SIZE_T copied = 0;
        SIZE_T lenstr = strlen(regex)+1;
        LPVOID vstr = VirtualAllocEx( hProcHnd, NULL, lenstr*sizeof(char), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
        fprintf(stderr, "vstr = %p\n", vstr);
        WriteProcessMemory( hProcHnd, vstr, regex, lenstr*sizeof(char), &copied );
        fprintf(stderr, "WriteProcessMemory(vstr, \"%s\"): %016I64d\n", regex, copied);

        // populate structure's regex from regex buffer vstr
        ttf.lpstrText = vstr;

        // dump the structure for debug
        char* rawptr = (char*)((void*)(&ttf));
        fprintf(stderr, "bytes(ttf) = 0x ");
        for(i=0; i<sizeof(ttf); i++) { fprintf(stderr, "%02x ", 0xFF & rawptr[i]); }
        fprintf(stderr, "\n");

        // allocate the virtual structure
        LPVOID vttf = VirtualAllocEx( hProcHnd, NULL, sizeof(ttf), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
        fprintf(stderr, "vttf = %p\n", vttf);

        // populate the virtual structure
        copied = 0;
        WriteProcessMemory( hProcHnd, vttf, (LPVOID)(&ttf), sizeof(ttf), &copied);
        fprintf(stderr, "WriteProcessMemory(vttf) [%d]\n", copied);

        // send the message
        ret = SendMessage( (HWND)sci_hWnd, (UINT)(msg=SCI_FINDTEXT), (WPARAM)(w=SCFIND_WHOLEWORD), (LPARAM)(l=(LRESULT)vttf));

        // maybe have to read back the virtual structure
        copied=0;
        ttf.chrg.cpMin = -3;
        ttf.chrg.cpMax = -5;
        ttf.chrgText.cpMin = -7;
        ttf.chrgText.cpMax = -11;
        ReadProcessMemory( hProcHnd, vttf, (LPVOID)(&ttf), sizeof(ttf), &copied);
        fprintf(stderr, "ReadProcessMemory(vttf) [%d]\n", copied);

        // grab the chrgText results from the structure
        fprintf(stderr, "resulting {min,max} = {%d,%d}\n", ttf.chrgText.cpMin, ttf.chrgText.cpMax );
        fprintf(stderr, "original {min,max} = {%d,%d}\n", ttf.chrg.cpMin, ttf.chrg.cpMax );

        // free memory afterward
        VirtualFreeEx( hProcHnd, vttf, 0, MEM_RELEASE);
        VirtualFreeEx( hProcHnd, vstr, 0, MEM_RELEASE);
    }

    return(0);
}

/* Example of the last few lines of debug
sizeof(ttf) = 24
vstr = 00000143B93D0000
WriteProcessMemory(vstr, "#include"): 0000000000000009
bytes(ttf) = 0x 00 00 00 00 0f 27 00 00 00 00 3d b9 43 01 00 00 ff ff ff ff ff ff ff ff
vttf = 00000143B93E0000
WriteProcessMemory(vttf) [24]
ReadProcessMemory(vttf) [24]
resulting {min,max} = {0,8}
original {min,max} = {0,9999}
*/