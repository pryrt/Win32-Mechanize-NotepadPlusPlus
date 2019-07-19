package Win32::Mechanize::NotepadPlusPlus::Notepad;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use IPC::Open2;
use Win32::API;
use Carp;
    BEGIN {
        Win32::API::->Import("user32","DWORD GetWindowThreadProcessId( HWND hWnd, LPDWORD lpdwProcessId)") or die "GetWindowThreadProcessId: $^E";
        # http://www.perlmonks.org/?node_id=806573 shows how to import the GetWindowThreadProcessId(), and it's reply shows how to pack/unpack the arguments to extract appropriate PID
    }
use Win32::GuiTest ':FUNC';
    BEGIN {
        Win32::API::->Import("kernel32","HMODULE GetModuleHandle(LPCTSTR lpModuleName)") or die "GetModuleHandle: $^E";
        my $hModule = GetModuleHandle("kernel32.dll") or die "GetModuleHandle: $! ($^E)";
        print "handle(kernel32.dll) = '$hModule'\n";

        Win32::API::->Import("kernel32","BOOL WINAPI GetModuleHandleEx(DWORD dwFlags, LPCTSTR lpModuleName, HMODULE *phModule)") or die "GetModuleHandleEx: $^E";

        Win32::API::->Import("kernel32","HANDLE WINAPI OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId)") or die "OpenProcess: $! ($^E)";

        Win32::API::->Import("kernel32","DWORD GetModuleFileName(HMODULE hModule, LPTSTR lpFilename, DWORD nSize)") or die "GetModuleFileName: $^E";
        Win32::API::->Import("psapi","DWORD WINAPI GetModuleFileNameEx(HANDLE  hProcess, HMODULE hModule, LPTSTR  lpFilename, DWORD   nSize)") or die "GetModuleFileNameEx: $^E";
    }

our $VERSION = '0.000001';  # TODO = make this automatically the same version as NotepadPlusPlus.pm # idea from [id://1209488] = sub VERSION { shift->SUPER::VERSION(@_) || '0.000000_000' }

use Inline C => Config =>
    BUILD_NOISY => 1,
    USING => 'ParseRegExp',
    #CLEAN_AFTER_BUILD => 0,
    ccflagsex => '-Wno-int-to-pointer-cast',        # fix (hwnd)handle warning
    ;
use Inline C => <<'EOC';

LRESULT mySendMessageNN( HWND handle, UINT msg, WPARAM wparam, LPARAM lparam)
{
    return SendMessage(handle, msg, (WPARAM) wparam, (LPARAM) lparam);
}

LRESULT mySendMessageNP( HWND handle, UINT msg, WPARAM wparam, LPVOID lparam)
{
    return SendMessage(handle, msg, (WPARAM) wparam, (LPARAM) lparam);
}

/*
double sendNPtest( long handle, long msg, long wparam )
{
    char lret[1024];
    double rv;
    rv = (double)mySendMessageNP( (HWND)handle, (UINT)msg, (WPARAM)wparam, (LPVOID)lret);
    printf("debug: rv=%f, lret=_%s_\n");
    return rv;
}
*/

double sendtest( long handle )
{
    return (double)mySendMessageNN( (HWND)handle, 0x0400 + 1000 + 7 , (WPARAM)0, (LPARAM)0);
}

double sendtest2( long handle, long msg )
{
    return (double)mySendMessageNN( (HWND)handle, (UINT)msg , (WPARAM)0, (LPARAM)1);
}

double sendtest4( long handle, long msg, long wparam, long lparam )
{
    return (double)mySendMessageNN( (HWND)handle, (UINT)msg , (WPARAM)wparam, (LPARAM)lparam);
}

double nxtafter(double in, double dir) {
    return nextafter(in, dir);
}

EOC

=pod

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Notepad - The main application object for Notepad++ automation

=head1 SYNOPSIS

    use Win32::Mechanize::NotepadPlusPlus ':main';
    my $npp = notepad();    # main application

=head1 DESCRIPTION

The editor object for Notepad++ automation using L<Win32::Mechanize::NotepadPlusPlus>

=cut

