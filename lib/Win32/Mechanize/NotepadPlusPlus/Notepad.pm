package Win32::Mechanize::NotepadPlusPlus::Notepad;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use IPC::Open2;
use Carp qw/croak carp cluck confess/;
use Config;
use Win32::API;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';     # 1.64 required for 64-bit SendMessage
use Win32::Mechanize::NotepadPlusPlus::__hwnd;
use Win32::Mechanize::NotepadPlusPlus::__npp_msgs;  # exports %nppm, which contains the messages used by the Notepad++ GUI
use Win32::Mechanize::NotepadPlusPlus::__npp_idm;   # exports %nppidm, which contains the Notepad++ GUI menu-command IDs
use Win32::Mechanize::NotepadPlusPlus::Editor;

use Data::Dumper; $Data::Dumper::Useqq++;

    BEGIN {
        Win32::API::->Import("user32","DWORD GetWindowThreadProcessId( HWND hWnd, LPDWORD lpdwProcessId)") or die "GetWindowThreadProcessId: $^E";  # uncoverable branch true
        # http://www.perlmonks.org/?node_id=806573 shows how to import the GetWindowThreadProcessId(), and it's reply shows how to pack/unpack the arguments to extract appropriate PID

        Win32::API::->Import("kernel32","HMODULE GetModuleHandle(LPCTSTR lpModuleName)") or die "GetModuleHandle: $^E";  # uncoverable branch true
        my $hModule = GetModuleHandle("kernel32.dll") or die "GetModuleHandle: $! ($^E)";  # uncoverable branch true
        #print "handle(kernel32.dll) = '$hModule'\n";

        Win32::API::->Import("kernel32","BOOL WINAPI GetModuleHandleEx(DWORD dwFlags, LPCTSTR lpModuleName, HMODULE *phModule)") or die "GetModuleHandleEx: $^E";  # uncoverable branch true

        Win32::API::->Import("kernel32","HANDLE WINAPI OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId)") or die "OpenProcess: $! ($^E)";  # uncoverable branch true

        Win32::API::->Import("kernel32","DWORD GetModuleFileName(HMODULE hModule, LPTSTR lpFilename, DWORD nSize)") or die "GetModuleFileName: $^E";  # uncoverable branch true
        Win32::API::->Import("psapi","DWORD WINAPI GetModuleFileNameEx(HANDLE  hProcess, HMODULE hModule, LPTSTR  lpFilename, DWORD   nSize)") or die "GetModuleFileNameEx: $^E";  # uncoverable branch true
    }

our $VERSION = '0.000001'; # auto-populated from W::M::NPP

=encoding utf8

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

=head1 Constructors

The Constructors and similar object methods in this section are purely for class access, and will be called by the NotepadPlusPlus
object.  They should never need to be referenced directly.
(Instead, you will get the notepad, editor1, editor2, and editor instances from the app instance)

=over

=item * new

=item * notepad

=item * editor1

=item * editor2

=item * editor

    use Win32::Mechanize::NotepadPlusPlus;                      # calls Win32::Mechanize::NotepadPlusPlus::Notepad::new()
    my $npp = Win32::Mechanize::NotepadPlusPlus::notepad();     # calls ...Notepad::notepad()
    my $ed1 = Win32::Mechanize::NotepadPlusPlus::editor1();     # calls ...Notepad::editor1()
    my $ed2 = Win32::Mechanize::NotepadPlusPlus::editor2();     # calls ...Notepad::editor2()
    my $ed  = Win32::Mechanize::NotepadPlusPlus::editor();      # calls ...Notepad::editor()

=for comment
The _enumScintillaHwnds is considered private by Pod::Coverage, because it starts with underscore.
TODO = consider making all of these private by renaming them.  Need to think about whether or not
an end user would ever create an instance of the Notepad object that doesn't also have the parent
app object.  I think it's probably safe, but will continue to think about it.

=back

=cut

sub new
{
    my ($class, @args) = @_;
    my $self = bless {
        _exe => $npp_exe,
        _pid => undef,
        _hwnd => undef,
        editor1 => undef,
        editor2 => undef,
    }, $class;

    # start the process:
    my $launchPid = open2(my $npo, my $npi, $npp_exe);  # qw/notepad++ -multiInst -noPlugin/, $fname)
    $self->{_hwnd} = WaitWindowLike( 0, undef, '^Notepad\+\+$', undef, undef, 5 ) # wait up to 5sec
        or croak "could not open the Notepad++ application";  # uncoverable branch true
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
    my @sci_hwnds = @{$self->_enumScintillaHwnds()}[0..1];       # first two are the main editors
    @{$self}{qw/editor1 editor2/} = map Win32::Mechanize::NotepadPlusPlus::Editor->new($_, $self->{_hwobj}), @sci_hwnds;

    return $self;
}

sub notepad { my $self = shift; $self }
sub editor1 { my $self = shift; $self->{editor1} }
sub editor2 { my $self = shift; $self->{editor2} }
sub editor  {
    # choose either editor1 or editor2, depending on which is active
    my $self = shift;
    $self->editor1 and $self->editor2 or croak "default editor object not initialized";
    my $view = $self->getCurrentView();
    return $self->{editor1} if 0 == $view;
    return $self->{editor2} if 1 == $view;
    croak "Notepad->editor(): unknown GETCURRENTSCIINTILLA=$view";
}

sub _enumScintillaHwnds
{
    my $self = shift;
    my @hwnds = FindWindowLike($self->{_hwnd}, undef, '^Scintilla$', undef, 2); # this will find all Scintilla-class windows that are direct children of the Notepad++ window
    return [@hwnds];
}

=head1 API

