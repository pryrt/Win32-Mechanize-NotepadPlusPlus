#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "INLINE.h"

#define DLGTITLE  L"Win32::Mechanize::NotepadPlusPlus::Prompt Title"
#define DLGFONT   L"MS Sans Serif"
#define DLGOK     L"&OK"
#define DLGCANCEL L"&Cancel"
#define DLGLBLTXT L"Label Default"
#define DLGTXTBOX L"Textbox Default"
#define NUMCHARS(aa) (sizeof(aa)/sizeof((aa)[0]))
#define IDC_LABEL 99
#define IDC_TEXTBOX 98
#define MY_WS_TXTBOX_MULTILINE WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_VSCROLL | ES_AUTOVSCROLL | ES_LEFT | ES_MULTILINE | ES_WANTRETURN
#define MY_WS_TXTBOX_SINGLELINE WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | ES_LEFT

INT_PTR CALLBACK Prompt_DlgProc (
    HWND   hwnd,
    UINT   uMsg,
    WPARAM wParam,
    LPARAM lParam);
LRESULT DoPromptDialog(unsigned char isDlgMultiLine, HWND hwndApp, LPVOID pvData);
void onInitDlg(HWND hwnd);
void onCloseDlg(HWND hwnd, bool is_ok);

#pragma pack(push, 4)

static struct _st_dlg_prompt { // dltt

    DWORD  style;
    DWORD  dwExtendedStyle;
    WORD   ccontrols;
    short  x;
    short  y;
    short  cx;
    short  cy;
    WORD   menu;         // name or ordinal of a menu resource
    WORD   windowClass;  // name or ordinal of a window class
    WCHAR  wszTitle[NUMCHARS(DLGTITLE)]; // title string of the dialog box
    short  pointsize;       // only if DS_SETFONT flag is set
    WCHAR  wszFont[NUMCHARS(DLGFONT)];   // typeface name, if DS_SETFONT is set

    // control info
    // EDIT TEXTBOX: before OK/CANCEL, to control tabstop order
    struct {
       DWORD  style;
       DWORD  exStyle;
       short  x;
       short  y;
       short  cx;
       short  cy;
       WORD   id;
       WORD   sysClass;       // 0xFFFF identifies a system window class
       WORD   idClass;        // ordinal of a system window class
       WCHAR  wszTitle[NUMCHARS(DLGTXTBOX)];    // title string or ordinal of a resource
       WORD   cbCreationData; // bytes of following creation data
    } editstruct;
    // OK
    struct {
       DWORD  style;
       DWORD  exStyle;
       short  x;
       short  y;
       short  cx;
       short  cy;
       WORD   id;
       WORD   sysClass;       // 0xFFFF identifies a system window class
       WORD   idClass;        // ordinal of a system window class
       WCHAR  wszTitle[NUMCHARS(DLGOK)];
       WORD   cbCreationData; // bytes of following creation data
//       WORD   wAlign;         // align next control to DWORD boundry.
    } okstruct;

    // CANCEL
    struct {
       DWORD  style;
       DWORD  exStyle;
       short  x;
       short  y;
       short  cx;
       short  cy;
       WORD   id;
       WORD   sysClass;       // 0xFFFF identifies a system window class
       WORD   idClass;        // ordinal of a system window class
       WCHAR  wszTitle[NUMCHARS(DLGCANCEL)];
       WORD   cbCreationData; // bytes of following creation data
    } cancel;

