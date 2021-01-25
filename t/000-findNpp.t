########################################################################
# Check to see if notepad++ is found
# (also serves as debug for the BEGIN-require idiom)
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;

#BEGIN { for my $inc ('./tmp.inc', './t/tmp.inc') { next unless -f $inc; open my $fh, '<', $inc; print for <$fh>; } }
BEGIN { require './tmp.inc' if -f './tmp.inc'; require './t/tmp.inc' if -f './t/tmp.inc'; }

diag "\n"x2;
diag "PATH ELEMENT: ", $_, "\n" for (split /;/, $ENV{PATH})[0];
diag "NPP PATH: ", $_, "\n" for my @wheres = split /\R/, `where notepad++`;
diag "\n"x2;
ok defined scalar @wheres, "temporary manual check";

done_testing();
