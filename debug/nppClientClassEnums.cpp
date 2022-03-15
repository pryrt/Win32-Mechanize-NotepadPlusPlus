#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <stdlib.h>
#include "../src/Notepad_plus_msgs.h"


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

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_all = ret;

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=1));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_one = ret;

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_GETNBOPENFILES), (WPARAM)(w=0), (LPARAM)(l=2));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
    int n_two = ret;

    fprintf(stderr, "all=%d, one=%d, two=%d\n", n_all, n_one, n_two);

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_GETCURRENTMACROSTATUS), (WPARAM)(w=0), (LPARAM)(l=0));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
	MacroStatus mstat;
	mstat = (MacroStatus) ret;
	fprintf(stderr, "\tMacroStatus = %d\n", mstat);

	char x[] = "C++";
	fprintf(stderr, "x address = 0x%p => \"%s\"\n", x, x);

	ExternalLexerAutoIndentMode indentMode = ExternalLexerAutoIndentMode::Custom;
	fprintf(stderr, "try to write indentMode = %d for \"%s\"\n", indentMode, x);

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_SETEXTERNALLEXERAUTOINDENTMODE), (WPARAM)(w=(LRESULT)x), (LPARAM)(l=(LRESULT)(&indentMode)));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);

    ret = SendMessage((HWND)hWnd, (UINT)(msg=NPPM_GETEXTERNALLEXERAUTOINDENTMODE), (WPARAM)(w=(LRESULT)x), (LPARAM)(l=(LRESULT)(indentMode)));
    fprintf(stderr, "run SendMessage(0x%016I64x,0x%016I64x,0x%016I64x,0x%016I64x) = %016I64x\n", (LRESULT)hWnd, msg, w, l, ret);
	fprintf(stderr, "read indentMode = %d\n", indentMode);

    return 0;

}

