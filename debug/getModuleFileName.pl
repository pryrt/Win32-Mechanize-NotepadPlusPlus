# https://perl-win32-users.listserv.activestate.narkive.com/Rdrwxkog/win32-api-problem-pack-unpack#post2
use strict;
use Win32::API;

# HWND FindWindow(LPCTSTR lpClassName, LPCTSTR lpWindowName);

my $FindWindow = new Win32::API('USER32', 'FindWindow', 'PP', 'N') or
die "FindWindow: $!";
my $hWnd = $FindWindow->Call(0, 0);
print "hWnd=$hWnd\n";

# DWORD GetWindowThreadProcessId(HWND hWnd, LPDWORD lpdwProcessId);

my $GetWindowThreadProcessId = new Win32::API('user32',
'GetWindowThreadProcessId', 'LP', 'N') or
die "get GetWindowThreadProcessId: $!";
my $lpdwProcessId = pack 'L', 0;
my $CTID = $GetWindowThreadProcessId->Call($hWnd, $lpdwProcessId) or
die "GetWindowThreadProcessId->Call: $!";
my $dwProcessId = unpack 'L', $lpdwProcessId;
printf "CTID=$CTID; lpdwProcessId=$dwProcessId\n";

# HANDLE OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle,
# DWORD dwProcessId);

my $OpenProcess = new Win32::API('kernel32', 'OpenProcess', 'ILI', 'N') or
die "get OpenProcess: $!";
use constant SYNCHRONIZE => 0x00100000;
use constant STANDARD_RIGHTS_REQUIRED => 0x000F0000;
use constant PROCESS_ALL_ACCESS => (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE |
0xFFF);
my $dwDesiredAccess = PROCESS_ALL_ACCESS;
my $bInheritHandle = 0;
printf "dwDesiredAccess=%08X\n", $dwDesiredAccess;
my $handle = $OpenProcess->Call($dwDesiredAccess, $bInheritHandle,
$dwProcessId);
print "handle='$handle'\n";

# DWORD GetModuleFileName(HMODULE hModule, LPTSTR lpFilename, DWORD nSize);

my $GetModuleFileName = new Win32::API('kernel32', 'GetModuleFileName', 'LPI',
'N') or die "get GetModuleFileName: $!";
my $nSize = 256;
my $lpFilename = ' ' x $nSize;

# maybe your handle will work on the next line, I oculd only get it to work
# using the default handle (0)

# my $ret = $GetModuleFileName->Call($handle, $lpFilename, 256) or
my $ret = $GetModuleFileName->Call(0, $lpFilename, $nSize) or
die "GetModuleFileName->Call: $!";
print "ret=$ret\n";
printf "FileName=%s\n", unpack 'A*', $lpFilename;

###### Peter Additions #####
{
    use Data::Dumper; $Data::Dumper::Useqq = 1;
    use Win32::GuiTest qw':FUNC !SendMessage';
    my $vbuf = AllocateVirtualBuffer( $hWnd , $nSize );
    print "vbuf => ", Dumper $vbuf;
    WriteToVirtualBuffer( $vbuf, "Hello, world"); # pre-populate
    print Dumper \Win32::GuiTest::ReadFromVirtualBuffer( $vbuf , $nSize); # make sure readback working
    print "\n";
    my $ret = $GetModuleFileName->Call( 0, $lpFilename, $nSize) or
        die "GetModuleFileName->Call: $!";
    print "ret=$ret\n";
    printf "FileName=%s\n", unpack 'A*', $lpFilename;
}
__END__

Output:
hWnd=1115222
CTID=3020; lpdwProcessId=3348 (3348 is Netscape ???)
dwDesiredAccess=001F0FFF
handle='1980'
ret=20
FileName=F:\perl\bin\perl.exe