my $npp_exe;
BEGIN {
    use File::Which 'which';
    # TODO = if it's already running, just use that path
#    my $already_running;
#    my ($hwnd) = Win32::GuiTest::FindWindowLike(undef, undef, '^Notepad++');
#    if(defined $hwnd) {
#        my $pidStruct = pack("L" => 0);
#        my $gwtpi = GetWindowThreadProcessId( $hwnd, $pidStruct );
#        my $extractPid = unpack("L" => $pidStruct);
#        print "already running hwnd#$hwnd, pid#$extractPid from '$pidStruct'\n";
#        my $pHandle = OpenProcess( 0xFFFF , 0, $extractPid)
#            or die "Cannot OpenProcess(0xFFFF,0,$extractPid): $! ($^E)";
#        print "pHandle='$pHandle'\n";
#        my $bufStr = Win32::GuiTest::AllocateVirtualBuffer( $hwnd, 1000 ) or die "buffer: $! ($^E)";
#        Win32::GuiTest::WriteToVirtualBuffer( $bufStr, "This is a test") or die "buffer: $! ($^E)";
#        print Win32::GuiTest::ReadFromVirtualBuffer( $bufStr , 1000) or die "buf read: $! ($^E)";
#        print "\n";
#        my $dw = GetModuleFileNameEx( $pHandle , 0, $bufStr, 1000);
#        my $vBuf = Win32::GuiTest::ReadFromVirtualBuffer( $bufStr , 1000) or die "buf read: $! ($^E)";
#        print "GMFNE($pHandle) = dw:$dw, '$vBuf'\n";
#    }

    # if it's not already running,
    foreach my $try (   # priority to path, 64bit, default, then x86-specific locations
        which('notepad++'),
        "$ENV{ProgramW6432}/Notepad++/notepad++.exe",
        "$ENV{ProgramFiles}/Notepad++/notepad++.exe",
        "$ENV{'ProgramFiles(x86)'}/Notepad++/notepad++.exe",
    )
    {
        $npp_exe = $try if -x $try;
        last if defined $npp_exe;
    }
    die "could not find an instance of notepad++; please add it to your path" unless defined $npp_exe;
    print STDERR __PACKAGE__, " found '$npp_exe'\n";
}

sub new
{
    my ($class, @args) = @_;
    my $self = bless {
        _exe => $npp_exe,
        _pid => undef,
        _hwnd => undef,
        editor1 => undef,
        editor2 => undef,
        editor  => undef,
        console => undef,
    }, $class;

    # start the process:
    my $launchPid = open2(my $npo, my $npi, $npp_exe);  # qw/notepad++ -multiInst -noPlugin/, $fname)
    $self->{_hwnd} = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5 ) # wait up to 5sec
        or croak "could not open the Notepad++ application";
    foreach my $hwnd ( $self->{_hwnd} ) {
        # if there's already an instance of NPP, then the launchPid process will go away quickly,
        #   so need to grab the process back from the hwnd found
        my $pidStruct = pack("L" => 0);
        my $gwtpi = GetWindowThreadProcessId($hwnd, $pidStruct);
        my $extractPid = unpack("L" => $pidStruct);
        warn sprintf "%-15.15s %-15.15s %-39.39s %-59.59s %-15.15s\n",
                    "launchPid:".$launchPid,
                    "h:$hwnd",
                    'c:'.Win32::GuiTest::GetClassName($hwnd),
                    't:'.Win32::GuiTest::GetWindowText($hwnd),
                    'extractPid:'.$extractPid,
                ;
        $self->{_pid} = $extractPid;
    }

    # 2019-Jul-19:
    #   Here, my long-term goal is to create new Editor and Console objects for $self->{editor, editor1, editor2, console}

    carp "NOT YET IMPLEMENTED: find current/active scintilla (::getCurrentView() => NPPM_GETCURRENTSCINTILLA)";
    carp "NOT YET IMPLEMENTED: scintilla editor1";
    carp "NOT YET IMPLEMENTED: scintilla editor2";
    carp "NOT YET IMPLEMENTED: scintilla console";  # actually, any "console" I found would be the PythonScript console and/or NppExec console

    # 2018-Apr-13
    # found the PythonScript at https://github.com/bruderstein/PythonScript/
    #   it uses NotepadPlusWrapper::getCurrentView() = callNotepad(NPPM_GETCURRENTSCINTILLA, 0, reinterpret_cast<LPARAM>(&currentView)))
    #       => SendMessage( nppHandle, message arg[0], wparam [1], lparam [2] )
    #   there is also msg(NPPM_GETCURRENTVIEW), but that doesn't seem to be used
    #
    # so, at this point, I might need to brave messages to the notepad window
    #
    # 2019-Jul-19:
    #   Back then, I started experimenting with messages and notifications...
    #   but I started cluttering this ->new() method, rather than keeping things encapsulated.
    #   I really want to start splitting things off, so I can have an external script for
    #   doing the debug of the messaging (maybe `<DIST>/debug/sendMessage.pl`)
    #   For now, commit with improved comments, then start moving things out

    return $self;
}

