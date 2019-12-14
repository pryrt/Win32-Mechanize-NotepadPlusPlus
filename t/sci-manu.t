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
    my $propkey = "scimanu.testprop";
    my $strVal = "test1234";
    editor()->setProperty($propkey, $strVal);
    my $value = editor->getProperty($propkey);
    is $value, $strVal, 'editor()->getProperty()';
    note "\t", sprintf qq|editor()->getProperty("%s"): retval = "%s" vs "%s"\n|, $propkey, $value//'<undef>', $strVal;

    my $intVal = 314;
    editor()->setProperty($propkey, $intVal);
    $value = editor->getPropertyInt($propkey);
    cmp_ok $value, '==', $intVal, 'editor()->getPropertyInt()';
    note "\t", sprintf qq|editor()->getPropertyInt("%s"): retval = "%s" vs "%s"\n|, $propkey, $value//'<undef>', $intVal;
}

# editor()->changeInsertion(text)
#   might not be testable without notifications/callbacks
{
    local $@;
    eval {
        use warnings FATAL => 'Win32::Mechanize::NotepadPlusPlus::Editor';
        editor()->changeInsertion("Hello, World!");
        1;
    };
    my $ugh = $@;
    like $ugh, qr/\Qrequires notification and callback implementation\E/, 'editor()->changeInsertion()';
    note "\t", sprintf qq|editor()->changeInsertion("%s"): warning = "%s"\n|, "Hello, World!", $ugh//'<undef>';
}

# findText(flags, start, end, ft):object
#	SCI_FINDTEXT(int searchFlags, Sci_TextToFind *ft):position
{
    my $SCFIND_NONE = 0x0;  # https://github.com/notepad-plus-plus/notepad-plus-plus/blob/92bad0a60ad606b30df9ed97aecf4ff27bb6e967/scintilla/include/Scintilla.iface#L1051
    my $ret = editor()->findText( $SCFIND_NONE, 0, 9999, "UniqueTextToFind" );
    ok $ret, 'editor()->findText()';
    note "\t", sprintf qq|editor()->findText(): explain(retval) = "%s"\n|, explain($ret//'<undef>');
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