This API was based on the Notepad++ plugin PythonScript's API for the Notepad object.

=cut

=head2 Files

These methods open, close, and save files (standard File menu operations).

=over

=item notepad()-E<gt>close()

Closes the currently active document

=cut

sub close {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_FILE_CLOSE} );
}

=item notepad()-E<gt>closeAll()

Closes all open documents

=cut

sub closeAll {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_FILE_CLOSEALL} );
}

=item notepad()-E<gt>closeAllButCurrent()

Closes all but the currently active document

=cut

sub closeAllButCurrent {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_FILE_CLOSEALL_BUT_CURRENT} );
}

=item notepad()-E<gt>newFile()

Create a new document.

=cut

sub newFile {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_FILE_NEW} );
}

=item notepad()-E<gt>open(filename)

Opens the given file.

=cut

sub open {
    my $self = shift;
    my $fileName = shift;
    croak "->open() method requires \$fileName argument" unless defined $fileName;

    my $ret = '<undef>';
    eval {
        $ret = $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_DOOPEN} , 0, $fileName);
        1;
    } or do {
        croak sprintf "->open('%s') died with msg:'%s'", $fileName, $@;
    };
    return $ret;
}

=item notepad()-E<gt>save()

Save the current file

=cut

sub save {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_SAVECURRENTFILE} , 0 , 0 );
}

=item notepad()-E<gt>saveAllFiles()

Saves all currently unsaved files

=cut

sub saveAllFiles {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_SAVEALLFILES} , 0 , 0 );
}

=item notepad()-E<gt>saveAs($filename)

Save the current file as the specified $filename

=cut

sub saveAs {
    my $self = shift;
    my $filename = shift;
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SAVECURRENTFILEAS} , 0 , $filename );
}

=item notepad()-E<gt>saveAsCopy($filename)

Save the current file as the specified $filename, but don’t change the filename for the buffer in Notepad++

=cut

sub saveAsCopy {
    my $self = shift;
    my $filename = shift;
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SAVECURRENTFILEAS} , 1 , $filename );
}

=back

=head3 Sessions

Sessions allow you to make a group of files that you can easily reload by loading the session.

=over

=item notepad()-E<gt>saveCurrentSession($filename)

Save the current session (list of open files) to a file.

=cut

sub saveCurrentSession {
    my $self = shift;
    my $fname = shift;
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SAVECURRENTSESSION}, 0 , $fname );
}

=item notepad()-E<gt>saveSession($filename, @filesList)

Saves a session (list of filenames in @filesList) to a file.

=cut

sub saveSession {
    my $self = shift;
    my $sessionFile = shift;
    my @fileList = @_;
    my $nFiles = scalar @fileList;

    my $hwnd = $self->{_hwnd};
    my $wparam = 0; # lparam below

    # NPPM_SAVESESSION

    #   TCHAR* sessionFilePathName;
    #       the full path name of session file to save
    #   int nbFile;
    #       the number of files in the session
    #   TCHAR** files;
    #       files' full path

    # memory for the $nFiles pointers, and the $nFiles strings that go into those pointers
    my $tcharpp = AllocateVirtualBuffer( $hwnd, $nFiles*$Config{ptrsize} ); #allocate 8-bytes per file for the pointer to each buffer (or 4bytes on 32bit perl)
    my @strBufs;
    for my $i ( 0 .. $#fileList ) {
        # allocate and populate each filename and buffer
        my $filename_ucs2le = Encode::encode( 'ucs2-le', $fileList[$i]);
        $strBufs[$i] = AllocateVirtualBuffer( $hwnd, length($filename_ucs2le) );
        WriteToVirtualBuffer( $strBufs[$i], $filename_ucs2le );
    }
    my @strPtrs = map { $_->{ptr} } @strBufs;   # want an array of pointers
    my $pk = $Config{ptrsize}==8 ? 'Q' : 'L';     # L is 32bit, so maybe I need to pick L or Q depending on ptrsize?
    my $tcharpp_val = pack $pk."*", @strPtrs;
    WriteToVirtualBuffer( $tcharpp , $tcharpp_val );

    # memory for the sessionFilePathName
    my $ucs2le = Encode::encode('ucs2-le', $sessionFile);
    my $sessionFilePathName = AllocateVirtualBuffer( $hwnd, length($ucs2le) );
    WriteToVirtualBuffer( $sessionFilePathName, $ucs2le );

    # memory for structure
    my $structure = AllocateVirtualBuffer( $hwnd , $Config{ptrsize} * 3 );
    my $struct_val = pack "$pk $pk $pk", $sessionFilePathName->{ptr}, $nFiles, $tcharpp->{ptr};
    WriteToVirtualBuffer( $structure, $struct_val );
    my $lparam = $structure->{ptr};

    # send the message
    my $ret = $self->SendMessage( $nppm{NPPM_SAVESESSION}, $wparam, $lparam );
    # warn sprintf "saveSession(): SendMessage(NPPM_SAVESESSION, 0x%016x, l:0x%016x): ret = %d", $wparam, $lparam, $ret;

    # free virtual memories
    FreeVirtualBuffer($_) for $structure, $sessionFilePathName, @strBufs;

    return $ret;
}

=item notepad()-E<gt>loadSession($sessionFilename)

Opens the session by loading all the files listed in the $sessionFilename.

=cut

sub loadSession {
    my $self = shift;
    my $fname = shift;
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_LOADSESSION}, 0 , $fname );
}

=item notepad()-E<gt>getSessionFiles($sessionFilename)

Reads the session stored in $sessionFilename, and returns a list of the file paths that it references.

This does not open the files in the session; to do that, use C<notepad()-E<gt>loadSession($sessionFilename)>

=cut

