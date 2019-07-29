#!/usr/bin/env perl
# Copyright (C) 2019 Peter C. Jones
#   see LICENSE file

# derived from convert_npp_msgs.pl
#   customized for scintilla, rather than Notepad++
#   generates a %scimsg hash to contain the messages

use warnings;
use strict;
use autodie;

my $in_file = $ARGV[0] || './src/Scintilla.h';
my $out_file = $ARGV[1] || './lib/Win32/Mechanize/NotepadPlusPlus/__sci_msgs.pm';

my $slurp = do {
    local $/;
    open my $fh, '<', $in_file;
    <$fh>;
};

my %scimsg = ();

$slurp =~ s/\\\n\s*/ /g;
$slurp =~ s{//.*$}{}gim;

foreach ( $slurp =~ /^\h*enum\s\w+\s*{\s*.*?\s*}\s*;/gims ) {
    s/\s+/ /gims;
    my ($list) = ($_ =~ /{\s*(.*?)\s*}/g);
    my @enums = split /,\s*/, $list;
    foreach my $i (0 .. $#enums) {
        $scimsg{ $enums[$i] } = $i;
    }
}

foreach ( $slurp =~ /^\h*#\s*define\s+\w+.+$/gim ) {
    #print STDERR "|$_|\n";
    my ($name, $value) = ( m/^\h*#\s*define\s+(\w+)(.*)$/ );
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $scimsg{ $name } = $value;
}

open my $fh, '>', $out_file;
print {$fh} "# auto-converted from $in_file at ", scalar localtime, "\n";
print {$fh} <<'EOH';
package Win32::Mechanize::NotepadPlusPlus::__sci_msgs;
use warnings;
use strict;
use Exporter 5.57 ('import');

our @EXPORT = qw/%scimsg/;
our %scimsg = (
EOH

my %already;
foreach my $key ( sort keys %scimsg ) {
    next if $already{$key};
    my $value = $scimsg{$key};
    if( !defined $value ) {
        $value = 'undef';
    } elsif ($value eq '') {
        $value = "''";
    } elsif ($value =~ /[^0-9]/) {
        my @reps;
        while ( $value =~ m/([A-Z]\w+)/gi ) {
            my $rep = $1;
            next if $rep eq 'scimsg';
            if( exists $scimsg{$rep} ) {
                push @reps, $rep;
            }
        }
        foreach my $rep ( @reps ) {
            $value =~ s/\b$rep\b/$scimsg{$rep}/;
        }
    }
    next if $value =~ /^Sci_\w+$/;
    printf {$fh} "    %-60s => %s,\n", "'$key'", $value;
    $scimsg{$key} = $value;   # need the key to also update, so that recursive definitions are done properly
    $already{$key} = 'done';
}

print {$fh} ");\n1;\n";
