########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for hidden scintilla instance
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;
use Win32::GuiTest qw':FUNC !SendMessage';

use FindBin;
use lib $FindBin::Bin;
use myTestHelpers;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

my $sci = notepad()->createScintilla();
isa_ok $sci, "Win32::Mechanize::NotepadPlusPlus::Editor"
    or BAIL_OUT(sprintf 'invalid object:%s returned from createScintilla()', $sci//'<undef>');
    note sprintf "\tsci = %s", $sci//'<undef>';

note sprintf "->createScintilla() has hwnd = %s", $sci->{_hwnd} // '<undef>';
ok 0+$sci->{_hwnd}, 'returned hwnd is non-zero' or BAIL_OUT('invalid hwnd from createScintilla');

my $class = GetClassName($sci->{_hwnd});
is GetClassName($class), 'Scintilla', 'class(hwnd) is Scintilla';
note sprintf "\tclass(h:%s) = '%s'", $sci->{_hwnd}, $class // '<undef>';

my $destroy = notepad()->destroyScintilla($sci);
ok $destroy, '->destroyScintilla(): retval'; note sprintf "\tretval = %s", $destroy // '<undef>';

done_testing;