sub getSessionFiles {
    my $self = shift;
    my $sessionFile = shift;
    my $hwnd = $self->{_hwnd};

    # first determine how many files are involved
    my $nFiles = $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_GETNBSESSIONFILES}, 0, $sessionFile );
    # warn sprintf "getSessionFiles(%s): msg{NPPM_GETNBSESSIONFILES} => nFiles = %d\n", $sessionFile, $nFiles;

    #   wParam:     [out] TCHAR ** sessionFileArray
    #   lParam:     [in]const TCHAR * sessionFilePathName

    # memory for the $nFiles pointers, and the $nFiles strings that go into those pointers
    my $tcharpp = AllocateVirtualBuffer( $hwnd, $nFiles*$Config{ptrsize} ); #allocate 8-bytes per file for the pointer to each buffer (or 4bytes on 32bit perl)
    my @strBufs = map { AllocateVirtualBuffer( $hwnd, 1024 ) } 1 .. $nFiles;
    my @strPtrs = map { $_->{ptr} } @strBufs;   # want an array of pointers
    my $pk = $Config{ptrsize}==8 ? 'Q' : 'L';     # L is 32bit, so maybe I need to pick L or Q depending on ptrsize?
    my $tcharpp_val = pack $pk."*", @strPtrs;
    WriteToVirtualBuffer( $tcharpp , $tcharpp_val );
    my $wparam = $tcharpp->{ptr};

    # memory for the sessionFilePathName
    my $ucs2le = Encode::encode('ucs2-le', $sessionFile);
    my $sessionFilePathName = AllocateVirtualBuffer( $hwnd, length($ucs2le) );
    WriteToVirtualBuffer( $sessionFilePathName, $ucs2le );
    my $lparam = $sessionFilePathName->{ptr};

    # send the message
    my $ret = $self->SendMessage( $nppm{NPPM_GETSESSIONFILES}, $wparam, $lparam );
    # warn sprintf "getSessionFiles(): SendMessage(NPPM_GETSESSIONFILES, 0x%016x, l:0x%016x): ret = %d", $wparam, $lparam, $ret;

    # read the filenames
    my @filenameList;
    for my $bufidx ( 0 .. $#strBufs ) {
        my $text_buf = $strBufs[$bufidx];
        my $fname = Encode::decode('ucs2-le', ReadFromVirtualBuffer( $text_buf , 1024 ) );
        $fname =~ s/\0*$//;
        # warn sprintf "getSessionFiles(): #%d = \"%s\"\n", $bufidx, $fname;
        push @filenameList, $fname;
    }

    # free virtual memories
    FreeVirtualBuffer($_) for $sessionFilePathName, @strBufs;

    return @filenameList;
}

=back

=for comment /end of Files

=head2 Buffers and Views

These methods influence which views are available and which file buffers are available in which views;
they also read or manipulate the information about the files in these buffers.

Views relate to the one or two editor windows inside Notepad++.
Buffers are the individual file-editing buffers in each view.
Because each view has a group of buffers, each buffer has an index within that view.

=cut

=head3 Get/Change Active Buffers

These methods allow you to change which file buffer is active in a given view,
and get information about which view and buffer are active.

=over

=item notepad()-E<gt>activateBufferID($bufferID)

Activates the given $bufferID

=cut

sub activateBufferID {
    my $self = shift;
    my $bufid = shift // croak "->activateBufferID(\$bufferID): \$bufferID required";
    my $index = $self->SendMessage( $nppm{NPPM_GETPOSFROMBUFFERID} , $bufid , 0 );
    my $view = ($index & 0xC0000000) >> 30; # upper bit is view
    $index &= 0x3FFFFFFF;
    return $self->SendMessage( $nppm{NPPM_ACTIVATEDOC} , $view , $index );
}

=item notepad()-E<gt>activateFile($filename)

Activates the buffer with the given $filename, regardless of view.

=cut

sub activateFile {
    my $self = shift;
    my $fileName = shift // croak "->activateFile(\$filename): \$filename required";
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SWITCHTOFILE} , 0, $fileName);
}

=item notepad()-E<gt>activateIndex($view, $index)

Activates the document with the given $view and $index. view is 0 or 1.

=cut

sub activateIndex {
    my $self = shift;
    my ($view, $index) = @_;
    croak "->activateIndex(): view must be defined" unless defined $view;
    croak "->activateIndex(): index must be defined" unless defined $index;
    return $self->SendMessage( $nppm{NPPM_ACTIVATEDOC} , $view , $index );
}

=item notepad()-E<gt>getCurrentBufferID()

Gets the bufferID of the currently active buffer

=cut

sub getCurrentBufferID {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_GETCURRENTBUFFERID} , 0 , 0 );
}

=item notepad()-E<gt>getCurrentDocIndex($view)

Gets the current active index for the given $view (0 or 1)

=cut

sub getCurrentDocIndex {
#msgs indicate it might need MAIN_VIEW or SUB_VIEW arguemnt
    my $self = shift;
    my $view = shift; croak "->getCurrentDocIndex(\$view) requires a view of \$nppm{MAIN_VIEW} or \$nppm{SUB_VIEW}" unless defined $view;
    return $self->SendMessage( $nppm{NPPM_GETCURRENTDOCINDEX} , 0 , 0 );
}

=item notepad()-E<gt>getCurrentView()

=item notepad()-E<gt>getCurrentScintilla()

Get the currently active view (0 or 1)

=cut

sub getCurrentView {
    my $self = shift;
    return my $view = $self->SendMessage( $nppm{NPPM_GETCURRENTVIEW} , 0 , 0 );
}

