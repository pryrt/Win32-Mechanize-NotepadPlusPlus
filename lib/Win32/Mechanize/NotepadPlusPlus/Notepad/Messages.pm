package Win32::Mechanize::NotepadPlusPlus::Notepad::Messages;

use warnings;
use strict;
use Exporter 5.57 ('import');

our @EXPORT = qw/%nppm %NPPMSG %VIEW %MODELESS %STATUSBAR %MENUHANDLE %INTERNALVAR %LANGTYPE %WINVER %WINPLATFORM %NOTIFICATION %DOCSTATUS/;

=encoding utf8

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Notepad::Messages - Define values for using messages, notifications, and their arguments

=head1 SYNOPSIS

    use Win32::Mechanize::NotepadPlusPlus ':vars';
    print "$_\n" for sort { $nppm{$a} <=> $nppm{$b} } grep { /NPPM_/ } keys %nppm;  # legacy: prints all message keys in numerical order
    print "$_\n" for sort { $NPPMSG{$a} <=> $NPPMSG{$b} } keys %NPPMSG;             # prints all message keys in numerical order


=head1 DESCRIPTION

Notepad++'s L<Plugin Communication system|https://npp-user-manual.org/docs/plugin-communication/#notepad-messages>
defines a set of messages that applications (either plugins embedded in Notepad++, or external programs)
can use for communicating with (and thus controlling) Notepad++.

The hashes in L<Win32::Mechanize::NotepadPlusPlus::Notepad::Messages> give named access to the underlying
messages, as well as named versions of the constants used as arguments for those messages.

=head2 MESSAGES

=over

=item %NPPMSG

Most of the Notepad++ Messages are already implemented in the L<Win32::Mechanize::NotepadPlusPlus> interface, and under normal circumstances, the end-user should never need to access this %NPPMSG hash directly.

However, if you have a reason to use L<Notepad-E<gt>SendMessage|Win32::Mechanize::NotepadPlusPlus/SendMessage> directly,
you can use the values from this hash.  Usually, this would only be done if you want a unique wrapper
around the message, or want to implement a new or unimplemented message.

