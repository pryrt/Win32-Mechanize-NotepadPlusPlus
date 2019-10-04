# based on https://metacpan.org/source/PLICEASE/Win32API-ProcessStatus-0.05/test.pl

use Win32API::ProcessStatus ':All';
use strict;

my $winpid = $^O eq 'cygwin' ? Cygwin::pid_to_winpid($$) : $$;

printf STDERR "TestResult => '%s'\n", TestGetModuleFileNameEx();

sub speak { printf STDERR "\n%-70s", @_; }
sub croak { printf STDERR "\n%-70s", @_; }

sub TestGetModuleFileNameEx {
        my ($result, $handle, $handles, $name, $result2);

        use Win32API::Process ':All';

        $handle = OpenProcess(PROCESS_ALL_ACCESS, 0, $winpid);
        croak "  OpenProcess(PROCESS_ALL_ACCESS, 0, $winpid) returned \"$handle\"";
        if ($handle == 0) { return 0; }

        $result = EnumProcessModules($handle, $handles);
        croak "  EnumProcessModules($handle, \$handles) returned \"$result\"";
        if (!$result) { goto EXIT; }

        $result = GetModuleFileNameEx($handle, $$handles[0], $name);
        croak "  GetModuleFileNameEx($handle, $$handles[0], \$name) returned \"$result\"";
        speak "  GetModuleFileNameEx($handle, $$handles[0], \$name) has a name of \"$name\"";
        if (!$result) { return 0; }
EXIT:
        $result2 = CloseProcess($handle);
        croak "  CloseProcess($handle) returned \"$result2\"";
        if (!$result2) { return 0; }

        $result
}

######################### peter's test
{
    print STDERR '-'x80, "\n\n";
    use Win32::Mechanize::NotepadPlusPlus ':main';
    my $hwnd = notepad()->{_hwnd};
    my $pid  = notepad()->{_pid};

    my ($result, $handle, $handles, $name, $result2);

    use Win32API::Process ':All';

    $handle = OpenProcess(PROCESS_ALL_ACCESS, 0, $pid);
    printf STDERR "PROCESS_ALL_ACCESS = 0x%08x\n", PROCESS_ALL_ACCESS;
    croak "  OpenProcess(PROCESS_ALL_ACCESS, 0, $pid) returned \"$handle\"";
    if ($handle == 0) { exit 0; }

    $result = EnumProcessModules($handle, $handles);
    croak "  EnumProcessModules($handle, \$handles) returned \"$result\"";
    if (!$result) { goto EXIT; }

    use Data::Dumper; $Data::Dumper::Useqq = 1;
    print "\$handles = ", Dumper [@{$handles}[0..5]];

    $result = GetModuleFileNameEx($handle, $$handles[0], $name);
    croak "  GetModuleFileNameEx($handle, $$handles[0], \$name) returned \"$result\"";
    speak "  GetModuleFileNameEx($handle, $$handles[0], \$name) has a name of \"$name\"";
    if (!$result) { goto EXIT; }

EXIT:
    $result2 = CloseProcess($handle);
    croak "  CloseProcess($handle) returned \"$result2\"";
    if (!$result2) { exit 0; }

    ######################################
    ## so external process worked, without allocated strings.  That's surprising to me.
    ## the question is, can I use it with the virtual-buffer ->{process}
    use Win32::GuiTest qw/:FUNC/;
    my $vbuf = AllocateVirtualBuffer( $hwnd , 100 );
    $handle = $vbuf->{process};
    speak sprintf "\nnew handle = %d\n", $handle;
    $result = EnumProcessModules($handle, $handles);
    croak "  EnumProcessModules($handle, \$handles) returned \"$result\"";
    print "\$handles = ", Dumper [@{$handles}[0..5]];
    $result = GetModuleFileNameEx($handle, $$handles[0], $name);
    croak "  GetModuleFileNameEx($handle, $$handles[0], \$name) returned \"$result\"";
    speak "  GetModuleFileNameEx($handle, $$handles[0], \$name) has a name of \"$name\"";
    # so it _can_ use the process handle from AllocateVirtualBuffer...
    #   however, if I have to include Win32API::Process/::ProcessStatus anyway, what's the
    #   point.
    # TODO = next, see if I can take the lessons learned from this one, but run it
    #   using the functions defined using Win32::API.  Everything _appears_ to just be
    #   local strings and local structures, based on the XS for ::Process/::ProcessStatus
    #   ... but we'll see.

}