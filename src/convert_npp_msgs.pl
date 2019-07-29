#!/usr/bin/env perl

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

my %nppm;

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
print {$fh} <<'EOH';
# auto-converted from $in_file
package Win32::Mechanize::NotepadPlusPlus::__npp_msgs;
use warnings;
use strict;
use Exporter 5.57 ('import');

our %nppm;
our @EXPORT = qw/%nppm/;

EOH

foreach my $key ( sort keys %nppm ) {
    my $value = $nppm{$key};
    print {$fh} "\$nppm{'$key'} = '$value';\n";
}

print {$fh} "1;\n";