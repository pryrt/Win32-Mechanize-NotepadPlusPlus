########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for GUI manipulation
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use myTestHelpers;
myTestHelpers::setChildEndDelay(3);

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

use version;
my $ver = version->parse( notepad->getNppVersion() );

# prompt
{
    my $ret;
    runCodeAndClickPopup( sub { $ret = notepad()->prompt('prompt', 'title1', 'default'); }, qr/^\Qtitle1\E$/, 0 );
    is $ret, 'default', 'prompt(): retval = "default"';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # prompt: cancel
    runCodeAndClickPopup( sub { $ret = notepad()->prompt('prompt', 'title2', 'default'); }, qr/^\Qtitle2\E$/, 1 );
    is $ret, undef, 'prompt(): cancel: retval is undef';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # unspecified default text
    runCodeAndClickPopup( sub { $ret = notepad()->prompt('prompt', 'title3', ''); }, qr/^\Qtitle3\E$/, 0 );
    is $ret, '', 'prompt("prompt","title3",undef): no default value -> retval = ""';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # unspecified title text
    runCodeAndClickPopup( sub { $ret = notepad()->prompt('prompt', undef, 'default'); }, qr/^\QW32MNPP prompt\E$/, 0 );
    is $ret, 'default', 'prompt("prompt",undef,"default"): no title value, so search for "W32MNPP prompt" -> retval = "default"';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';
}

# prompt_multiline
{
    my $ret;
    runCodeAndClickPopup( sub { $ret = notepad()->prompt_multiline('prompt', 'title1', 'default'); }, qr/^\Qtitle1\E$/, 0 );
    is $ret, 'default', 'prompt_multiline(): retval = "default"';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # prompt: cancel
    runCodeAndClickPopup( sub { $ret = notepad()->prompt_multiline('prompt', 'title2', 'default'); }, qr/^\Qtitle2\E$/, 1 );
    is $ret, undef, 'prompt_multiline(): cancel: retval is undef';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # unspecified default text
    runCodeAndClickPopup( sub { $ret = notepad()->prompt_multiline('prompt', 'title3', ''); }, qr/^\Qtitle3\E$/, 0 );
    is $ret, '', 'prompt_multiline("prompt","title3",undef): no default value -> retval = ""';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # unspecified title text
    runCodeAndClickPopup( sub { $ret = notepad()->prompt_multiline('prompt', undef, 'default'); }, qr/^\QW32MNPP prompt_multiline\E$/, 0 );
    is $ret, 'default', 'prompt_multiline("prompt",undef,"default"): no title value, so search for "W32MNPP prompt_multiline" -> retval = "default"';
    note sprintf qq(\t=> "%s"\n), $ret // '<undef>';
}

done_testing;