sub getCurrentScintilla {
    my $self = shift;
    return my $scint = $self->{_hwobj}->SendMessage_get32u( $nppm{NPPM_GETCURRENTSCINTILLA} , 0 );
}

=item notepad()-E<gt>moveCurrentToOtherView()

Moves the active file from one view to another

=cut

# pythonscript doesn't have it, but for my test suite, I want access to IDM_VIEW_GOTO_ANOTHER_VIEW
sub moveCurrentToOtherView {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_VIEW_GOTO_ANOTHER_VIEW} );
}

=item notepad()-E<gt>cloneCurrentToOtherView()

Clones the active file from one view to the other, so it's now available in both views
(which makes it easy to look at different sections of the same file)

=cut

# pythonscript doesn't have it, but for my test suite, I want access to IDM_VIEW_GOTO_ANOTHER_VIEW
sub cloneCurrentToOtherView {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $nppidm{IDM_VIEW_CLONE_TO_ANOTHER_VIEW} );
}

=back

=head3 Get Filename Information

These methods allow you to get the filename for a selected or active buffer,
or get the list of all currently-open files.

=over

=item notepad()-E<gt>getBufferFilename( $bufferid )

=item notepad()-E<gt>getBufferFilename( )

Gets the filename of the selected buffer.

If $bufferid is omitted, it will get the filename of the active document

=cut

sub getBufferFilename {
    my $self = shift;
    my $bufid = shift || $self->getCurrentBufferID();   # optional argument: default to  NPPM_GETCURRENTBUFFERID
    return $self->{_hwobj}->SendMessage_getUcs2le( $nppm{NPPM_GETFULLPATHFROMBUFFERID} , int($bufid) , { trim => 'retval' } );
}

=item notepad()-E<gt>getCurrentFilename()

Gets the filename of the active document

=cut

sub getCurrentFilename {
    return $_[0]->getBufferFilename();
}

=item notepad()-E<gt>getFiles()

Gets a list of the open filenames.

Returns:
A reference to an array-of-arrays, one row for each file, with filename, bufferID, index, and view as the elements of each row:

C<[ [$filename1, $bufferID1, $index1, $view1], ... [$filenameN, $bufferIDN, $indexN, $viewN] ]>

=cut

# 2019-Sep-23: vr of perlmonks [found the problem](https://perlmonks.org/?node_id=11106581):
#   need to pass SendMessage(hwnd, NPPM_GETOPENFILENAMESPRIMARY, ->{ptr}, $nFiles)
sub getFiles {
    my $self = shift;
    my $hwo = $self->{_hwobj};
    my $hwnd = $hwo->hwnd;
    my @tuples = ();

    foreach my $view (0,1) {
        my $msg = ($nppm{NPPM_GETOPENFILENAMESPRIMARY}, $nppm{NPPM_GETOPENFILENAMESSECOND})[$view];
        my $nbType = ($nppm{PRIMARY_VIEW}, $nppm{SECOND_VIEW})[$view];
        my $nFiles = $hwo->SendMessage($nppm{NPPM_GETNBOPENFILES}, 0, $nbType );

        # allocate remote memory for the n pointers, 8 bytes per pointer
        my $tcharpp = AllocateVirtualBuffer( $hwnd, $nFiles*$Config{ptrsize} ); #allocate 8-bytes per file for the pointer to each buffer (or 4bytes on 32bit perl)

        # allocate remote memory for the strings, each 1024 bytes long
        my @strBufs = map { AllocateVirtualBuffer( $hwnd, 1024 ) } 1 .. $nFiles;

        # grab the pointers
        my @strPtrs = map { $_->{ptr} } @strBufs;

        # pack them into a string for writing into the virtual buffer
        my $pk = $Config{ptrsize}==8 ? 'Q*' : 'L*';     # L is 32bit, so maybe I need to pick L or Q depending on ptrsize?
        my $tcharpp_val = pack $pk, @strPtrs;

        # load the pointers into the tcharpp
        WriteToVirtualBuffer( $tcharpp , $tcharpp_val );

        # send the message
        #   https://web.archive.org/web/20190325050754/http://docs.notepad-plus-plus.org/index.php/Messages_And_Notifications
        #   wParam = [out] TCHAR ** fileNames
        #   lParam = [in] int nbFile
        my $ret = $hwo->SendMessage( $msg, $tcharpp->{ptr}, $nFiles );

        # grab the strings
        for my $bufidx ( 0 .. $#strBufs ) {
            my $text_buf = $strBufs[$bufidx];
            my $fname = Encode::decode('ucs2-le', ReadFromVirtualBuffer( $text_buf , 1024 ) );
            $fname =~ s/\0*$//;

            # get buffer id for each position
            my $bufferID = $hwo->SendMessage( $nppm{NPPM_GETBUFFERIDFROMPOS} , $bufidx, $view );

            push @tuples, [$fname, $bufferID, $bufidx, $view];
        }

        # cleanup when done
        FreeVirtualBuffer( $_ ) foreach $tcharpp, @strBufs;
    } # end view loop
    return [@tuples];
}

=item notepad()-E<gt>getNumberOpenFiles($view)

=item notepad()-E<gt>getNumberOpenFiles()

Returns the number of open files in $view, which should be 0 or 1.
If C<undef> or $view not given, return total number of files open in either view.

=cut

sub getNumberOpenFiles {
    my $self = shift;
    my $view = shift // -1;
    croak "->getNumberOpenFiles(\$view = $view): \$view must be 0, 1, or undef" if (0+$view)>1 or (0+$view)<-1;
    my $nbType = ($nppm{PRIMARY_VIEW}, $nppm{SECOND_VIEW}, $nppm{MAIN_VIEW})[$view];
    return $self->SendMessage($nppm{NPPM_GETNBOPENFILES}, 0, $nbType );
}

