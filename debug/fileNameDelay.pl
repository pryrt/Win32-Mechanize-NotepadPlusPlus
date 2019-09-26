########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for file and session open/close
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;
use Win32;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus ':main';

# outline:
#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.

our $saveUserFileList;
BEGIN {
    use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;  # for %scimsg
    my $unsaved = 0;
    for my $view (0, 1) {
        my $nb = notepad()->getNumberOpenFiles($view);
        for my $idoc ( 0 .. $nb-1 ) {
            notepad()->activateIndex($view,$idoc);
            $unsaved++ if editor()->{_hwobj}->SendMessage( $scimsg{SCI_GETMODIFY} );
            push @$saveUserFileList, notepad()->getCurrentFilename();
        }
    }
    no Win32::Mechanize::NotepadPlusPlus::__sci_msgs;
    if($unsaved) {
        my $err = "\n"x4;
        $err .= sprintf "%s\n", '!'x80;
        $err .= sprintf "You have %d unsaved file%s in Notepad++!\n", $unsaved, ($unsaved>1)?'s':'';
        $err .= sprintf "Please save or close %s, then re-run the module test or installation.\n", ($unsaved>1)?'them':'it';
        $err .= sprintf "%s\n", '!'x80;
        $err .= "\n"x4;
        diag($err);
        BAIL_OUT('Unsaved Files: Please read the message between the !!!-lines.');
    }
}