    // LABEL
    struct {
       DWORD  style;
       DWORD  exStyle;
       short  x;
       short  y;
       short  cx;
       short  cy;
       WORD   id;
       WORD   sysClass;       // 0xFFFF identifies a system window class
       WORD   idClass;        // ordinal of a system window class
       WCHAR  wszTitle[NUMCHARS(DLGLBLTXT)];    // title string or ordinal of a resource
       WORD   cbCreationData; // bytes of following creation data
    } labelstruct;

} g_PromptTemplate = {

    WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU  // style  0x94c800c4
    | DS_MODALFRAME | DS_3DLOOK
    | DS_SETFONT,
    0x0,        // exStyle;
    4,          // ccontrols
    0, 0, 300, 180,
    0,                       // menu: none
    0,                       // window class: none
    DLGTITLE,                // Window caption
    8,                       // font pointsize
    DLGFONT,

    {
      MY_WS_TXTBOX_MULTILINE,
      WS_EX_NOPARENTNOTIFY, // 0x4
      6,50,288,100,
      IDC_TEXTBOX,
      0xFFFF, 0x0081, // edit
      DLGTXTBOX, 0,
    },

    {
      WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_GROUP | BS_DEFPUSHBUTTON,   // 0x50030001
      WS_EX_NOPARENTNOTIFY, // 0x4
      190,160,50,14,
      IDOK,
      0xFFFF, 0x0080, // button
      DLGOK, 0,
    },

    {
      WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,    // 0x50010000
      WS_EX_NOPARENTNOTIFY, // 0x4
      244,160,50,14,
      IDCANCEL,
      0xFFFF, 0x0080, // button
      DLGCANCEL, 0,
    },

    {
      WS_CHILD | WS_VISIBLE | WS_GROUP | SS_LEFT,    // 0x50020000
      WS_EX_NOPARENTNOTIFY, // 0x4
      6,6,288,26,
      IDC_LABEL,
      0xFFFF, 0x0082, // static
      DLGLBLTXT, 0,
    },
};

// https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-dlgitemtemplate =>
//  => shows the 0x0080 = BUTTON, 0x0081 = EDIT (textbox?), 0x0082 = STATIC (label, including bitmap),
//      0x0083 = LIST BOX, 0x0084 = SCROLL BAR, 0x0085 = COMBOBOX

#pragma pack(pop)

INT_PTR CALLBACK Prompt_DlgProc (
    HWND   hwnd,
    UINT   uMsg,
    WPARAM wParam,
    LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_INITDIALOG:
        {
            onInitDlg(hwnd);
        }
        break;

    case WM_COMMAND:
        {
            UINT wId = LOWORD(wParam);
            onCloseDlg(hwnd, wId==IDOK || wId==IDC_TEXTBOX);
            if (wId == IDOK || wId == IDCANCEL)
            {
                EndDialog (hwnd, wId);
            }
        }
        break;

    case WM_CLOSE:
        {
            EndDialog(hwnd, IDCANCEL);
        }
        break;
    }

    return FALSE;
}

LRESULT DoPromptDialog(unsigned char isDlgMultiLine, HWND hwndApp, LPVOID pvData)
{
   HINSTANCE hinst = hwndApp ? (HINSTANCE)(LONG_PTR)GetWindowLongPtr(hwndApp, GWLP_HINSTANCE)
                             : (HINSTANCE)GetModuleHandle(NULL);

   struct _st_dlg_prompt myTemplate = g_PromptTemplate;
   if(!isDlgMultiLine) {
       int shrinkLabel = 13;
       int shrinkExtra = 18;    // the textbox was 18 lower than it needed to be, as well
       int shrinkTextbox = 88;
       myTemplate.cy -= shrinkLabel + shrinkTextbox + shrinkExtra;
       myTemplate.labelstruct.cy -= shrinkLabel;
       myTemplate.editstruct.y -= shrinkLabel + shrinkExtra;
       myTemplate.editstruct.cy -= shrinkTextbox;
       myTemplate.editstruct.style = MY_WS_TXTBOX_SINGLELINE;
       myTemplate.okstruct.y -= shrinkTextbox + shrinkExtra + shrinkLabel;
       myTemplate.cancel.y -= shrinkTextbox + shrinkExtra + shrinkLabel;
   }

   return DialogBoxIndirectParamW (hinst, (LPCDLGTEMPLATEW)&myTemplate, hwndApp, Prompt_DlgProc, (LPARAM)pvData);
}