=back

=head3 Get/Set Language Parser

These methods allow you to determine or change the active language parser for the buffers.

=over

=item notepad()-E<gt>getCurrentLang()

Get the current language type

Returns:
LANGTYPE

=cut

sub getCurrentLang {
    my $self = shift;
    return $self->{_hwobj}->SendMessage_get32u($nppm{NPPM_GETCURRENTLANGTYPE}, 0);
}

=item notepad()-E<gt>getLangType($bufferID)

=item notepad()-E<gt>getLangType()

Gets the language type of the given $bufferID. If no $bufferID is given, then the language of the currently active buffer is returned.

Returns:
An integer that corresponds to

=item TODO: will eventually map those integers to names for the language

=cut

# https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp
sub getLangType {
    my $self = shift;
    my $bufferID = shift;
    return $self->getCurrentLang() unless $bufferID;
    return $self->SendMessage($nppm{NPPM_GETBUFFERLANGTYPE}, $bufferID);
}

=item notepad()-E<gt>setCurrentLang($langType)

Set the language type for the currently-active buffer.

=cut

sub setCurrentLang {
    my $self = shift;
    my $langType = shift;
    return $self->SendMessage($nppm{NPPM_SETCURRENTLANGTYPE}, 0, $langType);
}

=item notepad()-E<gt>setLangType($langType, $bufferID)

=item notepad()-E<gt>setLangType($langType)

Sets the language type of the given bufferID. If not bufferID is given, sets the language for the currently active buffer.

=cut

sub setLangType {
    my $self = shift;
    my $langType = shift;
    my $bufferID = shift;
    return $self->setCurrentLang($langType) unless $bufferID;
    return $self->SendMessage($nppm{NPPM_SETBUFFERLANGTYPE}, $bufferID, $langType);
}

=item notepad()-E<gt>getLanguageName($langType)

=item notepad()-E<gt>getLanguageDesc($langType)

Get the name and or longer description for the given language $langType.

=cut

sub getLanguageName {
    my $self = shift;
    my $langType = shift;
    return $self->{_hwobj}->SendMessage_getUcs2le( $nppm{NPPM_GETLANGUAGENAME}, $langType, { trim => 'retval' } );
}

sub getLanguageDesc {
    my $self = shift;
    my $langType = shift;
    return $self->{_hwobj}->SendMessage_getUcs2le( $nppm{NPPM_GETLANGUAGEDESC}, $langType, { trim => 'retval' } );
}

=back

=head3 Encoding and EOL Information

Determines the encoding for a given file, and determines or changes the EOL-style for the file buffer.

=over

=item notepad()-E<gt>getEncoding($bufferID)

=item notepad()-E<gt>getEncoding()

Gets the encoding of the given bufferID. If no bufferID is given, then the encoding of the currently active buffer is returned.

Returns:
An integer corresponding to how the buffer is encoded

=cut

sub getEncoding {
    my $self = shift;
    my $bufid = shift || $self->getCurrentBufferID();   # optional argument: default to  NPPM_GETCURRENTBUFFERID
    return $self->SendMessage( $nppm{NPPM_GETBUFFERENCODING} , int($bufid) , 0);
}

=item TODO = need to see if there are appropriate messages for setting/changing encoding

=item TODO = need to map encoding to meaningful words

=item notepad()-E<gt>getFormatType($bufferID)

=item notepad()-E<gt>getFormatType()

Gets the EOL format type (i.e. Windows [0], Unix [1] or old Mac EOL [2]) of the given bufferID.
If no bufferID is given, then the format of the currently active buffer is returned.

Returns:
The integers 0,1,or 2, corresponding to Windows EOL (CRLF), Unix/Linux (LF), or the old Mac EOL (CR).

=cut

sub getFormatType {
    my $self = shift;
    my $bufid = shift || $self->getCurrentBufferID();   # optional argument: default to  NPPM_GETCURRENTBUFFERID
    return $self->SendMessage( $nppm{NPPM_GETBUFFERFORMAT}, $bufid);
}

=item notepad()-E<gt>setFormatType($formatType, $bufferID)

=item notepad()-E<gt>setFormatType($formatType)

Sets the EOL format type (i.e. Windows [0], Unix [1] or old Mac EOL [2]) of the specified buffer ID. If not bufferID is passed, then the format type of the currently active buffer is set.

=cut

sub setFormatType {
    my $self = shift;
    my $formatType = shift;
    my $bufid = shift || $self->getCurrentBufferID();   # optional argument: default to  NPPM_GETCURRENTBUFFERID
    return $self->SendMessage( $nppm{NPPM_SETBUFFERFORMAT}, $bufid, $formatType);
}

=back

=head3 Reload Buffers

These methods allow you to reload the contents of the appropriate buffer from what is on disk.

=over

=item notepad()-E<gt>reloadBuffer($bufferID)

Reloads the given $bufferID

=cut

sub reloadBuffer {
    my $self = shift;
    my $bufferID = shift;
    return $self->SendMessage( $nppm{NPPM_RELOADBUFFERID}, $bufferID, 0);
}

=item notepad()-E<gt>reloadCurrentDocument()

Reloads the buffer of the current document

=cut

sub reloadCurrentDocument {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND}, 0, $nppidm{IDM_FILE_RELOAD});
}

=item notepad()-E<gt>reloadFile($filename)

Reloads the buffer for the given $filename

=cut

sub reloadFile {
    my $self = shift;
    my $fileName = shift;
    my $alert = shift ? 1 : 0;

    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_RELOADFILE}, $alert , $fileName);
}

=back

=for comment /end of Buffers and Views

