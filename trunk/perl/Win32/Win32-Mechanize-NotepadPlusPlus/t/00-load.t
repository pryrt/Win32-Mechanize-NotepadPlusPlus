########################################################################
# Verifies the module load is okay
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    my $MUT = 'Win32::Mechanize::NotepadPlusPlus';      # module under test
    use_ok( $MUT ) or diag "Couldn't even load $MUT";
}
