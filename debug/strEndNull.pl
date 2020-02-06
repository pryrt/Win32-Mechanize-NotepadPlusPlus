use warnings;
use strict;
use Data::Dumper; $Data::Dumper::Useqq=1;
use Win32::Mechanize::NotepadPlusPlus qw/:main/;

BEGIN {
    notepad->newFile();
    notepad->moveCurrentToOtherView();
}

END {
    editor->setText("");
    notepad->close();
}

editor->setText("Hello World");
my $got = editor->getText();

use Test::More tests => 1;
like $got, qr/^Hello World$/, 'No null at end'
    or diag "\tgot ", Dumper $got;
done_testing();