sub notepad { my $self = shift; $self }
sub editor1 { my $self = shift; $self->{editor1} }
sub editor2 { my $self = shift; $self->{editor2} }
sub editor  { my $self = shift; $self->{editor } }
sub console { my $self = shift; $self->{console} }

sub sendNotepadMessage
{
    my $hwnd = $_[0]->{_hwnd};
    my $result = SendMessage( $hwnd, @_[1..3]);
        my @args = ($hwnd, @_[1..3]);
        local $" = ',';
        warn "Notepad++::SendMessage(@args) = $result\n";
        return $result;
}

sub sendOtherMessage
{
    my $result = SendMessage(@_[1..4]);
        local $" = ',';
        warn "Other    ::SendMessage(@_[1..4]) = $result\n";
        return $result;
}

sub _debug_FindScintillaHwnds
{
    my $self = shift;
    # 2019-Jul-19:
    #   Back in 2018-Apr, I found a way to list the hwnds of the scintilla sub-windows, but I don't know which is which.
    #   Not really sure this still belongs in ...::Notepad->New()
    my $sci_hwnd = undef;
    foreach my $hwnd ( FindWindowLike($self->{_hwnd}, undef, '^Scintilla$') ) {
        warn sprintf "%-15.15s %-15.15s %-39.39s %-59.59s\n",
                "SCINTILLA:",
                "h:$hwnd",
                'c:'.Win32::GuiTest::GetClassName($hwnd),
                't:"'.Win32::GuiTest::GetWindowText($hwnd).'"#'.length(Win32::GuiTest::GetWindowText($hwnd)),
            ;
        warn "\t\t\tVisible => ", IsWindowVisible($hwnd) ? 'y' : 'n', "\n";
        warn "\t\t\tEnabled => ", IsWindowEnabled($hwnd) ? 'y' : 'n', "\n";
        local $" = ",";
        my @rect = GetWindowRect($hwnd);
        warn "\t\t\tWindowRect => (@rect)\n";
        $sci_hwnd = $hwnd if IsWindowVisible($hwnd) && !defined $sci_hwnd;
    }
    return $sci_hwnd;
}

