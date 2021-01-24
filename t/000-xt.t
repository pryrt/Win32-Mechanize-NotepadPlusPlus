########################################################################
# Temporary: manual check to see if notepad++ in path
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;

BEGIN { require './tmp.inc' if -f './tmp.inc'; }

ok $ENV{PATH}, "PATH = $ENV{PATH}";
diag "FIRST PATH ELEMENT: $_\n" for (split /;/, $ENV{PATH})[0];
diag "NPP PATH:     $_\n" for my @wheres = split /\R/, `where notepad++`;
ok defined scalar @wheres, "temporary manual check";

done_testing();
