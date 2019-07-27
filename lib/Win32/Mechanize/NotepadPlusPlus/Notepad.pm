package Win32::Mechanize::NotepadPlusPlus::Notepad;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use IPC::Open2;
use Carp;
use Win32::API;
use Win32::GuiTest ':FUNC';
use Win32::Mechanize::NotepadPlusPlus::__hwnd;
use Win32::Mechanize::NotepadPlusPlus::Editor;

use Data::Dumper; $Data::Dumper::Useqq++;

    BEGIN {
        Win32::API::->Import("user32","DWORD GetWindowThreadProcessId( HWND hWnd, LPDWORD lpdwProcessId)") or die "GetWindowThreadProcessId: $^E";
        # http://www.perlmonks.org/?node_id=806573 shows how to import the GetWindowThreadProcessId(), and it's reply shows how to pack/unpack the arguments to extract appropriate PID

        Win32::API::->Import("kernel32","HMODULE GetModuleHandle(LPCTSTR lpModuleName)") or die "GetModuleHandle: $^E";
        my $hModule = GetModuleHandle("kernel32.dll") or die "GetModuleHandle: $! ($^E)";
        #print "handle(kernel32.dll) = '$hModule'\n";

        Win32::API::->Import("kernel32","BOOL WINAPI GetModuleHandleEx(DWORD dwFlags, LPCTSTR lpModuleName, HMODULE *phModule)") or die "GetModuleHandleEx: $^E";

        Win32::API::->Import("kernel32","HANDLE WINAPI OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId)") or die "OpenProcess: $! ($^E)";

        Win32::API::->Import("kernel32","DWORD GetModuleFileName(HMODULE hModule, LPTSTR lpFilename, DWORD nSize)") or die "GetModuleFileName: $^E";
        Win32::API::->Import("psapi","DWORD WINAPI GetModuleFileNameEx(HANDLE  hProcess, HMODULE hModule, LPTSTR  lpFilename, DWORD   nSize)") or die "GetModuleFileNameEx: $^E";
    }

our $VERSION = '0.000001';  # TODO = make this automatically the same version as NotepadPlusPlus.pm # idea from [id://1209488] = sub VERSION { shift->SUPER::VERSION(@_) || '0.000000_000' }

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
        #carp sprintf "%-15.15s %-15.15s %-39.39s %-59.59s %-15.15s\n",
        #            "launchPid:".$launchPid,
        #            "h:$hwnd",
        #            'c:'.Win32::GuiTest::GetClassName($hwnd),
        #            't:'.Win32::GuiTest::GetWindowText($hwnd),
        #            'extractPid:'.$extractPid,
        #        ;
        $self->{_pid} = $extractPid;
    }
    $self->{_hwobj} = Win32::Mechanize::NotepadPlusPlus::__hwnd->new( $self->{_hwnd} ); # create an object

    # instantiate the two view-scintilla Editors from the first two Scintilla HWND children of the Editor HWND.
    my @sci_hwnds = @{$self->enumScintillaHwnds()}[0..1];       # first two are the main editors
    @{$self}{qw/editor1 editor2/} = map Win32::Mechanize::NotepadPlusPlus::Editor->new($_, $self->{_hwobj}), @sci_hwnds;

    return $self;
}

sub notepad { my $self = shift; $self }
sub console { my $self = shift; $self->{console} }      # TODO: probably not used
sub editor1 { my $self = shift; $self->{editor1} }
sub editor2 { my $self = shift; $self->{editor2} }
use constant NPPM_GETCURRENTSCINTILLA => (0x400 + 1000 + 4);    # TODO: replace this line with message-module constant
sub editor  {
    # choose either editor1 or editor2, depending on which is active
    my $self = shift;
    $self->editor1 and $self->editor2 or croak "default editor object not initialized";
    my $view = $self->{_hwobj}->SendMessage_get32u( NPPM_GETCURRENTSCINTILLA , 0 );
    return $self->{editor1} if 0 == $view;
    return $self->{editor2} if 1 == $view;
    croak "Notepad->editor(): unknown GETCURRENTSCIINTILLA=$view";
}