=head2 Hidden Scintilla Instances

When automating Notepad++, there are times when you may want an extra
Scintilla Editor instance, even though it never needs to be seen
inside the Notepad++ window.  You can create and destroy hidden
instances using these methods

=over

=item notepad()-E<gt>createScintilla()

Create a new Scintilla handle. Returns an Editor object.
This Scintilla editor instance is not available to be displayed in either view,
but in all other ways behaves like the main Scintilla Editor instances.

=cut

sub createScintilla {
    my $self = shift;
    # NPPM_CREATESCINTILLAHANDLE
    return undef;
}

=item notepad()-E<gt>destroyScintilla($editor)

Destroy a Scintilla handle created with createScintilla.

B<DO NOT> try to destroy one of the default Scintillas.  B<ONLY> try to destroy a Scintilla instance you created.

=cut

sub destroyScintilla {
    my $self = shift;
    # NPPM_DESTROYSCINTILLAHANDLE
    return undef;
}

=back

=for comment /end of Hidden Scintilla Instances

=head2 GUI Manipulation

=over

=cut

=item notepad()-E<gt>hideMenu()

Hides the menu bar.

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub hideMenu {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDEMENU}, 0, 1);
    # NPPM_HIDEMENU, lParam=1
}

=item notepad()-E<gt>showMenu()

Shows the menu bar

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub showMenu {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDEMENU}, 0, 0);
    # NPPM_HIDEMENU, lParam=0
}

=item notepad()-E<gt>isMenuHidden()

Returns 1 if the menu bar is currently hidden, 0 if it is shown.

=cut

sub isMenuHidden {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_ISMENUHIDDEN}, 0, 0);
    # NPPM_ISMENUHIDDEN
}

=item notepad()-E<gt>hideTabBar()

Hides the Tab bar.

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub hideTabBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDETABBAR}, 0, 1);
    # NPPM_HIDETABBAR, lParam=1
}

=item notepad()-E<gt>showTabBar()

Shows the Tab bar

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub showTabBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDETABBAR}, 0, 0);
    # NPPM_HIDETABBAR, lParam=0
}

=item notepad()-E<gt>isTabBarHidden()

Returns 1 if the tab bar is currently hidden, 0 if it is shown.

=cut

sub isTabBarHidden {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_ISTABBARHIDDEN}, 0, 0);
    # NPPM_ISTABBARHIDDEN
}

=item notepad()-E<gt>hideToolBar()

Hides the toolbar.

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub hideToolBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDETOOLBAR}, 0, 1);
    # NPPM_HIDETOOLBAR, lParam=1
}

=item notepad()-E<gt>showToolBar()

Shows the toolbar

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub showToolBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDETOOLBAR}, 0, 0);
    # NPPM_HIDETOOLBAR, lParam=0
}

=item notepad()-E<gt>isToolBarHidden()

Returns 1 if the toolbar is currently hidden, 0 if it is shown.

=cut

sub isToolBarHidden {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_ISTOOLBARHIDDEN}, 0, 0);
    # NPPM_ISTOOLBARHIDDEN
}

=item notepad()-E<gt>hideStatusBar()

Hides the status bar.

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub hideStatusBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDESTATUSBAR}, 0, 1);
    # NPPM_HIDESTATUSBAR, lParam=1
}

=item notepad()-E<gt>showStatusBar()

Shows the status bar

RETURN:
The previous state: it will return 1 if it was hidden before, or 0 if it was shown before

=cut

sub showStatusBar {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_HIDESTATUSBAR}, 0, 0);
    # NPPM_HIDESTATUSBAR, lParam=0
}

=item notepad()-E<gt>isStatusBarHidden()

Returns 1 if the status bar is currently hidden, 0 if it is shown.

=cut

sub isStatusBarHidden {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_ISSTATUSBARHIDDEN}, 0, 0);
    # NPPM_ISSTATUSBARHIDDEN
}

=item notepad()-E<gt>setStatusBar(statusBarSection, text)

Sets the status bar text. For statusBarSection, use one of the STATUSBARSECTION constants.

=cut

sub setStatusBar {
    my $self = shift;
    my $section = shift;
    my $text = shift;
    $section = $nppm{$section} if exists $nppm{$section};   # allow name or value
    return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SETSTATUSBAR} , $section, $text );
    # NPPM_SETSTATUSBAR
}

=item notepad()-E<gt>getStatusBar(statusBarSection)

Gets the status bar text. For statusBarSection, use one of the STATUSBARSECTION constants.

NOT IMPLEMENTED (there is no Notepad++ Message "NPPM_GETSTATUSBAR").

=cut
# There may be a workaround which could be implemented: for each of the sections, compute the default value...
#   or see dev-zoom-tooltips.py : npp_get_statusbar()

sub getStatusBar {
    my $self = shift;
    my $section = shift;
    $section = $nppm{$section} if exists $nppm{$section};   # allow name or value
    return undef;
    #return $self->{_hwobj}->SendMessage_sendStrAsUcs2le( $nppm{NPPM_SETSTATUSBAR} , $section, $text );
    # NPPM_GETSTATUSBAR -- Does Not Exist!
}

=item notepad()-E<gt>getPluginMenuHandle() → int

Gets the handle for the Plugins menu.

=cut

sub getPluginMenuHandle {
    my $self = shift;
    return $self->SendMessage( $nppm{NPPM_GETMENUHANDLE} , 0, 0);
    # NPPM_GETMENUHANDLE
}

=item notepad()-E<gt>messageBox(message[, title[, flags]]) → MessageBoxFlags

Displays a message box with the given message and title.

    Flags can be 0 for a standard ‘OK’ message box, or a combination of MESSAGEBOXFLAGS. title is “Python Script for Notepad++” by default, and flags is 0 by default.

