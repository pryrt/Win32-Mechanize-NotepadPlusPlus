########################################################################
# Verifies manual launch of Notepad++
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;

use FindBin;
use lib $FindBin::Bin;

use Win32::API;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';     # 1.64 required for 64-bit SendMessage

BEGIN {
    Win32::API::->Import("user32","DWORD GetWindowThreadProcessId( HWND hWnd, LPDWORD lpdwProcessId)") or die "GetWindowThreadProcessId: $^E";
    Win32::API::->Import("psapi","DWORD WINAPI GetModuleFileNameEx(HANDLE  hProcess, HMODULE hModule, LPTSTR  lpFilename, DWORD   nSize)") or die "GetModuleFileNameEx: $^E";
    Win32::API::->Import("psapi","BOOL EnumProcessModules(HANDLE  hProcess, HMODULE *lphModule, DWORD   cb, LPDWORD lpcbNeeded)") or die "EnumProcessModules: $^E";
}

diag "Is it running to begin with...\n";
my($hwnd) = FindWindowLike(0,undef,'^Notepad\+\+$', undef, undef);
ok $hwnd||-1, 'npp already exists vs not running';
diag "\t", sprintf "hwnd = %s\n", $hwnd//'<undef>';


my $file_exe;
diag "find the exe name...\n";
my $file_exe = ($hwnd) ? _hwnd_to_path($hwnd) : _search_for_npp_exe();
diag "... found ", $file_exe, "\n\n";
ok -x $file_exe, 'notepad++.exe executable found';

if($hwnd) {
    diag "want to kill the process...\n";
    my $pidStruct = pack("L" => 0);
    my $gwtpi = GetWindowThreadProcessId($hwnd, $pidStruct);
    my $extractPid = unpack("L" => $pidStruct);
    diag sprintf "extractPid = %s\n", $extractPid//'<undef>';
    kill -9, $extractPid;
    sleep(1);
}

diag "verify it's not running...\n";
my($kwnd) = FindWindowLike(0,undef,'^Notepad\+\+$', undef, undef);
diag "\t", sprintf "kwnd = %s\n", $kwnd//'<undef>';
ok !defined($kwnd), 'Notepad++ not currently running';

# TODO: probably need to find the executable path, so that I can force that to be in the PATH if it cannot be found... this will allow the auto-finder to find it, even when not in path

# at this point, do a "require" to instantiate it, forcing it to run its code

# then want to see if I could try again with already-running notepad++ (ie, can I re-require by clearing out the %INC or appropriate)

done_testing;

sub _hwnd_to_path
{
    my $hwnd = shift;
    my $filename;

    # use a dummy vbuf for getting the hprocess
    my $vbuf = AllocateVirtualBuffer($hwnd, 1);
    my $hprocess = $vbuf->{process};

    my $LENGTH_MAX = 1024;
    my $ENCODING  = 'cp1252';
    my $cb = Win32::API::Type->sizeof( 'HMODULE' ) * $LENGTH_MAX;
    my $lphmodule  = "\x0" x $cb;
    my $lpcbneeded = "\x0" x $cb;

    if (EnumProcessModules($hprocess, $lphmodule, $cb, $lpcbneeded)) {
        # the first 8 bytes of lphmodule would be the first pointer...
        my $hmodule = unpack 'Q', substr($lphmodule,0,8);
        my $size = Win32::API::Type->sizeof( 'CHAR*' ) * $LENGTH_MAX;
        my $lpfilenameex = "\x0" x $size;
        GetModuleFileNameEx($hprocess, $hmodule, $lpfilenameex, $size);
        $filename = Encode::decode($ENCODING, unpack "Z*", $lpfilenameex);
    }
    FreeVirtualBuffer($vbuf);
    return $filename;
}

sub _search_for_npp_exe {
    my $npp_exe;
    use File::Which 'which';
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
    #print STDERR __PACKAGE__, " found '$npp_exe'\n";
    return $npp_exe;
}
