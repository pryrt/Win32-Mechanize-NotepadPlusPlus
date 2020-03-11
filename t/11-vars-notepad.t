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

use Win32::Mechanize::NotepadPlusPlus::Notepad ':vars';

my $count;

eval '$count = scalar keys %NPPMSG; 1' or do { $count = undef; };
ok defined($count), '%NPPMSG'; note sprintf 'keys %%NPPMSG => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %NPPIDM; 1' or do { $count = undef; };
ok defined($count), '%NPPIDM'; note sprintf 'keys %%NPPIDM => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %ENCODINGKEY; 1' or do { $count = undef; };
ok defined($count), '%ENCODINGKEY'; note sprintf 'keys %%ENCODINGKEY => %s', defined($count) ? $count : '<undef>';

eval '$count = scalar keys %SCIMSG; 1' or do { $count = undef; };
ok !defined($count), '%SCIMSG undefined'; note sprintf 'keys %%SCIMSG => %s', defined($count) ? $count : '<undef>';

done_testing;
