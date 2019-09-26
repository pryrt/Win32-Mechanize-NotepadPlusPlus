#!/usr/bin/env perl
use Path::Tiny;
use IPC::Open2;
use autodie;
use Win32 ();   # doesn't seem to be _needed_ to have access to Win32::GetShortPathName, and use Win32 qw/GetShortPathName GetLongPathName/ says they aren't exported... Apparently -MWin32 is implied on strawberry
use strict;
use warnings;


my @dirs = grep { /Program Files/ } split /\n/, qx{cmd.exe /C dir /X c:\\};
print $_,$/ for @dirs;
my $cdrive = path('c:\\');
for (@dirs) {
    if( my($short,$long) = (m/(\S+)\s+(Program Files.*?$)/) ) {
        print "'$short' vs '$long'\n";
        for my $n ( $short, $long ) {
            printf "\t'%s' =>\n", $n;
            my $p = $cdrive->child($n);
            printf "\t\t%-20s '%s'\n", absolute => $p->absolute;
            printf "\t\t%-20s '%s'\n", canonpath => $p->canonpath;
            printf "\t\t%-20s '%s'\n", 'absolute->canonpath' => $p->absolute->canonpath;
            printf "\t\t%-20s '%s'\n", realpath => $p->realpath;
            printf "\t\t%-20s '%s'\n", 'realpath->canonpath' => $p->realpath->canonpath;
            printf "\t\t%-20s '%s'\n", GetShortPathName => Win32::GetShortPathName($p->canonpath);;
            printf "\t\t%-20s '%s'\n", GetLongPathName  => Win32::GetLongPathName ($p->canonpath);;
        }
    }
}
