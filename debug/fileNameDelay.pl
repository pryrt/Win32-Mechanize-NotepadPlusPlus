use Path::Tiny 0.018 qw/path tempfile/;
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;
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
notepad()->closeAll();

for my $run ( 1.. 5 ) {
    my $str = "\n"; # join '', ('A'..'Z')[map { rand 26 } 0 .. rand 20 ], "\n";
    editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $str );
    notepad()->saveAs( $txtfile->absolute->canonpath );

    $str .= sprintf "#%d '%s'\n", $_, notepad()->getCurrentFilename()//'<undef>' for 1..50;
    editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $str );
    notepad()->save();

    print "\n";
    sleep(1);
    notepad()->close();
#    ok $ret, sprintf 'saveAs(): retval = %d', $ret;
#
#    $ret = _wait_for_file_size( $fnew1->absolute->canonpath() );
}

END {
    notepad()->loadSession($saveUserSession->absolute->canonpath)
        and $saveUserSession->remove;
    $txtfile->remove;
}