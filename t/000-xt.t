########################################################################
# Temporary: manual check to see if notepad++ in path
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;

BEGIN {
    require './tmp.inc' if -f './tmp.inc';
}

ok $ENV{PATH}, "PATH = $ENV{PATH}";
diag "PATH ELEMENT: $_\n" for split /;/, $ENV{PATH};
diag "NPP PATH:     $_\n" for split /\R/, `where notepad++`;
ok 1, "end temporary manual check";

done_testing();