char* gs_dlgPrompt;
char* gs_dlgTitle;
char* gs_dlgDefault;
char* gs_dlgRetval;

void onInitDlg(HWND hwnd)
{
    SetWindowTextA(hwnd, gs_dlgTitle);
    SetDlgItemTextA(hwnd, IDC_LABEL, gs_dlgPrompt);
    SetDlgItemTextA(hwnd, IDC_TEXTBOX, gs_dlgDefault);
}

void onCloseDlg(HWND hwnd, bool is_ok)
{
    int iChars;
    if(gs_dlgRetval) { free(gs_dlgRetval); }
    if(is_ok) {
        iChars = GetWindowTextLength( GetDlgItem(hwnd, IDC_TEXTBOX) );
        gs_dlgRetval = (char*) calloc(iChars+1, sizeof(char));
        GetDlgItemText(hwnd, IDC_TEXTBOX, gs_dlgRetval, iChars+1);
    } else {
        gs_dlgRetval = (char*) calloc(1, sizeof(char));
        gs_dlgRetval[0] = '\0';
    }
}

// Helper to convert Perl SV/IV back to a C HWND
HWND sv_to_hwnd(SV* sv) {
    #if defined(USE_64_BIT_ALL) || defined(_WIN64)
        return (HWND)(INT_PTR)SvIV(sv);
    #else
        return (HWND)(long)SvIV(sv);
    #endif
}

// https://perldoc.perl.org/perlcall#EXAMPLES   -- this is the section where I figured out how to return a list,
// specifically, in https://perldoc.perl.org/perlcall#Returning-a-List-of-Values
//      actually, no it's not; I don't see the Inline_Stack in the perlapi or perlcall or perlguts; where did I get those?
//      using Google Advanced search on perldoc => https://metacpan.org/pod/Inline::C#THE-INLINE-STACK-MACROS
//          so they are Inline::C macros!
//      https://metacpan.org/dist/Inline-C/view/lib/Inline/C/Cookbook.pod#Multiple-Return-Values => this is probably really
//          where I got the sequence
// The `newSV*()` are in https://perldoc.perl.org/perlapi
//

void _c_prompt(SV* hwnd_sv, char* str_prompt, char* str_title, char* str_default, unsigned char isDlgMultiLine)
{
    HWND hwnd = sv_to_hwnd(hwnd_sv);

    // printf("prompt='%s', title='%s', default='%s'\n", str_prompt, str_title, str_default);
    gs_dlgPrompt = str_prompt;
    gs_dlgTitle = str_title;
    gs_dlgDefault = str_default;
    LRESULT r = DoPromptDialog(isDlgMultiLine, (HWND)hwnd, NULL);
    // printf("result = %d, string\n%s\n", r, gs_dlgRetval);
    // fflush(stdout);
    Inline_Stack_Vars;
    Inline_Stack_Reset;
    // if good result, then push the gs_dlgRetval, else push the undef as retval
    if(r==1 && gs_dlgRetval) { // was: // && gs_dlgRetval[0]) {
        Inline_Stack_Push(newSVpvf("%s", gs_dlgRetval));
    } else {
        Inline_Stack_Push(&PL_sv_undef);
    }
    Inline_Stack_Done;
    return;
}

MODULE = Win32::Mechanize::NotepadPlusPlus::Prompt  PACKAGE = Win32::Mechanize::NotepadPlusPlus::Prompt

PROTOTYPES: DISABLE


void
_c_prompt (hwnd_sv, str_prompt, str_title, str_default, isDlgMultiLine)
	SV *	hwnd_sv
	char *	str_prompt
	char *	str_title
	char *	str_default
	unsigned char	isDlgMultiLine
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _c_prompt(hwnd_sv, str_prompt, str_title, str_default, isDlgMultiLine);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

