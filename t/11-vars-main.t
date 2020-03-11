########################################################################
# Verifies the message variables when loaded from parent module
#   %NPPMSG
#   %NPPIDM
#   %scimsg
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More tests => 4;

use Win32::Mechanize::NotepadPlusPlus ':vars';

my $count;

eval '$count = scalar keys %NPPMSG; 1' or do { $count = undef; };
ok defined($count), '%NPPMSG'; note sprintf 'keys %%NPPMSG => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %NPPIDM; 1' or do { $count = undef; };
ok defined($count), '%NPPIDM'; note sprintf 'keys %%NPPIDM => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %nppencoding; 1' or do { $count = undef; };
ok defined($count), '%nppencoding'; note sprintf 'keys %%nppencoding => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %scimsg; 1' or do { $count = undef; };
ok defined($count), '%scimsg'; note sprintf 'keys %%scimsg => %s', defined($count) ? $count : '<undef>';

done_testing;