sub enumScintillaHwnds
{
    my $self = shift;
    my @hwnds = FindWindowLike($self->{_hwnd}, undef, '^Scintilla$', undef, 2); # this will find all Scintilla-class windows that are direct children of the Notepad++ window
    return [@hwnds];
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
=cut
use constant WM_USER => 0x400;                      # https://msdn.microsoft.com/en-us/library/windows/desktop/ms644931(v=vs.85).aspx
use constant NPPMSG => WM_USER + 1000;
use constant NPPM_SAVECURRENTFILE => NPPMSG + 38;
use constant NPPM_GETNBOPENFILES => NPPMSG + 7;         # args(0, nbType)
    use constant ALL_OPEN_FILES => 0;
    use constant PRIMARY_VIEW => 1;
    use constant SECOND_VIEW => 2;
use constant NPPM_GETCURRENTLANGTYPE => NPPMSG + 5;     # args(0, out int *)
use constant NPPM_GETLANGUAGENAME => NPPMSG + 83;       # args(int LangType, out char*)
use constant NPPM_GETLANGUAGEDESC => NPPMSG + 84;       # args(int LangType, out char*)
use constant NPPM_GETCURRENTVIEW => NPPMSG + 88;        # args(0,0)
use constant NPPM_GETOPENFILENAMESPRIMARY => (NPPMSG + 17); # args( out char**, in integer count) # where count comes from NPPM_GETNBOPENFILES
use constant NPPM_GETOPENFILENAMESSECOND => (NPPMSG + 18);  # args( out char**, in integer count) # where count comes from NPPM_GETNBOPENFILES
use constant NPPM_GETBUFFERIDFROMPOS => (NPPMSG + 59);
# TODO 2019-Jul-23: in the process of creating __npp_msgs.pm, so I don't have to manually do this...

# https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L278
sub getFiles {
    my $self = shift;
    my $hwo = $self->{_hwobj};
    foreach my $nbType (0..2) {
        my $count = $hwo->SendMessage(NPPM_GETNBOPENFILES, 0, $nbType);
        carp "getFiles(): nbType#$nbType has $count files open";
    }
    foreach my $view (0,1) {
        my $nbType = (PRIMARY_VIEW, SECOND_VIEW)[$view];
        my $count = $hwo->SendMessage(NPPM_GETNBOPENFILES, 0, $nbType );
        carp "getFiles(): view#$view has $count files open";

        # create an array of allocated buffers
        my @str_alloc;
        for my $si ( 0 .. $count-1 ) {
            $str_alloc[$si] = AllocateVirtualBuffer( $hwo->hwnd, 1024 );
            WriteToVirtualBuffer( $str_alloc[$si] , "1"x1024 );
        }
use Data::Dumper; $Data::Dumper::Useqq++;
print STDERR "str_alloc = ", Dumper(\@str_alloc);

my @ptrs = (); push @ptrs, sprintf('ptr:%s', $_->{ptr}) for @str_alloc;
local $" = ", ";
print STDERR "ptrs = (@ptrs)\n";

        # pack the N string pointers into one string
        my $pack_n = pack 'L!*', map { $_->{ptr} } @str_alloc;
print STDERR "pack_n = ", Dumper $pack_n;

        # create a buffer to hold the N string pointers
        my $nstr_buf = AllocateVirtualBuffer( $hwo->hwnd, 4*@str_alloc );  # four bytes for each 32-bit pointer

        # populate the nstr_buf with pack_n
        WriteToVirtualBuffer( $nstr_buf , $pack_n );

        # send the message
        my $ret = $hwo->SendMessage( NPPM_GETOPENFILENAMESPRIMARY + $view, $nstr_buf->{ptr}, $count );
print STDERR "SendMessage ret = $ret -- I expect it to match $count\n";

        # grab the strings
        foreach my $buf ( @str_alloc ) {
            my $r = ReadFromVirtualBuffer( $buf , 1024 );
            print STDERR "buf($buf) = '", Dumper($r), "'\n";
        }

        # cleanup when done
        FreeVirtualBuffer( $_ ) foreach $nstr_buf, @str_alloc;

# TODO = it's reading back all zeros, and I don't know why.
# I'm not sure I've got the pointer-to-a-pointer right
# if I pre-fill with 1s, it reads back those 1s... so at least that portion is correct.
#   IDEA: maybe after a safety commit, I can try to rework by making one contiguous memory block that's n*1024 long,
#       then after it's created the first pointer, manually set the other pointers to BASE+i*1024

# ooh, I had a thought... maybe wparam is longer (more bits) than an lparam

# actually, for now, continue:
        # get buffer id for each position
        foreach my $pos ( 0 .. $count-1 ) {
            my $bufferID = $hwo->SendMessage( NPPM_GETBUFFERIDFROMPOS , $pos, $view );
            print STDERR "id#$pos = $bufferID\n";
        }

    } # end view loop
}

=begin


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
