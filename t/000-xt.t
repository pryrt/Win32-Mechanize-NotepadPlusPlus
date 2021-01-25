########################################################################
# Temporary: manual check to see if notepad++ in path
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;

BEGIN { for my $inc ('./tmp.inc', './t/tmp.inc') { next unless -f $inc; open my $fh, '<', $inc; print for <$fh>; } }
BEGIN { require './tmp.inc' if -f './tmp.inc'; require './t/tmp.inc' if -f './t/tmp.inc'; }

diag "PATH ELEMENT: ", $_, "\n" for (split /;/, $ENV{PATH})[0];
diag "NPP PATH: ", $_, "\n" for my @wheres = split /\R/, `where notepad++`;
ok defined scalar @wheres, "temporary manual check";

done_testing();
