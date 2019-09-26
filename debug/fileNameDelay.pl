use Path::Tiny 0.018 qw/path tempfile/;
use Win32::Mechanize::NotepadPlusPlus ':main';
use strict;
use warnings;

my $txtfile = tempfile( TEMPLATE => 'XXXXXXXX')->sibling('fileNameDelay.txt');
$txtfile->append("contents");

my $saveUserSession = $txtfile->sibling('EmergencyNppSession.xml');
notepad()->saveCurrentSession( $saveUserSession->absolute->canonpath() ) or
    die "could not save session: $!";

notepad()->closeAll();


for my $run (1..5) {
    notepad()->open($txtfile->absolute->canonpath);
    my $fname = notepad()->getCurrentFilename();
    my $tuples = notepad()->getFiles();
    printf "%d#['%s',%s,%s,%s] vs '%s'\n", $run, @$_, $fname//'<undef>' for @{$tuples}[0];
    print "\n";
    notepad()->close();
}

END {
    notepad()->loadSession($saveUserSession->absolute->canonpath)
        and $saveUserSession->remove;
    $txtfile->remove;
}