sub _debug_sendVariousMessages
{
    # TODO = eventually, need to move the messaging to a separate module; messaging is not inherent to the Notepad++ object, but something that the object needs help doing

    my $self = shift;
    my $sci_hwnd = shift;
    $sci_hwnd = $self->_debug_FindScintillaHwnds() unless(defined $sci_hwnd);

    # http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
    #
    #define NPPM_GETCURRENTSCINTILLA (NPPMSG + 4)
    #define NPPMSG (WM_USER + 1000)
    #define WM_USER 0x0400                      https://msdn.microsoft.com/en-us/library/windows/desktop/ms644931(v=vs.85).aspx

    # try a scintilla message, for the fun of it:  npp_exec:`sci_sendmsg SCI_GOTOLINE 0` worked
    #       #define SCI_GOTOLINE 2024
    my $wparam = __LINE__ - 1;      # goto this line (the "-1" is because scintilla is 0-based)
    my $lparam = 0;
    my $res = $self->sendOtherMessage(  $sci_hwnd, 2024, $wparam, $lparam);
    carp "::DEBUG:: Active scintilla should be at line @{[$wparam + 1]}, assuming that many lines in the active editor";
    <STDIN>;

    # try a zero-arg NPPM message: NPPM_SAVECURRENTFILE (NPPMSG + 38)
    $wparam = 0;
    $lparam = 0;
    $res = $self->sendNotepadMessage( 0x0400 + 1000 + 38 , $wparam, $lparam );
    carp "::DEBUG:: Active scintilla should have saved (more obvious if you had left unsaved changes)";
    <STDIN>;

    # Per Messages_And_Notifications, NPPM_GETNBOPENFILES(0, nbType)    (NPPMSG+7)
    #   is a single argument in lparam; will return into RESULT the number of files
    #       nbType=0 => ALL         num open files
    #       nbType=1 => PRIMARY     num files in primary view
    #       nbType=3 => SECOND      num files in primary view
    $wparam = 0;
    $lparam = 0;
    $res = $self->sendNotepadMessage( 0x0400 + 1000 + 7 , $wparam, $lparam=0 ); printf STDERR "__%04d__ %-12s%d\n", __LINE__, 'all:', $res;
    $res = $self->sendNotepadMessage( 0x0400 + 1000 + 7 , $wparam, $lparam=1 ); printf STDERR "__%04d__ %-12s%d\n", __LINE__, 'primary:', $res;
    $res = $self->sendNotepadMessage( 0x0400 + 1000 + 7 , $wparam, $lparam=2 ); printf STDERR "__%04d__ %-12s%d\n", __LINE__, 'secondary:', $res;

    # try reading back NPPM_GETCURRENTLANGTYPE(0, out int *)    (NPPMSG + 5)
    $wparam = 0;
#    $lparam = pack("L" => 0);
#    $res = $self->sendNotepadMessage( 0x0400 + 1000 + 5 , $wparam, $lparam );
# https://metacpan.org/source/KMX/Win32-GUI-1.14/Win32-GUI_Scintilla/Scintilla.xs
#   the Win32::GUI::Scintilla XS code shows three additional SendMessage maps:
#       SendMessageNP(..., WPARAM wparam, LPVOID lparam)    -- w:int l:ptr
#       SendMessagePN(..., LPVOID wparam, int lparam)       -- w:ptr l:int
#       SendMessagePP(..., LPVOID wparam, LPVOID lparam)    -- w:ptr l:ptr
#   I bet if I did something like that

    printf STDERR "%.15f\n", nxtafter( 3.14 , 4 );
    printf STDERR "%.15f\n", nxtafter( 3.14 , 3 );

    # tried to use Inline::C to create mySendMessageNN()... while it can see nxtafter(),
    #   for some reason, it refuses to see mySendMessageNN().
    #printf STDERR "mySendMessageNN(): %lx\n", mySendMessageNN( $self->{_hwnd}, 0x0400 + 1000 + 7 , $wparam, $lparam=0 );
    # ahh, Inline::C shows that it only knows int, long, double, char*, void, SV*; if you
    # use anything else (without a typemap file), "If the signature is not recognized,
    #   Inline will simply ignore it, with no complaints. It will not be available from
    #   Perl-space, although it will be available from C-space."
    printf STDERR "sendtest(): %.0lf\n", sendtest( $self->{_hwnd} );
    printf STDERR "sendtest2(): %.0lf\n", sendtest2( $self->{_hwnd}, 0x0400 + 1000 + 7 );
    printf STDERR "sendtest4(): %.0lf\n", sendtest4( $self->{_hwnd}, 0x0400 + 1000 + 7, 0, 2 );
    # these work...
    # TODO = make a wrapper around mySendMessageNP() to properly convert the types
    #   or might want to try my hand at my own typemap... see the system typemap at
    #       ...\perl\lib\ExtUtils\typemap
    #   and the PDL example
    #       ...\perl\vendor\lib\PDL\Core\typemap.pdl
    #   (which shows that it inherits the default T_IV and T_NV, presumably from
    #   the system typemap)

    # 2019-Apr-19: with the notes from above, tried to make a wrapper that didn't include passing the lparam; it crashed NPP when perl ran that.
    #printf STDERR "sendNPtest(): %.0lf\n", sendNPtest($self->{_hwnd} , 0x0400 + 1000 + 5 , 0 );       # handle, msg, wparam; no lparam (yet)
    # since it crashes, comment this out for now.

}