#   prepopulate any tempfile locations
our ($saveUserSession, $knownSession, $fnew1, $fnew2);
BEGIN {
    # use tempfiles for the "new" and "save as" files
    $fnew1 = tempfile( TEMPLATE => 'nppNewFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew1->canonpath();
    $fnew2 = tempfile( TEMPLATE => 'nppDupFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew2->canonpath();
    $knownSession = tempfile( TEMPLATE => 'nppKnownSession_XXXXXXXX', SUFFIX => '.xml'); note $knownSession->canonpath();

    # for saveUserSession, use a named session, which I can point out to the user if necessary, or delete if safe.
    $saveUserSession = $fnew1->sibling('EmergencyNppSession.xml'); note $saveUserSession->canonpath(); # don't want to delete the session
    # the list of files was saved above, because I was already looping through all the open files.
}

#   ->saveCurrentSession($saveUserSession)
#       => this also avoids messing up the user's current Notepad++ instance.
#           STOP IMMEDIATELY IF THIS FAILS
#       => attempt to reload that session on exit (END block),
#           and if there's a problem with reload, point user
#           to where the session file is.
{
    my $ret = notepad()->saveCurrentSession( $saveUserSession->canonpath() );
    ok $ret, sprintf 'saveCurrentSession("%s"): retval = %d', $saveUserSession->canonpath(), $ret;
    my $size = $saveUserSession->is_file ? $saveUserSession->stat()->size : 0;
    ok $size, sprintf 'saveCurrentSession(): size(file) = %d', $size
        or do {
            my $err = "\n"x4;
            $err .= sprintf "%s\n", '!'x80;
            $err .= sprintf "I could not save your session for you!\n";
            $err .= sprintf "Because of this, I am not willing to continue running the test suite,.\n";
            $err .= sprintf "as I may not be able to restore your files.\n";
            $err .= sprintf "\n";
            $err .= sprintf "Please close all your files, and try to re-run the module test or installation\n";
            $err .= sprintf "%s\n", '!'x80;
            $err .= "\n"x4;
            diag($err);
            BAIL_OUT('Could not save session.  Please read the message between the !!!-lines.');
        };
}

# as last event in test (even after done_testing), make sure the files
#   from the user's original session are all loaded, and bail out with
#   emergency message if not:
our $inChildFork;   # if in a child fork, don't want to do the cleanup, because we're not done with the test, just with that temporary fork
END {
    if(!$inChildFork) {
        # in case any are left open, close them
        notepad()->closeAll;

        # should load just the user's files
        notepad()->loadSession($saveUserSession->absolute->canonpath);

        # check for any missing files
        my $missing = 0;
        for my $f ( @$saveUserFileList ) {
            ++$missing unless notepad()->activateFile($f);
        }
        if($missing) {
            my $err = "\n"x4;
            $err .= sprintf "%s\n", '!'x80;
            $err .= sprintf "I could not restore your session for you!\n";
            $err .= sprintf "It should be saved in \"%s\".\n", $saveUserSession->absolute->canonpath;
            $err .= sprintf "Feel free to try to File > Load Session... for that file\n";
            $err .= sprintf "\n";
            $err .= sprintf "Sorry for any inconvenience.  I tried.\n";
            $err .= sprintf "%s\n", '!'x80;
            $err .= "\n"x4;
            diag $err;
            BAIL_OUT(sprintf 'File > Load Session... > "%s"', $saveUserSession->absolute->canonpath);
        }

        # only delete the file if the session has been successfully loaded.
        $saveUserSession->remove();
        diag "Verified user session files re-loaded.";
    }
}

#   ->closeAll()
#       => gives a blank slate to work with.
{
    my $ret = notepad()->closeAll();
    ok $ret, sprintf 'closeAll(): retval = %d', $ret;

    my $nOpen = notepad()->getNumberOpenFiles(0);
    is $nOpen, 1, sprintf 'closeAll(): getNumberOpenFiles(0) = %d', $nOpen;

    my $fName = notepad()->getCurrentFilename();
    like $fName, qr/^new \d/i, sprintf 'closeAll(): getCurrentFilename() = "%s"', $fName;
}

#   ->newFile()
#       => create a blank, editable document
{
    my $ret = notepad()->newFile();
    ok $ret, sprintf 'newFile(): retval = %d', $ret;

    my $fName = notepad()->getCurrentFilename();
    like $fName, qr/^new \d/i, sprintf 'newFile(): getCurrentFilename() = "%s"', $fName;
}

#   ->saveAs( $fnew1 )
#       => give it a name
{
    my $text = sprintf 'saveAs("%s")%s', $fnew1->basename(), "\0";
    editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $text );

    my $ret = notepad()->saveAs( Win32::GetShortPathName($fnew1->absolute->canonpath()) );
    ok $ret, sprintf 'saveAs(): retval = %d', $ret;
#diag "saveAs -> getFiles: ", explain notepad()->getFiles;

#    my $fName = _wait_for_defined( sub {_longpath(notepad()->getCurrentFilename())}, 10 );
    my $fName = notepad()->getCurrentFilename();
    BAIL_OUT(__LINE__) unless defined $fName;
    diag sprintf 'fName = "%s"', $fName;

    #$fName = Win32::GetShortPathName($fName);
    #BAIL_OUT(__LINE__) unless defined $fName;
    #diag sprintf 'fName = "%s"', $fName;

    $fName = Win32::GetLongPathName($fName);
    BAIL_OUT(__LINE__) unless defined $fName;
    diag sprintf 'fName = "%s"', $fName;

    BAIL_OUT('undefined name') unless defined $fName;
#    is $fName, _longpath($fnew1->absolute->canonpath()), sprintf 'saveAs(): getCurrentFilename() = "%s"', $fName//'<undef>';
}

done_testing;

sub _longpath {
    #diag sprintf '_longpath("%s"): called from line=%d', $_[0]//'<undef>', (caller())[2];
    (-f $_[0]) ? Win32::GetLongPathName($_[0]) : $_[0];
}

sub _wait_for_defined {
    my $cref = shift;
    my $tries = shift || 5;
    my $answer = $cref->();
BAIL_OUT("undef") unless defined $answer;
    return $answer;
}

sub _wait_for_file_size {
    my ($fname, $timeout) = @_;
    $timeout //= 10;    # wait 10s if not given
    my $t0 = time;
    while((time()-$t0) < $timeout) {
        note sprintf "__%04d__->_wait_for_file_size(%s,%d): %d %d [%s]", (caller)[2], $fname, $timeout, (-f _ ? 1 : 0), (-s _ || 0 ), scalar localtime;
        last if -f $fname and -s $fname;
        select(undef,undef,undef,0.1);
    }
    return -s _;
}

__END__
use Path::Tiny 0.018 qw/path tempfile/;
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;
use Test::More;
use Win32;
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