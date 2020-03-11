########################################################################
# Verifies the message variables when loaded from parent module
#   %NPPMSG
#   %NPPIDM
#   %SCIMSG
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More tests => 4;

use Win32::Mechanize::NotepadPlusPlus::Editor ':vars';

my $count;

eval '$count = scalar keys %NPPMSG; 1' or do { $count = undef; };
ok !defined($count), '%NPPMSG undefined'; note sprintf 'keys %%NPPMSG => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %NPPIDM; 1' or do { $count = undef; };
ok !defined($count), '%NPPIDM undefined'; note sprintf 'keys %%NPPIDM => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %ENCODINGKEYS; 1' or do { $count = undef; };
ok !defined($count), '%ENCODINGKEYS undefined'; note sprintf 'keys %%ENCODINGKEYS => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %SCIMSG; 1' or do { $count = undef; };
ok defined($count), '%SCIMSG'; note sprintf 'keys %%SCIMSG => %s', defined($count) ? $count : '<undef>';

done_testing;