=head1 PythonScript API

    Notepad.activateBufferID(bufferID)
    Activates the given bufferID:

    bufferID = notepad.getCurrentBufferID()
    ...
    notepad.activateBufferID(bufferID)
    Notepad.activateFile(filename)
    Activates the document with the given filename

    Notepad.activateIndex(view, index)
    Activates the document with the given view and index. view is 0 or 1.

    Notepad.callback(function, notifications)
    Registers a callback function for a notification. notifications is a list of messages to call the function for.:

    def my_callback(args):
            console.write("Buffer Activated %d\n" % args["bufferID"]

    notepad.callback(my_callback, [NOTIFICATION.BUFFERACTIVATED])
    The NOTIFICATION enum corresponds to the NPPN_* plugin notifications. The function arguments is a map, and the contents vary dependant on the notification.

    Note that the callback will live on past the life of the script, so you can use this to perform operations whenever a document is opened, saved, changed etc.

    Also note that it is good practice to put the function in another module (file), and then import that module in the script that calls notepad.callback(). This way you can unregister the callback easily.

    For Scintilla notifications, see editor.callback()

    Returns:
    True if the registration was successful
    Notepad.clearCallbacks()
    Unregisters all callbacks

    Notepad.clearCallbacks(function)
    Unregisters all callbacks for the given function. Note that this uses the actual function object, so if the function has been redefined since it was registered, this will fail. If this has happened, use one of the other clearCallbacks() functions.

    Notepad.clearCallbacks(eventsList)
    Unregisters all callbacks for the given list of events.:

    notepad.clearCallbacks([NOTIFICATION.BUFFERACTIVATED, NOTIFICATION.FILESAVED])
    See NOTIFICATION

    Notepad.clearCallbacks(function, eventsList)
    Unregisters the callback for the given callback function for the list of events.

    Notepad.close()
    Closes the currently active document

    Notepad.closeAll()
    Closes all open documents

    Notepad.closeAllButCurrent()
    Closes all but the currently active document

    Notepad.createScintilla()
    Create a new Scintilla handle. Returns an Editor object

    Notepad.destroyScintilla(editor)
    Destroy a Scintilla handle created with createScintilla

    Notepad.getCommandLine()
    Gets the command line used to start Notepad++

    Notepad.getCurrentBufferID()
    Gets the bufferID of the currently active buffer

    Notepad.getCurrentDocIndex(view)
    Gets the current active index for the given view (0 or 1)

    Notepad.getCurrentFilename()
    Gets the filename of the active document

    Notepad.getCurrentLang()
    Get the current language type

    Returns:
    LANGTYPE
    Notepad.getCurrentView()
    Get the currently active view (0 or 1)

    Notepad.getEncoding([bufferID]) → BUFFERENCODING
    Gets the encoding of the given bufferID. If no bufferID is given, then the encoding of the currently active buffer is returned.

    Returns:
    BUFFERENCODING
    Notepad.getFiles()
    Gets a list of the open filenames.

    Returns:
    A list of tuples containing (filename, bufferID, index, view)
    Notepad.getFormatType([bufferID]) → FORMATTYPE
    Gets the format type (i.e. Windows, Unix or Mac) of the given bufferID. If no bufferID is given, then the format of the currently active buffer is returned.

    Returns:
    FORMATTYPE
    Notepad.getLangType([bufferID]) → LANGTYPE
    Gets the language type of the given bufferID. If no bufferID is given, then the language of the currently active buffer is returned.

    Returns:
    LANGTYPE
    Notepad.getNppDir() → str
    Gets the directory Notepad++ is running in (i.e. the location of notepad++.exe)

    Notepad.getPluginConfigDir() → str
    Gets the plugin config directory.

    Notepad.getPluginMenuHandle() → int
    Gets the handle for the Plugins menu.

    Notepad.getVersion() → tuple
    Gets the Notepad++ version as a tuple - e.g. 5.6.8 becomes (5,6,8)

    Notepad.getPluginVersion() → str
    Gets the PythonScript plugin version as a string. There is always four parts to it. e.g. ‘0.9.2.0’

    Notepad.hideTabBar()
    Hides the Tab bar

    Notepad.menuCommand(menuCommand)
    Runs a Notepad++ menu command. Use the MENUCOMMAND enum, or integers directly from the nativeLang.xml file.

    Notepad.messageBox(message[, title[, flags]]) → MessageBoxFlags
    Displays a message box with the given message and title.

    Flags can be 0 for a standard ‘OK’ message box, or a combination of MESSAGEBOXFLAGS. title is “Python Script for Notepad++” by default, and flags is 0 by default.

    Returns:
    A RESULTxxxx member of MESSAGEBOXFLAGS as to which button was pressed.
    Notepad.new()
    Create a new document.

    Notepad.open(filename)
    Opens the given file.

    Notepad.prompt(prompt, title[, defaultText]) → str
    Prompts the user for some text. Optionally provide the default text to initialise the entry field.

    Returns:
    The string entered.

    None if cancel was pressed (note that is different to an empty string, which means that no input was given)
    Notepad.reloadBuffer(bufferID)
    Reloads the given bufferID

    Notepad.reloadCurrentDocument()
    Reloads the current document

    Notepad.reloadFile(filename)
    Reloads a filename.

    Notepad.runMenuCommand(menuName, menuOption[, refreshCache]) → bool
    Runs a command from the menus. For built-in menus use notepad.menuCommand(), for non built-in menus (e.g. TextFX and macros you’ve defined), use notepad.runMenuCommand(menuName, menuOption). For other plugin commands (in the plugin menu), use Notepad.runPluginCommand(pluginName, menuOption)_

    Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runMenuCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

    Returns:
    True if the menu command was found, otherwise False
    e.g.:

    notepad.runMenuCommand('TextFX Edit', 'Delete Blank Lines')
    Notepad.runPluginCommand(pluginName, menuOption[, refreshCache])
    Runs a command from the plugin menu. Use to run direct commands from the Plugins menu. To call TextFX or other menu functions, either use notepad.menuCommand(menuCommand)_ (for Notepad++ menu commands), or notepad.runMenuCommand(menuName, menuOption)_ for TextFX or non standard menus (such as macro names).

    Note that menuOption can be a submenu in a plugin’s menu. So:

    notepad.runPluginCommand('Python Script', 'demo script')
    Could run a script called “demo script” from the Scripts submenu of Python Script.

    Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runPluginCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

    e.g.::
    notepad.runPluginCommand(‘XML Tools’, ‘Pretty Print (XML only)’)
    Notepad.save()
    Save the current file

    Notepad.saveAllFiles()
    Saves all currently unsaved files

    Notepad.saveAs(filename)
    Save the current file as the specified filename

    Only works in Notepad++ 5.7 onwards

    Notepad.saveAsCopy(filename)
    Save the current file as the specified filename, but don’t change the filename for the buffer in Notepad++

    Only works in Notepad++ 5.7 onwards

    Notepad.saveCurrentSession(filename)
    Save the current session (list of open files) to a file.

    Notepad.saveSession(filename, filesList)
    Saves a session file with the list of filenames.

    Notepad.setCurrentLang(langType)
    Set the language type of the currently active buffer (see LANGTYPE)

    Notepad.setFormatType(formatType[, bufferID])
    Sets the format type (i.e. Windows, Unix or Mac) of the specified buffer ID. If not bufferID is passed, then the format type of the currently active buffer is set.

    Notepad.setLangType(langType[, bufferID])
    Sets the language type of the given bufferID. If not bufferID is given, sets the language for the currently active buffer.

    Notepad.setStatusBar(statusBarSection, text)
    Sets the status bar text. For statusBarSection, use one of the STATUSBARSECTION constants.

    Notepad.showTabBar()
    Shows the Tab bar


=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>


=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2018 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
