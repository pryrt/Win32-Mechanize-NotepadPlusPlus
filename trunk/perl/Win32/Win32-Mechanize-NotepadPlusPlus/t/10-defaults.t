########################################################################
# Verifies the default objects exist
#   notepad()
#   editor1()
#   editor2()
#   console()
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 6;

use Win32::Mechanize::NotepadPlusPlus ':main';

diag '__'.__LINE__.'__';
my $npp = notepad();
diag $npp;
use Data::Dumper; diag Dumper $npp;
diag '__'.__LINE__.'__';
isa_ok $npp, 'Win32::Mechanize::NotepadPlusPlus::Notepad', 'default NPP object';
diag '__'.__LINE__.'__';
ok editor(),  'default editor()  object';
diag '__'.__LINE__.'__';
ok editor1(), 'default editor1() object';
diag '__'.__LINE__.'__';
ok editor2(), 'default editor2() object';
diag '__'.__LINE__.'__';
ok console(), 'default console() object';
diag '__'.__LINE__.'__';
