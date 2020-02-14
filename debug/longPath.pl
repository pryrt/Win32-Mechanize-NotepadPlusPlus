#!perl
use 5.010;
use warnings;
use strict;
use Win32::API;
use Path::Tiny 0.018;

BEGIN {
    Win32::API::->Import("kernel32","DWORD GetLongPathNameA( LPCWSTR lpszShortPath, LPWSTR lpszLongPath, DWORD cchBuffer )") or die "GetLongPathNameA: $^E";  # uncoverable branch true
}

sub wrapGetLongPathName {
    my $inPath = shift;
    my $lpszShortPath = $inPath; #'\\\\?\\' . $inPath;        # prepend literal \?\ to path to remove 260-character limit
    my ($lpszLongPath, $cchBuffer) = ("",0);
    my $ret = GetLongPathNameA( $lpszShortPath, $lpszLongPath, $cchBuffer);
    $lpszLongPath = "\0" x ($ret ? $ret : 1024);
    $cchBuffer = $ret ? $ret : 1024;
    $ret = GetLongPathNameA( $lpszShortPath, $lpszLongPath, $cchBuffer );
    $lpszLongPath =~ s/\0*$//g;   # trim trailing NULs

    printf STDERR "%-07d # GetLongPathNameA( '%s', '%s', %s ) = %s\n", map $_//'<undef>', 0+$ARGV[0], $lpszShortPath, $lpszLongPath, $cchBuffer, $ret;
    return $lpszLongPath;
}

if($ARGV[1]) {
    my $x = Win32::GetLongPathName( path($0)->absolute->canonpath );
    printf STDERR "%-07d # Win32::GetLongPathName('%s') => '%s'\n", $ARGV[0], path($0)->absolute->canonpath, $x // 'FAILED';
} else {
    wrapGetLongPathName( path($0)->absolute->canonpath ) or die "didn't find path";
}
