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

=begin
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
=cut

=begin
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
=cut

# new version, inspired by Win32::FindWindow module
eval {
=begin

EXAMPLE CODE from ::FindWindow

        my $hprocess;
           ($hprocess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, 0, $result{pid}))
        or ($hprocess = OpenProcess(PROCESS_QUERY_INFORMATION,                   0, $result{pid}));
        if ($hprocess > 0) {
            my $cb         = Win32::API::Type->sizeof( 'HMODULE' ) * $LENGTH_MAX;
            my $lphmodule  = "\x0" x $cb;
            my $lpcbneeded = "\x0" x $cb;
            if (EnumProcessModules($hprocess, $lphmodule, $cb, $lpcbneeded)) {
                my $hmodule = Win32::API::Type::Unpack('HMODULE', $lphmodule);

                # GetModuleFileNameEx()
                {
                    my $size = Win32::API::Type->sizeof( 'CHAR*' ) * $LENGTH_MAX;
                    my $lpfilenameex = "\x0" x $size;
                    GetModuleFileNameEx($hprocess, $hmodule, $lpfilenameex, $size);
                    $result{filename} = Encode::decode($ENCODING, Win32::API::Type::Unpack('CHAR*', $lpfilenameex));
                }

                # GetModuleBaseName()
                {
                    my $size = Win32::API::Type->sizeof( 'CHAR*' ) * $LENGTH_MAX;
                    my $lpbasename = "\x0" x $size;
                    GetModuleBaseName($hprocess, $hmodule, $lpbasename, $size);
                    $result{basename} = Encode::decode($ENCODING, Win32::API::Type::Unpack('CHAR*', $lpbasename));
                }
            }
            CloseHandle($hprocess);
        }
=cut
    local $\ = $/;
    print "pid = $pid";
    print "vbuf = ", Dumper my $vbuf = AllocateVirtualBuffer($hwnd, 1); # the buffer itself is a dummy; this is just for the process...
    print "hprocess => ", my $hprocess = $vbuf->{process};
    my $LENGTH_MAX = \1024;
    our $ENCODING  = 'cp1252';
    print "cb => ", my $cb = Win32::API::Type->sizeof( 'HMODULE' ) * $LENGTH_MAX;
    my $lphmodule  = "\x0" x $cb;   print "len lphmodule = ", length($lphmodule);
    my $lpcbneeded = "\x0" x $cb;   print "len lpcbneeded = ", length($lpcbneeded);
                print "lphmodule before enum => ", Dumper substr($lphmodule,0,128);
            if (EnumProcessModules($hprocess, $lphmodule, $cb, $lpcbneeded)) {
                print "lphmodule after  enum => ", Dumper substr($lphmodule,0,128);
                # my $hmodule = Win32::API::Type->Unpack('HMODULE', $lphmodule); # not working
                #print "hmodule =>", Dumper $hmodule;
                # I think the first 8 bytes of lphmodule would be the first pointer...
                my $hmodule = unpack 'Q', substr($lphmodule,0,8);
                printf "hmodule => 0x%016x\n", $hmodule;
                our $filename;
                # GetModuleFileNameEx()
                {
                    my $size = Win32::API::Type->sizeof( 'CHAR*' ) * $LENGTH_MAX;
                    my $lpfilenameex = "\x0" x $size;
                    GetModuleFileNameEx($hprocess, $hmodule, $lpfilenameex, $size);
                    print "lpfilenameex = ", Dumper substr($lpfilenameex,0,128);
                    print "unpacked = ", Dumper my $u = unpack "Z*", $lpfilenameex;
                    print "filename = ", Dumper $filename = Encode::decode($ENCODING, $u);
                    printf "filename = '%s'", $filename;
                }

            }
    FreeVirtualBuffer($vbuf);
    1;
} or do { print "eval FindWindow-like error: '$@'\n"};
1;