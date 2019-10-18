########################################################################
# Verifies the message variables
#   %nppm
#   %nppidm
#   %scimsg
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 3;

use Win32::Mechanize::NotepadPlusPlus ':vars';

my $count;

eval '$count = scalar keys %nppm; 1' or do { $count = undef; };
ok defined($count), '%nppm'; note sprintf 'keys %%nppm => %d', defined $count ? $count : '<undef>';

eval '$count = scalar keys %nppidm; 1' or do { $count = undef; };
ok defined($count), '%nppidm'; note sprintf 'keys %%nppidm => %d', defined $count ? $count : '<undef>';

eval '$count = scalar keys %scimsg; 1' or do { $count = undef; };
ok defined($count), '%scimsg'; note sprintf 'keys %%scimsg => %d', defined $count ? $count : '<undef>';

done_testing;