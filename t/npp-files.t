########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for file and session open/close
########################################################################
# outline:
#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.
#   prepopulate any tempfile locations
#   ->saveCurrentSession($saveUserSession)
#       => this also avoids messing up the user's current Notepad++
#       instance.
#           STOP IMMEDIATELY IF THIS FAILS
#       => attempt to reload that session on exit (END block),
#           and if there's a problem with reload, point user
#           to where the session file is.
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
########################################################################
#   METHODS TO DEFINE, IF POSSIBLE: loadSession()
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;

use Path::Tiny 0.018;

use Win32::Mechanize::NotepadPlusPlus ':main';

ok 1;
done_testing;