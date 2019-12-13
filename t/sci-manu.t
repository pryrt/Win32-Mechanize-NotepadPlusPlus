########################################################################
# Verifies Editor object's AUTOLOAD facility is working correctly
#   (unfortunately, didn't commit the version I had working yesterday
#   at home, so either re-develop or )
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;
use Encode qw'encode';

use FindBin;
use lib $FindBin::Bin;
use myTestHelpers qw/:userSession/;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.
my $EmergencySessionHash;
BEGIN { $EmergencySessionHash = saveUserSession(); }
END { restoreUserSession( $EmergencySessionHash ); }

BEGIN {
    notepad()->closeAll();
    notepad()->open( path($0)->absolute->canonpath() );
}

# editor()->getPropertyInt()
=begin pythonscript

    def test_scintillawrapper_int_string_stringresult(self):
        editor.setProperty('pythonscript.unittest', 'test1234')
        propertyValue = editor.getProperty('pythonscript.unittest')
        editor.setProperty('pythonscript.unittest', '422')
        result = editor.getPropertyInt('pythonscript.unittest', 0)
        self.assertEqual(result, 422)
=cut

{
    1;
}

# editor()->changeInsertion(text)
#   might not be testable without notifications/callbacks
{
    1;
}

# findText(flags, start, end, ft):object
#	SCI_FINDTEXT(int searchFlags, Sci_TextToFind *ft):position
{
    1;
}

#addStyledText(c):int
#	SCI_ADDSTYLEDTEXT(position length, cell *c):<undef>
#getTextRange(start, end):str
#	SCI_GETTEXTRANGE(<unused>, Sci_TextRange *tr):position
#getStyledText(start, end):tuple
#	SCI_GETSTYLEDTEXT(<unused>, Sci_TextRange *tr):position

#formatRange(draw, fr):<undef>
#	SCI_FORMATRANGE(bool draw, Sci_RangeToFormat *fr):position

ok 1;
done_testing;