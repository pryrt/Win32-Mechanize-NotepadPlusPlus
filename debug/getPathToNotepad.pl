use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::API;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';     # 1.64 required for 64-bit SendMessage

use strict;
use warnings;

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

        Win32::API::->Import("psapi","BOOL EnumProcessModules(HANDLE  hProcess, HMODULE *lphModule, DWORD   cb, LPDWORD lpcbNeeded)") or die "EnumProcessModules: $^E";  # uncoverable branch true
    }


my $hwnd = notepad()->{_hwnd};
my $pid  = notepad()->{_pid};
printf "hwnd => 0x%08x = %12d\n", $hwnd, $hwnd;
printf "pid  => 0x%08x = %12d\n", $pid, $pid;

# already have PID and HWND, and the AllocateVirtualBuffer gets me a process handle
my $bufStr = Win32::GuiTest::AllocateVirtualBuffer( $hwnd, 1000 );
print "bufStr => ", Dumper $bufStr;
Win32::GuiTest::WriteToVirtualBuffer( $bufStr, "Hello, world"); # pre-populate
print Dumper \Win32::GuiTest::ReadFromVirtualBuffer( $bufStr , 1000); # make sure readback working
print "\n";
eval {
print "dw = ", my $dw = GetModuleFileNameEx( $bufStr->{process} , 0, $bufStr->{ptr}, 100);
} or do { print "eval error: $@\n"};
#    my $vBuf = Win32::GuiTest::ReadFromVirtualBuffer( $bufStr , 1000) or die "buf read: $! ($^E)";
#    print "GMFNE($pHandle) = dw:$dw, '$vBuf'\n";

eval {
print __LINE__, "\n";
my $structure = "\0"x8192;
my $cb = 1024 * 8;      # 1k handles, where a handle is the same size as a pointer
my $handle = $bufStr->{process};
print __LINE__, "\n";
my $handles = pack("P", $structure);
my $lpcb_val = 1024*$cb;
print __LINE__, "\n";
my $lpcb = pack("p", $lpcb_val);
my $enumResult;
print __LINE__, "\n";
$enumResult = EnumProcessModules( $handle, $handles, $cb , $lpcb);
print __LINE__, "\n";
} or do { print "eval EnumProcessModules error: $@\n"};
print __LINE__, "\n";

1;