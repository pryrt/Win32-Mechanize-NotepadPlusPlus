#!/usr/bin/env perl

# using this to replace h2ph script,
#   customized to convert into a hash in the resulting .pm, rather than the constant-subs that h2ph creates

use warnings;
use strict;
use autodie;

my $in_file = $ARGV[0] || './src/Notepad_plus_msgs.h';
my $out_file = $ARGV[1] || './lib/Win32/Mechanize/NotepadPlusPlus/__npp_msgs.pm';

my $slurp = do {
    local $/;
    open my $fh, '<', $in_file;
    <$fh>;
};

my %nppm = ( WM_USER => 0x400 );

$slurp =~ s/\\\n\s*/ /g;
$slurp =~ s{//.*$}{}gim;

foreach ( $slurp =~ /^\h*enum\s\w+\s*{\s*.*?\s*}\s*;/gims ) {
    s/\s+/ /gims;
    my ($list) = ($_ =~ /{\s*(.*?)\s*}/g);
    my @enums = split /,\s*/, $list;
    foreach my $i (0 .. $#enums) {
        $nppm{ $enums[$i] } = $i;
    }
}

foreach ( $slurp =~ /^\h*#\s*define\s+\w+.+$/gim ) {
    #print STDERR "|$_|\n";
    my ($name, $value) = ( m/^\h*#\s*define\s+(\w+)(.*)$/ );
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $nppm{ $name } = $value;
}

# TODO = need to replace

open my $fh, '>', $out_file;
print {$fh} "# auto-converted from $in_file\n";
print {$fh} <<'EOH';
package Win32::Mechanize::NotepadPlusPlus::__npp_msgs;
use warnings;
use strict;
use Exporter 5.57 ('import');

our @EXPORT = qw/%nppm/;
our %nppm = (
EOH

my %already;
foreach my $key ( 'WM_USER', 'NPPMSG', 'RUNCOMMAND_USER', sort keys %nppm ) {
    next if $already{$key};
    my $value = $nppm{$key};
    if( !defined $value ) {
        $value = 'undef';
    } elsif ($value eq '') {
        $value = "''";
    } elsif ($value =~ /[^0-9]/) {
        my @reps;
        while ( $value =~ m/([A-Z]\w+)/gi ) {
            my $rep = $1;
            next if $rep eq 'nppm';
            if( exists $nppm{$rep} ) {
                push @reps, $rep;
            }
        }
        foreach my $rep ( @reps ) {
            $value =~ s/\b$rep\b/$nppm{$rep}/;
        }
    }
    printf {$fh} "    %-40s => %s,\n", "'$key'", $value;
    $nppm{$key} = $value;   # need the key to also update, so that recursive definitions are done properly
    $already{$key} = 'done';
}

print {$fh} ");\n1;\n";