As an example of using th %NPPMSG hash, this code replicates C<notepad-E<gt>getNppVersion> behavior:

    my $nppv = notepad->SendMessage( $NPPMSG{NPPM_GETNPPVERSION}, 0, 0);
    print "npp v", join('.', $v>>16, split//,($v&0xFFFF)), "\n";

=item %nppm (legacy)

Contains all the messages and arguments (merging all the other hashes described).

=cut

our %nppm;
our %NPPMSG = (
    'NPPMSG'                                                     => (1024 + 1000),
    # messages
    'NPPM_ACTIVATEDOC'                                           => ((1024 + 1000) + 28),
    'NPPM_ADDTOOLBARICON'                                        => ((1024 + 1000) + 41),
    'NPPM_ALLOCATECMDID'                                         => ((1024 + 1000) + 81),
    'NPPM_ALLOCATEMARKER'                                        => ((1024 + 1000) + 82),
    'NPPM_ALLOCATESUPPORTED'                                     => ((1024 + 1000) + 80),
    'NPPM_CREATESCINTILLAHANDLE'                                 => ((1024 + 1000) + 20),
    'NPPM_DECODESCI'                                             => ((1024 + 1000) + 27),
    'NPPM_DESTROYSCINTILLAHANDLE'                                => ((1024 + 1000) + 21),
    'NPPM_DISABLEAUTOUPDATE'                                     => ((1024 + 1000) + 95),
    'NPPM_DMMGETPLUGINHWNDBYNAME'                                => ((1024 + 1000) + 43),
    'NPPM_DMMHIDE'                                               => ((1024 + 1000) + 31),
    'NPPM_DMMREGASDCKDLG'                                        => ((1024 + 1000) + 33),
    'NPPM_DMMSHOW'                                               => ((1024 + 1000) + 30),
    'NPPM_DMMUPDATEDISPINFO'                                     => ((1024 + 1000) + 32),
    'NPPM_DMMVIEWOTHERTAB'                                       => ((1024 + 1000) + 35),
    'NPPM_DOCSWITCHERDISABLECOLUMN'                              => ((1024 + 1000) + 89),
    'NPPM_DOOPEN'                                                => ((1024 + 1000) + 77),
    'NPPM_ENCODESCI'                                             => ((1024 + 1000) + 26),
    'NPPM_GETAPPDATAPLUGINSALLOWED'                              => ((1024 + 1000) + 87),
    'NPPM_GETBUFFERENCODING'                                     => ((1024 + 1000) + 66),
    'NPPM_GETBUFFERFORMAT'                                       => ((1024 + 1000) + 68),
    'NPPM_GETBUFFERIDFROMPOS'                                    => ((1024 + 1000) + 59),
    'NPPM_GETBUFFERLANGTYPE'                                     => ((1024 + 1000) + 64),
    'NPPM_GETCURRENTBUFFERID'                                    => ((1024 + 1000) + 60),
    'NPPM_GETCURRENTCOLUMN'                                      => ((1024 + 3000) + 9),
    'NPPM_GETCURRENTDIRECTORY'                                   => ((1024 + 3000) + 2),
    'NPPM_GETCURRENTDOCINDEX'                                    => ((1024 + 1000) + 23),
    'NPPM_GETCURRENTLANGTYPE'                                    => ((1024 + 1000) + 5),
    'NPPM_GETCURRENTLINE'                                        => ((1024 + 3000) + 8),
    'NPPM_GETCURRENTNATIVELANGENCODING'                          => ((1024 + 1000) + 79),
    'NPPM_GETCURRENTSCINTILLA'                                   => ((1024 + 1000) + 4),
    'NPPM_GETCURRENTVIEW'                                        => ((1024 + 1000) + 88),
    'NPPM_GETCURRENTWORD'                                        => ((1024 + 3000) + 6),
    'NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR'                       => ((1024 + 1000) + 91),
    'NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR'                       => ((1024 + 1000) + 90),
    'NPPM_GETENABLETHEMETEXTUREFUNC'                             => ((1024 + 1000) + 45),
    'NPPM_GETEXTPART'                                            => ((1024 + 3000) + 5),
    'NPPM_GETFILENAME'                                           => ((1024 + 3000) + 3),
    'NPPM_GETFILENAMEATCURSOR'                                   => ((1024 + 3000) + 11),
    'NPPM_GETFULLCURRENTPATH'                                    => ((1024 + 3000) + 1),
    'NPPM_GETFULLPATHFROMBUFFERID'                               => ((1024 + 1000) + 58),
    'NPPM_GETLANGUAGEDESC'                                       => ((1024 + 1000) + 84),
    'NPPM_GETLANGUAGENAME'                                       => ((1024 + 1000) + 83),
    'NPPM_GETMENUHANDLE'                                         => ((1024 + 1000) + 25),
    'NPPM_GETNAMEPART'                                           => ((1024 + 3000) + 4),
    'NPPM_GETNBOPENFILES'                                        => ((1024 + 1000) + 7),
    'NPPM_GETNBSESSIONFILES'                                     => ((1024 + 1000) + 13),
    'NPPM_GETNBUSERLANG'                                         => ((1024 + 1000) + 22),
    'NPPM_GETNPPDIRECTORY'                                       => ((1024 + 3000) + 7),
    'NPPM_GETNPPFULLFILEPATH'                                    => ((1024 + 3000) + 10),
    'NPPM_GETNPPVERSION'                                         => ((1024 + 1000) + 50),
    'NPPM_GETOPENFILENAMES'                                      => ((1024 + 1000) + 8),
    'NPPM_GETOPENFILENAMESPRIMARY'                               => ((1024 + 1000) + 17),
    'NPPM_GETOPENFILENAMESSECOND'                                => ((1024 + 1000) + 18),
    'NPPM_GETPLUGINHOMEPATH'                                     => ((1024 + 1000) + 97),
    'NPPM_GETPLUGINSCONFIGDIR'                                   => ((1024 + 1000) + 46),
    'NPPM_GETPOSFROMBUFFERID'                                    => ((1024 + 1000) + 57),
    'NPPM_GETSESSIONFILES'                                       => ((1024 + 1000) + 14),
    'NPPM_GETSHORTCUTBYCMDID'                                    => ((1024 + 1000) + 76),
    'NPPM_GETWINDOWSVERSION'                                     => ((1024 + 1000) + 42),
    'NPPM_HIDEMENU'                                              => ((1024 + 1000) + 72),
    'NPPM_HIDESTATUSBAR'                                         => ((1024 + 1000) + 74),
    'NPPM_HIDETABBAR'                                            => ((1024 + 1000) + 51),
    'NPPM_HIDETOOLBAR'                                           => ((1024 + 1000) + 70),
    'NPPM_ISDOCSWITCHERSHOWN'                                    => ((1024 + 1000) + 86),
    'NPPM_ISMENUHIDDEN'                                          => ((1024 + 1000) + 73),
    'NPPM_ISSTATUSBARHIDDEN'                                     => ((1024 + 1000) + 75),
    'NPPM_ISTABBARHIDDEN'                                        => ((1024 + 1000) + 52),
    'NPPM_ISTOOLBARHIDDEN'                                       => ((1024 + 1000) + 71),
    'NPPM_LAUNCHFINDINFILESDLG'                                  => ((1024 + 1000) + 29),
    'NPPM_LOADSESSION'                                           => ((1024 + 1000) + 34),
    'NPPM_MAKECURRENTBUFFERDIRTY'                                => ((1024 + 1000) + 44),
    'NPPM_MENUCOMMAND'                                           => ((1024 + 1000) + 48),
    'NPPM_MODELESSDIALOG'                                        => ((1024 + 1000) + 12),
    'NPPM_MSGTOPLUGIN'                                           => ((1024 + 1000) + 47),
    'NPPM_RELOADBUFFERID'                                        => ((1024 + 1000) + 61),
    'NPPM_RELOADFILE'                                            => ((1024 + 1000) + 36),
    'NPPM_REMOVESHORTCUTBYCMDID'                                 => ((1024 + 1000) + 96),
    'NPPM_SAVEALLFILES'                                          => ((1024 + 1000) + 39),
    'NPPM_SAVECURRENTFILE'                                       => ((1024 + 1000) + 38),
    'NPPM_SAVECURRENTFILEAS'                                     => ((1024 + 1000) + 78),
    'NPPM_SAVECURRENTSESSION'                                    => ((1024 + 1000) + 16),
    'NPPM_SAVEFILE'                                              => ((1024 + 1000) + 94),
    'NPPM_SAVESESSION'                                           => ((1024 + 1000) + 15),
    'NPPM_SETBUFFERENCODING'                                     => ((1024 + 1000) + 67),
    'NPPM_SETBUFFERFORMAT'                                       => ((1024 + 1000) + 69),
    'NPPM_SETBUFFERLANGTYPE'                                     => ((1024 + 1000) + 65),
    'NPPM_SETCURRENTLANGTYPE'                                    => ((1024 + 1000) + 6),
    'NPPM_SETEDITORBORDEREDGE'                                   => ((1024 + 1000) + 93),
    'NPPM_SETMENUITEMCHECK'                                      => ((1024 + 1000) + 40),
    'NPPM_SETSMOOTHFONT'                                         => ((1024 + 1000) + 92),
    'NPPM_SETSTATUSBAR'                                          => ((1024 + 1000) + 24),
    'NPPM_SHOWDOCSWITCHER'                                       => ((1024 + 1000) + 85),
    'NPPM_SWITCHTOFILE'                                          => ((1024 + 1000) + 37),
    'NPPM_TRIGGERTABBARCONTEXTMENU'                              => ((1024 + 1000) + 49),

    # message offsets
    'WM_USER'                                                    => 1024,
    'RUNCOMMAND_USER'                                            => (1024 + 3000),
);
%nppm = (%nppm, %NPPMSG); # appending

=item %VIEW

=item TODO: L<issue #17|>https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/17>

There are two groups of methods that access the views.

The first is L<getNumberOpenFiles()|Win32::Mechanize::NotepadPlusPlus::Notepad/getNumberOpenFiles>,
which uses three of the %VIEW keys to count the number of files open in the specified view.

    Key             | Value | Description
    ----------------+-------+------------------------------
    ALL_OPEN_FILES  | 0     | Total of files in both views
    PRIMARY_VIEW    | 1     | Only the files in the primary view (usually the left view: editor1)
    SECOND_VIEW     | 2     | Only the files in the second view (usually the right view: editor2)


The second group are the L<buffer-related methods|Win32::Mechanize::NotepadPlusPlus::Notepad/"Get/Change Active Buffers">.

    Key             | Value | Description
    ----------------+-------+------------------------------
    MAIN_VIEW       | 0     | Access the main view (usually the left view: editor1)
    SUB_VIEW        | 1     | Access the sub view (usually the right view: editor2)

Yes, the two groups have an off-by-one.  That's the way the underlying Notepad++ code, and thus the Plugin Interface, was designed.

=cut

our %VIEW = (
    # view params (NPPM_GETNBOPENFILES)
    'ALL_OPEN_FILES'                                             => 0,
    'PRIMARY_VIEW'                                               => 1,
    'SECOND_VIEW'                                                => 2,
    # view params (NPPM_GETCURRENTDOCINDEX)
    'MAIN_VIEW'                                                  => 0,
    'SUB_VIEW'                                                   => 1,
);
%nppm = (%nppm, %VIEW); # appending

=item %MODELESS

=item TODO: L<issue #18|https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/18>

These would be used by the C<$NPPMSG{NPPM_MODELESSDIALOG}> message.
However, L<registerModelessDialog()|Win32::Mechanize::NotepadPlusPlus::Notepad/registerModelessDialog>
has not yet been implemented.

    Key                     | Description
    ------------------------|------------
    MODELESSDIALOGADD       | Registers a dialog's hWnd
    MODELESSDIALOGREMOVE    | Un-registers a dialog's hWnd

=cut

our %MODELESS = (
    # NPPM_MODELESSDIALOG params
    'MODELESSDIALOGADD'                                          => 0,
    'MODELESSDIALOGREMOVE'                                       => 1,
);
%nppm = (%nppm, %MODELESS); # appending

=item %STATUSBAR

These are be used by the L<setStatusBar()|Win32::Mechanize::NotepadPlusPlus::Notepad/setStatusBar> method for choosing which section of the status bar to change.

    Key                     |   | Description
    ------------------------+---+-----------------
    STATUSBAR_DOC_TYPE      | 0 | Document's syntax lexer (language)
    STATUSBAR_DOC_SIZE      | 1 | File size
    STATUSBAR_CUR_POS       | 2 | Current cursor position
    STATUSBAR_EOF_FORMAT    | 3 | EOL (End-Of-Line) format
    STATUSBAR_UNICODE_TYPE  | 4 | Encoding
    STATUSBAR_TYPING_MODE   | 5 | Insert (INS) or Overwrite (OVR)

=cut

our %STATUSBAR = (
    # NPPM_SETSTATUSBAR params
    'STATUSBAR_DOC_TYPE'                                         => 0,
    'STATUSBAR_DOC_SIZE'                                         => 1,
    'STATUSBAR_CUR_POS'                                          => 2,
    'STATUSBAR_EOF_FORMAT'                                       => 3,
    'STATUSBAR_UNICODE_TYPE'                                     => 4,
    'STATUSBAR_TYPING_MODE'                                      => 5,
);
%nppm = (%nppm, %STATUSBAR); # appending

=item %MENUHANDLE

Used internally by L<getMainMenuHandle()|Win32::Mechanize::NotepadPlusPlus::Notepad/getMainMenuHandle>  and
L<getPluginMenuHandle()|Win32::Mechanize::NotepadPlusPlus::Notepad/getPluginMenuHandle> to return handles to the specified menus.

    Key             |   | Description
    ----------------+---+-----------------
    NPPMAINMENU     | 1 | Main menu (contains File, Edit, ...)
    NPPPLUGINMENU   | 0 | Plugins menu (a submenu of the Main menu)

=cut

our %MENUHANDLE = (
    # NPPM_GETMENUHANDLE params
    'NPPPLUGINMENU'                                              => 0,
    'NPPMAINMENU'                                                => 1,
);
%nppm = (%nppm, %MENUHANDLE); # appending

=item %INTERNALVAR

=item TODO: L<issue #19|https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/19>

Not yet implemented.

Pass these to L<getNppDir()|Win32::Mechanize::NotepadPlusPlus::Notepad/getNppDir> (not yet implemented) to access the internal variables described L<in the Macros section of the official docs|https://npp-user-manual.org/docs/config-files/#macros>.


    Key                 | Description                               | Example
    --------------------+-------------------------------------------+----------------------------
    FULL_CURRENT_PATH   | full path to the active file              | E:\My Web\main\welcome.html
    CURRENT_DIRECTORY   | active file’s directory                   | E:\My Web\main
    FILE_NAME           | active file’s name                        | welcome.html
    NAME_PART           | filename without extension                | welcome
    EXT_PART            | extension                                 | html
    CURRENT_WORD        | active selection or word under the cursor | text
    CURRENT_LINE        | line number of cursor location            | 1
    CURRENT_COLUMN      | column number of cursor location          | 5
    NPP_DIRECTORY       | notepad++ executable's directory          | c:\Program Files\notepad++
    NPP_FULL_FILE_PATH  | full path to the notepad++.exe            | c:\Program Files\notepad++\notepad++.exe

=cut


our %INTERNALVAR = (
    'VAR_NOT_RECOGNIZED'                                         => 0,
    'FULL_CURRENT_PATH'                                          => 1,
    'CURRENT_DIRECTORY'                                          => 2,
    'FILE_NAME'                                                  => 3,
    'NAME_PART'                                                  => 4,
    'EXT_PART'                                                   => 5,
    'CURRENT_WORD'                                               => 6,
    'NPP_DIRECTORY'                                              => 7,
    'CURRENT_LINE'                                               => 8,
    'CURRENT_COLUMN'                                             => 9,
    'NPP_FULL_FILE_PATH'                                         => 10,
    'GETFILENAMEATCURSOR'                                        => 11,
);
%nppm = (%nppm, %INTERNALVAR); # appending

=item %LANGTYPE

Used by L<language parser methods|Win32::Mechanize::NotepadPlusPlus::Notepad/"Get/Set Language Parser">.

    L_TEXT      : 0  | L_CSS       : 20 | L_AU3           : 40 | L_BAANC         : 60 | L_REGISTRY      : 80 |
    L_PHP       : 1  | L_PERL      : 21 | L_CAML          : 41 | L_SREC          : 61 | L_RUST          : 81 |
    L_C         : 2  | L_PYTHON    : 22 | L_ADA           : 42 | L_IHEX          : 62 | L_SPICE         : 82 |
    L_CPP       : 3  | L_LUA       : 23 | L_VERILOG       : 43 | L_TEHEX         : 63 | L_TXT2TAGS      : 83 |
    L_CS        : 4  | L_TEX       : 24 | L_MATLAB        : 44 | L_SWIFT         : 64 | L_VISUALPROLOG  : 84 |
    L_OBJC      : 5  | L_FORTRAN   : 25 | L_HASKELL       : 45 | L_ASN1          : 65 | L_EXTERNAL      : 85 |
    L_JAVA      : 6  | L_BASH      : 26 | L_INNO          : 46 | L_AVS           : 66 |                 :    |
    L_RC        : 7  | L_FLASH     : 27 | L_SEARCHRESULT  : 47 | L_BLITZBASIC    : 67 |                 :    |
    L_HTML      : 8  | L_NSIS      : 28 | L_CMAKE         : 48 | L_PUREBASIC     : 68 |                 :    |
    L_XML       : 9  | L_TCL       : 29 | L_YAML          : 49 | L_FREEBASIC     : 69 |                 :    |
    L_MAKEFILE  : 10 | L_LISP      : 30 | L_COBOL         : 50 | L_CSOUND        : 70 |                 :    |
    L_PASCAL    : 11 | L_SCHEME    : 31 | L_GUI4CLI       : 51 | L_ERLANG        : 71 |                 :    |
    L_BATCH     : 12 | L_ASM       : 32 | L_D             : 52 | L_ESCRIPT       : 72 |                 :    |
    L_INI       : 13 | L_DIFF      : 33 | L_POWERSHELL    : 53 | L_FORTH         : 73 |                 :    |
    L_ASCII     : 14 | L_PROPS     : 34 | L_R             : 54 | L_LATEX         : 74 |                 :    |
    L_USER      : 15 | L_PS        : 35 | L_JSP           : 55 | L_MMIXAL        : 75 |                 :    |
    L_ASP       : 16 | L_RUBY      : 36 | L_COFFEESCRIPT  : 56 | L_NIMROD        : 76 |                 :    |
    L_SQL       : 17 | L_SMALLTALK : 37 | L_JSON          : 57 | L_NNCRONTAB     : 77 |                 :    |
    L_VB        : 18 | L_VHDL      : 38 | L_JAVASCRIPT    : 58 | L_OSCRIPT       : 78 |                 :    |
    L_JS        : 19 | L_KIX       : 39 | L_FORTRAN_77    : 59 | L_REBOL         : 79 |                 :    |

=cut

our %LANGTYPE = (
    # enum LangType
    'L_ADA'                                                      => 42,
    'L_ASCII'                                                    => 14,
    'L_ASM'                                                      => 32,
    'L_ASN1'                                                     => 65,
    'L_ASP'                                                      => 16,
    'L_AU3'                                                      => 40,
    'L_AVS'                                                      => 66,
    'L_BAANC'                                                    => 60,
    'L_BASH'                                                     => 26,
    'L_BATCH'                                                    => 12,
    'L_BLITZBASIC'                                               => 67,
    'L_C'                                                        => 2,
    'L_CAML'                                                     => 41,
    'L_CMAKE'                                                    => 48,
    'L_COBOL'                                                    => 50,
    'L_COFFEESCRIPT'                                             => 56,
    'L_CPP'                                                      => 3,
    'L_CS'                                                       => 4,
    'L_CSOUND'                                                   => 70,
    'L_CSS'                                                      => 20,
    'L_D'                                                        => 52,
    'L_DIFF'                                                     => 33,
    'L_ERLANG'                                                   => 71,
    'L_ESCRIPT'                                                  => 72,
    'L_EXTERNAL'                                                 => 85,
    'L_FLASH'                                                    => 27,
    'L_FORTH'                                                    => 73,
    'L_FORTRAN'                                                  => 25,
    'L_FORTRAN_77'                                               => 59,
    'L_FREEBASIC'                                                => 69,
    'L_GUI4CLI'                                                  => 51,
    'L_HASKELL'                                                  => 45,
    'L_HTML'                                                     => 8,
    'L_IHEX'                                                     => 62,
    'L_INI'                                                      => 13,
    'L_INNO'                                                     => 46,
    'L_JAVA'                                                     => 6,
    'L_JAVASCRIPT'                                               => 58,
    'L_JS'                                                       => 19,
    'L_JSON'                                                     => 57,
    'L_JSP'                                                      => 55,
    'L_KIX'                                                      => 39,
    'L_LATEX'                                                    => 74,
    'L_LISP'                                                     => 30,
    'L_LUA'                                                      => 23,
    'L_MAKEFILE'                                                 => 10,
    'L_MATLAB'                                                   => 44,
    'L_MMIXAL'                                                   => 75,
    'L_NIMROD'                                                   => 76,
    'L_NNCRONTAB'                                                => 77,
    'L_NSIS'                                                     => 28,
    'L_OBJC'                                                     => 5,
    'L_OSCRIPT'                                                  => 78,
    'L_PASCAL'                                                   => 11,
    'L_PERL'                                                     => 21,
    'L_PHP '                                                     => 1,
    'L_POWERSHELL'                                               => 53,
    'L_PROPS'                                                    => 34,
    'L_PS'                                                       => 35,
    'L_PUREBASIC'                                                => 68,
    'L_PYTHON'                                                   => 22,
    'L_R'                                                        => 54,
    'L_RC'                                                       => 7,
    'L_REBOL'                                                    => 79,
    'L_REGISTRY'                                                 => 80,
    'L_RUBY'                                                     => 36,
    'L_RUST'                                                     => 81,
    'L_SCHEME'                                                   => 31,
    'L_SEARCHRESULT'                                             => 47,
    'L_SMALLTALK'                                                => 37,
    'L_SPICE'                                                    => 82,
    'L_SQL'                                                      => 17,
    'L_SREC'                                                     => 61,
    'L_SWIFT'                                                    => 64,
    'L_TCL'                                                      => 29,
    'L_TEHEX'                                                    => 63,
    'L_TEX'                                                      => 24,
    'L_TEXT'                                                     => 0,
    'L_TXT2TAGS'                                                 => 83,
    'L_USER'                                                     => 15,
    'L_VB'                                                       => 18,
    'L_VERILOG'                                                  => 43,
    'L_VHDL'                                                     => 38,
    'L_VISUALPROLOG'                                             => 84,
    'L_XML'                                                      => 9,
    'L_YAML'                                                     => 49,
);
%nppm = (%nppm, %LANGTYPE); # appending

=item %WINVER

I'm not sure it's really useful, but it's still privided.

    print join "\n", map { "$_ => $WINVER{$_}" } sort keys %WINVER;

=cut

our %WINVER = (
    # enum WinVer
    'WV_95'                                                      => 2,
    'WV_98'                                                      => 3,
    'WV_ME'                                                      => 4,
    'WV_NT'                                                      => 5,
    'WV_S2003'                                                   => 8,
    'WV_UNKNOWN'                                                 => 0,
    'WV_VISTA'                                                   => 10,
    'WV_W2K'                                                     => 6,
    'WV_WIN10'                                                   => 14,
    'WV_WIN32S'                                                  => 1,
    'WV_WIN7'                                                    => 11,
    'WV_WIN8'                                                    => 12,
    'WV_WIN81'                                                   => 13,
    'WV_XP'                                                      => 7,
    'WV_XPX64'                                                   => 9,
);
%nppm = (%nppm, %WINVER); # appending

=item %WINPLATFORM

I'm not sure it's really useful, but it's still privided.

    print join "\n", map { "$_ => $WINPLATFORM{$_}" } sort keys %WINPLATFORM;

=cut

our %WINPLATFORM = (
    # enum Platform
    'PF_IA64'                                                    => 3,
    'PF_UNKNOWN'                                                 => 0,
    'PF_X64'                                                     => 2,
    'PF_X86'                                                     => 1,

);
%nppm = (%nppm, %WINPLATFORM); # appending

=back

=head2 NOTIFICATIONS

Not yet used, but the constants are available.

=over

=item %NOTIFICATION

If you are interested, you can find all the message keys with code like the following:

    use Win32::Mechanize::NotepadPlusPlus ':vars';
    printf "%-39s => %d\n", $_, $NOTIFICATION{$_} for sort { $NOTIFICATION{$a} <=> $NOTIFICATION{$b} } keys %NOTIFICATION;   # prints all notification keys in numerical order

=cut


# NPP Notifications
our %NOTIFICATION = (
    'NPPN_FIRST'                                                 => 1000,
    'NPPN_BEFORESHUTDOWN'                                        => (1000 + 19),
    'NPPN_BUFFERACTIVATED'                                       => (1000 + 10),
    'NPPN_CANCELSHUTDOWN'                                        => (1000 + 20),
    'NPPN_DOCORDERCHANGED'                                       => (1000 + 17),
    'NPPN_FILEBEFORECLOSE'                                       => (1000 + 3),
    'NPPN_FILEBEFOREDELETE'                                      => (1000 + 24),
    'NPPN_FILEBEFORELOAD'                                        => (1000 + 14),
    'NPPN_FILEBEFOREOPEN'                                        => (1000 + 6),
    'NPPN_FILEBEFORERENAME'                                      => (1000 + 21),
    'NPPN_FILEBEFORESAVE'                                        => (1000 + 7),
    'NPPN_FILECLOSED'                                            => (1000 + 5),
    'NPPN_FILEDELETED'                                           => (1000 + 26),
    'NPPN_FILEDELETEFAILED'                                      => (1000 + 25),
    'NPPN_FILELOADFAILED'                                        => (1000 + 15),
    'NPPN_FILEOPENED'                                            => (1000 + 4),
    'NPPN_FILERENAMECANCEL'                                      => (1000 + 22),
    'NPPN_FILERENAMED'                                           => (1000 + 23),
    'NPPN_FILESAVED'                                             => (1000 + 8),
    'NPPN_LANGCHANGED'                                           => (1000 + 11),
    'NPPN_READONLYCHANGED'                                       => (1000 + 16),
    'NPPN_READY'                                                 => (1000 + 1),
    'NPPN_SHORTCUTREMAPPED'                                      => (1000 + 13),
    'NPPN_SHUTDOWN'                                              => (1000 + 9),
    'NPPN_SNAPSHOTDIRTYFILELOADED'                               => (1000 + 18),
    'NPPN_TBMODIFICATION'                                        => (1000 + 2),
    'NPPN_WORDSTYLESUPDATED'                                     => (1000 + 12),
);
%nppm = (%nppm, %NOTIFICATION); # appending

=item %DOCSTATUS

Used by the NPPN_READONLYCHANGED notification.

    Key                     |   | Description
    ------------------------+---+-----------------
    DOCSTATUS_READONLY      | 1 | The file changed its "is readonly" status
    DOCSTATUS_BUFFERDIRTY   | 0 | The file changed its "is modified" status

=cut

our %DOCSTATUS = (
    # NPPN_READONLYCHANGED notification params
    'DOCSTATUS_READONLY'                                         => 1,
    'DOCSTATUS_BUFFERDIRTY'                                      => 2,
);
%nppm = (%nppm, %DOCSTATUS); # appending

=back

=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2019,2020 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
