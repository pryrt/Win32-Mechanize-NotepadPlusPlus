#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use Win32::API;
use Win32::GuiTest ':FUNC';
use Encode;
use Test::More;

# TO USER: make sure Notepad++ is already running before running this script
my $npp_hwnd = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5)
    or die "could not find an open Notepad++ application";
ok $npp_hwnd, 'Notepad++ hwnd = ' . ($npp_hwnd//'<undef>');

# http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications

# first, show that I understand how to get a single string back from the LPARAM side
my $ret = GetFileName($npp_hwnd);
ok defined $ret, "GetFileName: $ret";

# next, I want to try one that uses wparam = out TCGAR **, lparam = in int
#   NPPM_GETOPENFILENAMES

done_testing;

sub GetFileName {
    # derived from example 2.3 and 2.6 from http://www.piotrkaluski.com/files/winguitest/docs/winguitest.html
    my $hwnd = shift;
    my $msgid = NPPM_GETFILENAME();
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

# https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
#   simplified from h2ph run on Notepad_plus_msgs
    sub WM_USER () { 0x400; }
    sub L_TEXT () { 0; }
    sub L_PHP () { 1; }
    sub L_C () { 2; }
    sub L_CPP () { 3; }
    sub L_CS () { 4; }
    sub L_OBJC () { 5; }
    sub L_JAVA () { 6; }
    sub L_RC () { 7; }
    sub L_HTML () { 8; }
    sub L_XML () { 9; }
    sub L_MAKEFILE () { 10; }
    sub L_PASCAL () { 11; }
    sub L_BATCH () { 12; }
    sub L_INI () { 13; }
    sub L_ASCII () { 14; }
    sub L_USER () { 15; }
    sub L_ASP () { 16; }
    sub L_SQL () { 17; }
    sub L_VB () { 18; }
    sub L_JS () { 19; }
    sub L_CSS () { 20; }
    sub L_PERL () { 21; }
    sub L_PYTHON () { 22; }
    sub L_LUA () { 23; }
    sub L_TEX () { 24; }
    sub L_FORTRAN () { 25; }
    sub L_BASH () { 26; }
    sub L_FLASH () { 27; }
    sub L_NSIS () { 28; }
    sub L_TCL () { 29; }
    sub L_LISP () { 30; }
    sub L_SCHEME () { 31; }
    sub L_ASM () { 32; }
    sub L_DIFF () { 33; }
    sub L_PROPS () { 34; }
    sub L_PS () { 35; }
    sub L_RUBY () { 36; }
    sub L_SMALLTALK () { 37; }
    sub L_VHDL () { 38; }
    sub L_KIX () { 39; }
    sub L_AU3 () { 40; }
    sub L_CAML () { 41; }
    sub L_ADA () { 42; }
    sub L_VERILOG () { 43; }
    sub L_MATLAB () { 44; }
    sub L_HASKELL () { 45; }
    sub L_INNO () { 46; }
    sub L_SEARCHRESULT () { 47; }
    sub L_CMAKE () { 48; }
    sub L_YAML () { 49; }
    sub L_COBOL () { 50; }
    sub L_GUI4CLI () { 51; }
    sub L_D () { 52; }
    sub L_POWERSHELL () { 53; }
    sub L_R () { 54; }
    sub L_JSP () { 55; }
    sub L_COFFEESCRIPT () { 56; }
    sub L_JSON () { 57; }
    sub L_JAVASCRIPT () { 58; }
    sub L_FORTRAN_77 () { 59; }
    sub L_BAANC () { 60; }
    sub L_SREC () { 61; }
    sub L_IHEX () { 62; }
    sub L_TEHEX () { 63; }
    sub L_SWIFT () { 64; }
    sub L_ASN1 () { 65; }
    sub L_AVS () { 66; }
    sub L_BLITZBASIC () { 67; }
    sub L_PUREBASIC () { 68; }
    sub L_FREEBASIC () { 69; }
    sub L_CSOUND () { 70; }
    sub L_ERLANG () { 71; }
    sub L_ESCRIPT () { 72; }
    sub L_FORTH () { 73; }
    sub L_LATEX () { 74; }
    sub L_MMIXAL () { 75; }
    sub L_NIMROD () { 76; }
    sub L_NNCRONTAB () { 77; }
    sub L_OSCRIPT () { 78; }
    sub L_REBOL () { 79; }
    sub L_REGISTRY () { 80; }
    sub L_RUST () { 81; }
    sub L_SPICE () { 82; }
    sub L_TXT2TAGS () { 83; }
    sub L_VISUALPROLOG () { 84; }
    sub L_EXTERNAL () { 85; }
    sub WV_UNKNOWN () { 0; }
    sub WV_WIN32S () { 1; }
    sub WV_95 () { 2; }
    sub WV_98 () { 3; }
    sub WV_ME () { 4; }
    sub WV_NT () { 5; }
    sub WV_W2K () { 6; }
    sub WV_XP () { 7; }
    sub WV_S2003 () { 8; }
    sub WV_XPX64 () { 9; }
    sub WV_VISTA () { 10; }
    sub WV_WIN7 () { 11; }
    sub WV_WIN8 () { 12; }
    sub WV_WIN81 () { 13; }
    sub WV_WIN10 () { 14; }
    sub PF_UNKNOWN () { 0; }
    sub PF_X86 () { 1; }
    sub PF_X64 () { 2; }
    sub PF_IA64 () { 3; }
    sub NPPMSG () {( &WM_USER + 1000);}
    sub NPPM_GETCURRENTSCINTILLA () {( &NPPMSG + 4);}
    sub NPPM_GETCURRENTLANGTYPE () {( &NPPMSG + 5);}
    sub NPPM_SETCURRENTLANGTYPE () {( &NPPMSG + 6);}
    sub NPPM_GETNBOPENFILES () {( &NPPMSG + 7);}
    sub ALL_OPEN_FILES () {0;}
    sub PRIMARY_VIEW () {1;}
    sub SECOND_VIEW () {2;}
    sub NPPM_GETOPENFILENAMES () {( &NPPMSG + 8);}
    sub NPPM_MODELESSDIALOG () {( &NPPMSG + 12);}
    sub MODELESSDIALOGADD () {0;}
    sub MODELESSDIALOGREMOVE () {1;}
    sub NPPM_GETNBSESSIONFILES () {( &NPPMSG + 13);}
    sub NPPM_GETSESSIONFILES () {( &NPPMSG + 14);}
    sub NPPM_SAVESESSION () {( &NPPMSG + 15);}
    sub NPPM_SAVECURRENTSESSION () {( &NPPMSG + 16);}
    sub NPPM_GETOPENFILENAMESPRIMARY () {( &NPPMSG + 17);}
    sub NPPM_GETOPENFILENAMESSECOND () {( &NPPMSG + 18);}
    sub NPPM_CREATESCINTILLAHANDLE () {( &NPPMSG + 20);}
    sub NPPM_DESTROYSCINTILLAHANDLE () {( &NPPMSG + 21);}
    sub NPPM_GETNBUSERLANG () {( &NPPMSG + 22);}
    sub NPPM_GETCURRENTDOCINDEX () {( &NPPMSG + 23);}
    sub MAIN_VIEW () {0;}
    sub SUB_VIEW () {1;}
    sub NPPM_SETSTATUSBAR () {( &NPPMSG + 24);}
    sub STATUSBAR_DOC_TYPE () {0;}
    sub STATUSBAR_DOC_SIZE () {1;}
    sub STATUSBAR_CUR_POS () {2;}
    sub STATUSBAR_EOF_FORMAT () {3;}
    sub STATUSBAR_UNICODE_TYPE () {4;}
    sub STATUSBAR_TYPING_MODE () {5;}
    sub NPPM_GETMENUHANDLE () {( &NPPMSG + 25);}
    sub NPPPLUGINMENU () {0;}
    sub NPPMAINMENU () {1;}
    sub NPPM_ENCODESCI () {( &NPPMSG + 26);}
    sub NPPM_DECODESCI () {( &NPPMSG + 27);}
    sub NPPM_ACTIVATEDOC () {( &NPPMSG + 28);}
    sub NPPM_LAUNCHFINDINFILESDLG () {( &NPPMSG + 29);}
    sub NPPM_DMMSHOW () {( &NPPMSG + 30);}
    sub NPPM_DMMHIDE () {( &NPPMSG + 31);}
    sub NPPM_DMMUPDATEDISPINFO () {( &NPPMSG + 32);}
    sub NPPM_DMMREGASDCKDLG () {( &NPPMSG + 33);}
    sub NPPM_LOADSESSION () {( &NPPMSG + 34);}
    sub NPPM_DMMVIEWOTHERTAB () {( &NPPMSG + 35);}
    sub NPPM_RELOADFILE () {( &NPPMSG + 36);}
    sub NPPM_SWITCHTOFILE () {( &NPPMSG + 37);}
    sub NPPM_SAVECURRENTFILE () {( &NPPMSG + 38);}
    sub NPPM_SAVEALLFILES () {( &NPPMSG + 39);}
    sub NPPM_SETMENUITEMCHECK () {( &NPPMSG + 40);}
    sub NPPM_ADDTOOLBARICON () {( &NPPMSG + 41);}
    sub NPPM_GETWINDOWSVERSION () {( &NPPMSG + 42);}
    sub NPPM_DMMGETPLUGINHWNDBYNAME () {( &NPPMSG + 43);}
    sub NPPM_MAKECURRENTBUFFERDIRTY () {( &NPPMSG + 44);}
    sub NPPM_GETENABLETHEMETEXTUREFUNC () {( &NPPMSG + 45);}
    sub NPPM_GETPLUGINSCONFIGDIR () {( &NPPMSG + 46);}
    sub NPPM_MSGTOPLUGIN () {( &NPPMSG + 47);}
    sub NPPM_MENUCOMMAND () {( &NPPMSG + 48);}
    sub NPPM_TRIGGERTABBARCONTEXTMENU () {( &NPPMSG + 49);}
    sub NPPM_GETNPPVERSION () {( &NPPMSG + 50);}
    sub NPPM_HIDETABBAR () {( &NPPMSG + 51);}
    sub NPPM_ISTABBARHIDDEN () {( &NPPMSG + 52);}
    sub NPPM_GETPOSFROMBUFFERID () {( &NPPMSG + 57);}
    sub NPPM_GETFULLPATHFROMBUFFERID () {( &NPPMSG + 58);}
    sub NPPM_GETBUFFERIDFROMPOS () {( &NPPMSG + 59);}
    sub NPPM_GETCURRENTBUFFERID () {( &NPPMSG + 60);}
    sub NPPM_RELOADBUFFERID () {( &NPPMSG + 61);}
    sub NPPM_GETBUFFERLANGTYPE () {( &NPPMSG + 64);}
    sub NPPM_SETBUFFERLANGTYPE () {( &NPPMSG + 65);}
    sub NPPM_GETBUFFERENCODING () {( &NPPMSG + 66);}
    sub NPPM_SETBUFFERENCODING () {( &NPPMSG + 67);}
    sub NPPM_GETBUFFERFORMAT () {( &NPPMSG + 68);}
    sub NPPM_SETBUFFERFORMAT () {( &NPPMSG + 69);}
    sub NPPM_HIDETOOLBAR () {( &NPPMSG + 70);}
    sub NPPM_ISTOOLBARHIDDEN () {( &NPPMSG + 71);}
    sub NPPM_HIDEMENU () {( &NPPMSG + 72);}
    sub NPPM_ISMENUHIDDEN () {( &NPPMSG + 73);}
    sub NPPM_HIDESTATUSBAR () {( &NPPMSG + 74);}
    sub NPPM_ISSTATUSBARHIDDEN () {( &NPPMSG + 75);}
    sub NPPM_GETSHORTCUTBYCMDID () {( &NPPMSG + 76);}
    sub NPPM_DOOPEN () {( &NPPMSG + 77);}
    sub NPPM_SAVECURRENTFILEAS () {( &NPPMSG + 78);}
    sub NPPM_GETCURRENTNATIVELANGENCODING () {( &NPPMSG + 79);}
    sub NPPM_ALLOCATESUPPORTED () {( &NPPMSG + 80);}
    sub NPPM_ALLOCATECMDID () {( &NPPMSG + 81);}
    sub NPPM_ALLOCATEMARKER () {( &NPPMSG + 82);}
    sub NPPM_GETLANGUAGENAME () {( &NPPMSG + 83);}
    sub NPPM_GETLANGUAGEDESC () {( &NPPMSG + 84);}
    sub NPPM_SHOWDOCSWITCHER () {( &NPPMSG + 85);}
    sub NPPM_ISDOCSWITCHERSHOWN () {( &NPPMSG + 86);}
    sub NPPM_GETAPPDATAPLUGINSALLOWED () {( &NPPMSG + 87);}
    sub NPPM_GETCURRENTVIEW () {( &NPPMSG + 88);}
    sub NPPM_DOCSWITCHERDISABLECOLUMN () {( &NPPMSG + 89);}
    sub NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR () {( &NPPMSG + 90);}
    sub NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR () {( &NPPMSG + 91);}
    sub NPPM_SETSMOOTHFONT () {( &NPPMSG + 92);}
    sub NPPM_SETEDITORBORDEREDGE () {( &NPPMSG + 93);}
    sub NPPM_SAVEFILE () {( &NPPMSG + 94);}
    sub NPPM_DISABLEAUTOUPDATE () {( &NPPMSG + 95);}
    sub NPPM_REMOVESHORTCUTBYCMDID () {( &NPPMSG + 96);}
    sub NPPM_GETPLUGINHOMEPATH () {( &NPPMSG + 97);}
    sub RUNCOMMAND_USER () {( &WM_USER + 3000);}
    sub NPPM_GETFULLCURRENTPATH () {( &RUNCOMMAND_USER +  &FULL_CURRENT_PATH);}
    sub NPPM_GETCURRENTDIRECTORY () {( &RUNCOMMAND_USER +  &CURRENT_DIRECTORY);}
    sub NPPM_GETFILENAME () {( &RUNCOMMAND_USER +  &FILE_NAME);}
    sub NPPM_GETNAMEPART () {( &RUNCOMMAND_USER +  &NAME_PART);}
    sub NPPM_GETEXTPART () {( &RUNCOMMAND_USER +  &EXT_PART);}
    sub NPPM_GETCURRENTWORD () {( &RUNCOMMAND_USER +  &CURRENT_WORD);}
    sub NPPM_GETNPPDIRECTORY () {( &RUNCOMMAND_USER +  &NPP_DIRECTORY);}
    sub NPPM_GETFILENAMEATCURSOR () {( &RUNCOMMAND_USER +  &GETFILENAMEATCURSOR);}
    sub NPPM_GETCURRENTLINE () {( &RUNCOMMAND_USER +  &CURRENT_LINE);}
    sub NPPM_GETCURRENTCOLUMN () {( &RUNCOMMAND_USER +  &CURRENT_COLUMN);}
    sub NPPM_GETNPPFULLFILEPATH () {( &RUNCOMMAND_USER +  &NPP_FULL_FILE_PATH);}
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
    sub NPPN_FIRST () {1000;}
    sub NPPN_READY () {( &NPPN_FIRST + 1);}
    sub NPPN_TBMODIFICATION () {( &NPPN_FIRST + 2);}
    sub NPPN_FILEBEFORECLOSE () {( &NPPN_FIRST + 3);}
    sub NPPN_FILEOPENED () {( &NPPN_FIRST + 4);}
    sub NPPN_FILECLOSED () {( &NPPN_FIRST + 5);}
    sub NPPN_FILEBEFOREOPEN () {( &NPPN_FIRST + 6);}
    sub NPPN_FILEBEFORESAVE () {( &NPPN_FIRST + 7);}
    sub NPPN_FILESAVED () {( &NPPN_FIRST + 8);}
    sub NPPN_SHUTDOWN () {( &NPPN_FIRST + 9);}
    sub NPPN_BUFFERACTIVATED () {( &NPPN_FIRST + 10);}
    sub NPPN_LANGCHANGED () {( &NPPN_FIRST + 11);}
    sub NPPN_WORDSTYLESUPDATED () {( &NPPN_FIRST + 12);}
    sub NPPN_SHORTCUTREMAPPED () {( &NPPN_FIRST + 13);}
    sub NPPN_FILEBEFORELOAD () {( &NPPN_FIRST + 14);}
    sub NPPN_FILELOADFAILED () {( &NPPN_FIRST + 15);}
    sub NPPN_READONLYCHANGED () {( &NPPN_FIRST + 16);}
    sub DOCSTATUS_READONLY () {1;}
    sub DOCSTATUS_BUFFERDIRTY () {2;}
    sub NPPN_DOCORDERCHANGED () {( &NPPN_FIRST + 17);}
    sub NPPN_SNAPSHOTDIRTYFILELOADED () {( &NPPN_FIRST + 18);}
    sub NPPN_BEFORESHUTDOWN () {( &NPPN_FIRST + 19);}
    sub NPPN_CANCELSHUTDOWN () {( &NPPN_FIRST + 20);}
    sub NPPN_FILEBEFORERENAME () {( &NPPN_FIRST + 21);}
    sub NPPN_FILERENAMECANCEL () {( &NPPN_FIRST + 22);}
    sub NPPN_FILERENAMED () {( &NPPN_FIRST + 23);}
    sub NPPN_FILEBEFOREDELETE () {( &NPPN_FIRST + 24);}
    sub NPPN_FILEDELETEFAILED () {( &NPPN_FIRST + 25);}
    sub NPPN_FILEDELETED () {( &NPPN_FIRST + 26);}
