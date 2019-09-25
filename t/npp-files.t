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

BEGIN {
    use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;  # for %scimsg
    my $unsaved = 0;
    for my $view (0, 1) {
        my $nb = notepad()->getNumberOpenFiles($view);
        for my $idoc ( 0 .. $nb-1 ) {
            notepad()->activateIndex($view,$idoc);
            $unsaved++ if editor()->{_hwobj}->SendMessage( $scimsg{SCI_GETMODIFY} );
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
our ($saveUserSession, $fnew1, $fnew2);
BEGIN {
    # use tempfiles for the "new" and "save as" files
    $fnew1 = tempfile( TEMPLATE => 'nppNewFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew1->canonpath();
    $fnew2 = tempfile( TEMPLATE => 'nppDupFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew2->canonpath();
    # for the session, use a named session, which I can point out to the user if necessary, or delete if safe.
    $saveUserSession = $fnew1->sibling('EmergencyNppSession.xml'); note $saveUserSession->canonpath(); # don't want to delete the session
}

#   ->saveCurrentSession($saveUserSession)
#       => this also avoids messing up the user's current Notepad++ instance.
#           STOP IMMEDIATELY IF THIS FAILS
#       => attempt to reload that session on exit (END block),
#           and if there's a problem with reload, point user
#           to where the session file is.
{
    my $ret = notepad()->saveCurrentSession( $saveUserSession->canonpath() );
    ok $ret, sprintf 'saveCurrentSession(%s): %d', $saveUserSession->canonpath(), $ret;
    my $stat = $saveUserSession->stat();
    ok $stat->size, sprintf 'saveCurrentSession(): size(file) = %d', $stat->size()
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

END {
    # as last event in test, make sure the session is loaded, and bail out with emergency message if not okay:
    notepad()->loadSession($saveUserSession);
# TODO = need to come up with a way of testing whether the loadSession has been successful.
#   probably make a global $userFiles = [...], and make sure all those files are open here.
    if(1) {
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
    note "does object $saveUserSession still exist? ";
}


#   ->closeAll()
#       => gives a blank slate to work with.
#   ->loadSession()
#       => gets us to a known state with a prebuilt session
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
#   END {
#       ->loadSession($saveUserSession)
#       If file(s) not open, give an error as best I can, and
#           inform the user where his session file should be
#       delete any temp files
#   }


ok 1;
done_testing;