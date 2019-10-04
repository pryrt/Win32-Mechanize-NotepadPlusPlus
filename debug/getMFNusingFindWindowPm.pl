# https://metacpan.org/release/Win32-FindWindow/source/lib/Win32/FindWindow.pm
package FindWindow;
use warnings;
use strict;
use utf8;
use Encode;
use Win32::API;
use Win32::API::Callback;

use base qw(Exporter Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(hwnd windowtext classname pid filename basename));

use constant PROCESS_VM_READ           => 0x0010;
use constant PROCESS_QUERY_INFORMATION => 0x0400;

our $VERSION = '0.03';

our @EXPORT = qw();
our @EXPORT_OK = qw(find_window find_windows);
our @ARGS_REGEXP = qw(windowtext classname filename basename);

our $ENCODING  = 'cp1252';
our $LENGTH_MAX = 1024;

our $args = {};
our @instances = ();

Win32::API->Import("user32",   "GetWindowThreadProcessId", "NP",   "N");
Win32::API->Import("user32",   "GetClassName",             "NPI",  "I");
Win32::API->Import("user32",   "GetWindowTextLength",      "N",    "I");
Win32::API->Import("user32",   "GetWindowText",            "NPI",  "I");
Win32::API->Import("kernel32", "OpenProcess",              "NIN",  "N");
Win32::API->Import("psapi",    "EnumProcessModules",       "NPNP", "I");
Win32::API->Import("kernel32", "CloseHandle",              "N",    "I");
Win32::API->Import("psapi",    "GetModuleFileNameEx",      "NNPN", "N");
Win32::API->Import("psapi",    "GetModuleBaseName",        "NNPN", "N");
Win32::API->Import("user32",   "GetDesktopWindow",         "",     "N");
Win32::API->Import("user32",   "EnumChildWindows",         "NKP",  "I");

sub _neg(@) { map { $_, "$_!" } @_ } ## no critic

our $EnumChildProc = Win32::API::Callback->new(sub {
    my %result = ();
    $result{hwnd} = shift;

    # GetWindowThreadProcessId()
    {
        my $ppid = "\x0" x Win32::API::Type->sizeof( 'LPDWORD' );
        GetWindowThreadProcessId($result{hwnd}, $ppid);
        $result{pid} = Win32::API::Type::Unpack('LPDWORD', $ppid);
    }

    if ($result{pid}) {
        # GetClassName()
        {
            my $size = Win32::API::Type->sizeof( 'CHAR*' ) * $LENGTH_MAX;
            my $pclassname = "\x0" x $size;
            GetClassName($result{hwnd}, $pclassname, $size);
            $result{classname} = Encode::decode($ENCODING, Win32::API::Type::Unpack('CHAR*', $pclassname));
        }

        # GetWindowText()
        {
            my $size = GetWindowTextLength($result{hwnd});
            if (Win32::API::IsUnicode()) { $size *= 2; }
            $size++;
            my $pwindowtext = "\x0" x $size;
            GetWindowText($result{hwnd}, $pwindowtext, $size);
            $result{windowtext} = Encode::decode($ENCODING, Win32::API::Type::Unpack('CHAR*', $pwindowtext));
        }

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

        my $found = 1;
        for my $_key (_neg @ARGS_REGEXP) {
            next unless defined($args->{$_key});
            my $neg = '';
            (my $key, $neg) = ($_key =~ /(\w+)(!)?$/);
            next unless defined($args->{$key});

            if ($neg) {
                $found = 0     if $result{$key} =~ $args->{$key};
            }
            else {
                $found = 0 unless $result{$key} =~ $args->{$key};
            }
        }

        if ($found) {
            push(@instances, __PACKAGE__->new(%result));
        }
    }
    1;
}, "NN", "I");

sub find_window {
    @instances = find_windows(@_);
    if (@instances > 1) { @instances = sort { $a->{pid} <=> $b->{pid} } @instances; }
    $instances[0];
}

sub find_windows {
    $args = {@_};

    $args->{hwnd} = (defined($args->{hwnd}) and ($args->{hwnd} =~ /^\d+$/))
                  ? $args->{hwnd}
                  : GetDesktopWindow();

    @instances = ();
    EnumChildWindows($args->{hwnd}, $EnumChildProc, 0);
    @instances;
}

sub new {
    my $class = shift;
    bless {@_}, $class;
}

1;

package main;

use warnings;
use strict;

use Data::Dumper; $Data::Dumper::Useqq = 1;
no warnings 'uninitialized';
print "window => ", Dumper my $window = FindWindow::find_window(windowtext => qr/^Notepad++/);
use warnings;
__END__