Returns:
A RESULTxxxx member of MESSAGEBOXFLAGS as to which button was pressed.

=cut

sub messageBox {
    my $self = shift;
    my ($message, $title, $flags) = @_;
    $message = "" unless $message;
    $title = "Win32::Mechanize::NotepadPlusPlus" unless $title;
    $flags = 0 unless $flags;
    return Win32::MsgBox( $message, $flags, $title );
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L698
    # retVal = ::MessageBoxA(m_nppHandle, message, title, flags);
    # => https://metacpan.org/pod/Win32 => for Win32::MsgBox
    return undef;
}



=item notepad()-E<gt>prompt(prompt, title[, defaultText]) → str

Prompts the user for some text. Optionally provide the default text to initialise the entry field.

Returns:
The string entered.

None if cancel was pressed (note that is different to an empty string, which means that no input was given)

=cut

sub prompt {
    my $self = shift;
    my $prompt = shift;
    my $text = shift || '';
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L711

    {
        # => https://www.mail-archive.com/perl-win32-gui-users@lists.sourceforge.net/msg04117.html => may come in handy for ->prompt()
        use Win32::GUI ();
        my $mw = Win32::GUI::DialogBox->new(
                -caption => $prompt,
                -pos => [100,100],
                -size => [300,90],
                -helpbox => 0,
        );

        my $tf = $mw->AddTextfield(
                -pos => [10,10],
                -size => [$mw->ScaleWidth() - 20, 20],
                -tabstop => 1,
                -text => $text,  # default value
        );

        $mw->AddButton(
                -text => 'Ok',
                -ok => 1,
                -default => 1,
                -tabstop => 1,
                -pos => [$mw->ScaleWidth()-156,$mw->ScaleHeight()-30],
                -size => [70,20],
                -onClick => sub { $text = $tf->Text(); return -1; },
        );

        $mw->AddButton(
                -text => 'Cancel',
                -cancel => 1,
                -tabstop => 1,
                -pos => [$mw->ScaleWidth()-80,$mw->ScaleHeight()-30],
                -size => [70,20],
                -onClick => sub { return -1; },
        );

        $mw->Show();
        $tf->SetFocus();
        Win32::GUI::Dialog();
    }
    # possible alternative: https://stackoverflow.com/questions/4201399/prompting-a-user-with-an-input-box-c
    #   => https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-dialogboxparama?redirectedfrom=MSDN


    return $text;
}

=item notepad()-E<gt>menuCommand(menuCommand)

Runs a Notepad++ menu command. Use the MENUCOMMAND enum (C<%nppidm> below), or integers directly from the nativeLang.xml file.

=cut

sub menuCommand {
    my $self = shift;
    my $menuCmdId = shift;
    $menuCmdId = $nppidm{$menuCmdId} if exists $nppidm{$menuCmdId}; # allow named command string, or the actual ID
    return $self->SendMessage( $nppm{NPPM_MENUCOMMAND} , 0 , $menuCmdId );
    # NPPM_MENUCOMMAND
}

=item notepad()-E<gt>runMenuCommand(menuName, menuOption[, refreshCache]) → bool

Runs a command from the menus. For built-in menus use notepad.menuCommand(), for non built-in menus (e.g. TextFX and macros you’ve defined), use notepad.runMenuCommand(menuName, menuOption). For other plugin commands (in the plugin menu), use Notepad.runPluginCommand(pluginName, menuOption)_

Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runMenuCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

Returns:
True if the menu command was found, otherwise False

e.g.:

    notepad.runMenuCommand('TextFX Edit', 'Delete Blank Lines')

=cut

sub runMenuCommand {
    my $self = shift;
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L865
    return undef;
}

=item notepad()-E<gt>runPluginCommand(pluginName, menuOption[, refreshCache])

Runs a command from the plugin menu. Use to run direct commands from the Plugins menu. To call TextFX or other menu functions, either use notepad.menuCommand(menuCommand)_ (for Notepad++ menu commands), or notepad.runMenuCommand(menuName, menuOption)_ for TextFX or non standard menus (such as macro names).

Note that menuOption can be a submenu in a plugin’s menu. So:

    notepad.runPluginCommand('Python Script', 'demo script')

Could run a script called “demo script” from the Scripts submenu of Python Script.

Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runPluginCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

e.g.:

    notepad.runPluginCommand(‘XML Tools’, ‘Pretty Print (XML only)’)

=cut

sub runPluginCommand {
    my $self = shift;
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L843
    return undef;
}

=item notepad()-E<gt>SendMessage( $msgid, $wparam, $lparam )

For any messages not implemented in the API, if you know the
appropriate $msgid, and what are needed as $wparam and $lparam,
you can send the message to the Notepad GUI directly.

If you have developed a wrapper for a missing message, feel free to send in a
L<Pull Request|https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/pulls>,
or open an L<issue|https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>,
including your wrapper code.

=cut

sub SendMessage {
    my ($self, $msgid, $wparam, $lparam) = @_;
    return $self->{_hwobj}->SendMessage( $msgid, $wparam, $lparam );
}

=over

=item %Win32::Mechanize::NotepadPlusPlus::Notepad::nppm

This hash contains maps all known message names from L<Notepad_plus_msgs.h|https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h>, which are useful for passing to the C<SendMessage> method.

You can find out the names and values of all the messages using:

    printf "%-40s => %s\n", $_, $Win32::Mechanize::NotepadPlusPlus::Notepad::nppm{$_} for sort keys %Win32::Mechanize::NotepadPlusPlus::Notepad::nppm;

