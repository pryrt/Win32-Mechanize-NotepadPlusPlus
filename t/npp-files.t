########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for file and session open/close
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;

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

#notepad()->close();

# as last event in test (even after done_testing), make sure the files
#   from the user's original session are all loaded, and bail out with
#   emergency message if not:
END {
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

#   ->loadSession()
#       => gets us to a known state with a prebuilt session
{
    # generate the session file on the fly, because it needs absolute directories, which I cannot have until the test suite runs
    my @src = qw/00-load.t 10-defaults.t/;
    $knownSession->append(qq{<NotepadPlus><Session activeView="0"><mainView activeIndex="0">\n});
    $knownSession->append(sprintf qq{<File firstVisibleLine="0" xOffset="0" filename="%s" />\n}, $_)
        for map { path($0)->sibling($_)->absolute->canonpath() } @src;
    $knownSession->append(qq{</mainView><subView activeIndex="0" /></Session></NotepadPlus>\n});
    note $knownSession->slurp();

    my $ret = notepad()->loadSession( $knownSession->absolute->canonpath );
    ok $ret, sprintf 'loadSession("%s"): retval = %d', $knownSession->absolute->canonpath, $ret;

    my $nOpen = notepad()->getNumberOpenFiles(0);
    is $nOpen, 2, sprintf 'loadSession(): getNumberOpenFiles(0) = %d', $nOpen;

    my @files = map { $_->[0] } @{ notepad()->getFiles() };
    for my $i (0,1) {
        like $files[$i], qr/\b\Q$src[$i]\E\b/i, sprintf 'loadSession(): getFiles()->[%d][0] = "%s"', $i, $files[$i];
    }
}

#   ->newFile()
#       => create a blank, editable document
#   ->saveAs( $tempfilename )
#       => give it a name (probably have to populate it, too)
#   ->saveAsCopy( $tempfilename2 )
#       => give it a second name (but ->getCurrentFilename() should remain the same)
#   ->open( $tempfilename2 )
#       => bring it in and edit it
#   ->save()
#       => need to make sure that it changes on disk
#   ->saveSession( $tempsessionfilename )
#       => include a subset of files; see whether they all have to be open or not
#   ->saveAllFiles()
#       => _after_ editing both open files
#       => need to make sure that it changes on disk
#   ->closeAllButCurrent()
#       => only one file should be there
#   ->close()
#       => all that remains should be the "new 1" empty buffer

done_testing;