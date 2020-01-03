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

my($hwnd) = FindWindowLike(0,undef,'^Notepad\+\+$', undef, undef);
ok $hwnd||-1, 'npp exists vs launch';
diag "\t", sprintf "hwnd = %s\n", $hwnd//'<undef>';

if($hwnd) {
    diag "want to kill the process\n";
    my $pidStruct = pack("L" => 0);
    my $gwtpi = GetWindowThreadProcessId($hwnd, $pidStruct);
    my $extractPid = unpack("L" => $pidStruct);
    diag sprintf "extractPid = %s\n", $extractPid//'<undef>';
    kill -9, $extractPid;
    sleep(1);
    my($kwnd) = FindWindowLike(0,undef,'^Notepad\+\+$', undef, undef);
    diag "\t", sprintf "kwnd = %s\n", $kwnd//'<undef>';
    ok !defined($kwnd), 'should be killed';
}

# TODO: probably need to find the executable path, so that I can force that to be in the PATH if it cannot be found... this will allow the auto-finder to find it, even when not in path

# at this point, do a "require" to instantiate it, forcing it to run its code

# then want to see if I could try again with already-running notepad++ (ie, can I re-require by clearing out the %INC or appropriate)

done_testing;