=item %Win32::Mechanize::NotepadPlusPlus::Notepad::nppidm

This hash contains maps all known message names from L<menuCmdID.h|https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/menuCmdID.h>, which are useful for passing to the C<SendMessage> method with the NPPM_MENUCOMMAND message.

All of these should be accessible through the L<notepad()-E<gt>runMenuCommand()> method as well.

You can find out the names and values of all the messages using:

    printf "%-40s => %s\n", $_, $Win32::Mechanize::NotepadPlusPlus::Notepad::nppidm{$_} for sort keys %Win32::Mechanize::NotepadPlusPlus::Notepad::nppidm;

=back

=back

=for comment /end of GUI Manipulation

=head2 Meta Information

These give details about the current instance of Notepad++, or the Perl Library, or Perl itself.

=over

=item notepad()-E<gt>getNppVersion() → str

Gets the Notepad++ version as a string.

(This was called getVersion in the PythonScript API.)

=cut

sub getNppVersion {
    my $self = shift;
    my $version_int =  $self->SendMessage( $nppm{NPPM_GETNPPVERSION}, 0, 0);
    my $major = ($version_int & 0xFFFF0000) >> 16;
    my $minor = ($version_int & 0x0000FFFF) >> 0;
    return 'v'.join '.', $major, split //, $minor;
}

=item notepad()-E<gt>getPluginVersion() → str

Gets the PythonScript plugin version as a string.

=cut

sub getPluginVersion {
    return "v$VERSION";
}

=item notepad()-E<gt>getPerlVersion() → str

Gets the Perl interpreter version as a string.

=cut

sub getPerlVersion {
    return ''.$^V;
}

=item notepad()-E<gt>getPerlBits() → str

Gets the Perl interpreter bits-information (32-bit vs 64-bit) as an integer.

=cut

sub getPerlBits {
    return $Config{ivsize}*8;
}

=item notepad()-E<gt>getCommandLine()

Gets the command line used to start Notepad++

NOT IMPLEMENTED.  RETURNS C<undef>.  (May be implemented in the future.)

=cut

sub getCommandLine {
    my $self = shift;
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L893
    return undef;
}

=item notepad()-E<gt>getNppDir() → str

Gets the directory Notepad++ is running in (i.e. the location of notepad++.exe)

=cut

sub getNppDir {
    my $self = shift;
    # NPPM_GETNPPDIRECTORY
    my $dir = $self->{_hwobj}->SendMessage_getUcs2le($nppm{NPPM_GETNPPDIRECTORY},1024,{ trim => 'wparam' });
    $dir =~ s/\0*$//;
    return $dir;
}

=item notepad()-E<gt>getPluginConfigDir() → str

Gets the plugin config directory.

=cut

sub getPluginConfigDir {
    my $self = shift;
    # NPPM_GETPLUGINSCONFIGDIR
    my $dir = $self->{_hwobj}->SendMessage_getUcs2le($nppm{NPPM_GETPLUGINSCONFIGDIR},1024,{ trim => 'wparam' });
    $dir =~ s/\0*$//;
    return $dir;
}

=back

=for comment /end of Meta Information

=head2 FUTURE: Callbacks

Callbacks are functions that are registered to various events.

FUTURE: they were in the PythonScript plugin, but I don't know if they'll be able to work in the remote perl module.
If I ever integrated more tightly with a Notepad++ plugin, it may be that they can be implemented then.

=over

=cut

=item notepad()-E<gt>callback(\&function, $notifications)


Registers a callback function for a notification. notifications is a list of messages to call the function for.:

    def my_callback(args):
            console.write("Buffer Activated %d\n" % args["bufferID"]

=item notepad()-E<gt>callback(\&my_callback, [NOTIFICATION.BUFFERACTIVATED])

The NOTIFICATION enum corresponds to the NPPN_* plugin notifications. The function arguments is a map, and the contents vary dependant on the notification.

Note that the callback will live on past the life of the script, so you can use this to perform operations whenever a document is opened, saved, changed etc.

Also note that it is good practice to put the function in another module (file), and then import that module in the script that calls notepad.callback(). This way you can unregister the callback easily.

For Scintilla notifications, see editor.callback()

Returns:
True if the registration was successful

=cut

sub callback {
    my $self = shift;
    # https://github.com/bruderstein/PythonScript/blob/e1e362178e8bfab90aa908f44214b170c8f40de0/PythonScript/src/NotepadPython.cpp#L64
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L176
    return undef;
}

=item notepad()-E<gt>clearCallbacks()

Unregisters all callbacks

=item notepad()-E<gt>clearCallbacks(\&function)

Unregisters all callbacks for the given function. Note that this uses the actual function object, so if the function has been redefined since it was registered, this will fail. If this has happened, use one of the other clearCallbacks() functions.

=item notepad()-E<gt>clearCallbacks($eventsList)

Unregisters all callbacks for the given list of events.:

    notepad.clearCallbacks([NOTIFICATION.BUFFERACTIVATED, NOTIFICATION.FILESAVED])

See NOTIFICATION

=item notepad()-E<gt>clearCallbacks(\&function, $eventsList)

Unregisters the callback for the given callback function for the list of events.

=cut

sub clearCallbacks {
    my $self = shift;
    # https://github.com/bruderstein/PythonScript/blob/e1e362178e8bfab90aa908f44214b170c8f40de0/PythonScript/src/NotepadPython.cpp#L82-L85
    # https://github.com/bruderstein/PythonScript/blob/1d9230ffcb2c110918c1c9d36176bcce0a6572b6/PythonScript/src/NotepadPlusWrapper.cpp#L741-L812
    return undef;
}

=back

=for comment /end of Callbacks

=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>


=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2018,2019 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
