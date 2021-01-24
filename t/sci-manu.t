########################################################################
# Verifies various Editor methods that were manually coded, rather
#   than using AUTOLOAD, but are still primarily implementing one
#   underlying scintilla message.
# (AUTOLOAD methods are in sci-auto.t; methods implementing multiple
#   message calls are generally helper functions tested in sci-hlprfns.t)
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

BEGIN { require './tmp.inc' if -f './tmp.inc'; }

use FindBin;
use lib $FindBin::Bin;
use myTestHelpers qw/:userSession dumper/;

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

# findText(flags, start, end, ft):object
#	SCI_FINDTEXT(int searchFlags, Sci_TextToFind *ft):position
{
    my $SCFIND_NONE = 0x0;  # https://github.com/notepad-plus-plus/notepad-plus-plus/blob/92bad0a60ad606b30df9ed97aecf4ff27bb6e967/scintilla/include/Scintilla.iface#L1051
    my $ret = editor()->findText( $SCFIND_NONE, 0, 9999,  "UniqueTextToFind" );
    note "\t", sprintf qq|editor()->findText() should be found this time: explain(retval) = "%s"\n|, explain($ret//'<undef>');
    ok defined($ret), 'editor()->findText() found';
    isa_ok $ret, 'ARRAY';
    my @rarr; @rarr = @$ret if UNIVERSAL::isa($ret, 'ARRAY');
    is scalar(@rarr), 2, 'findText() retval must be 2-element array-reference';
    $rarr[0] = -1 unless defined $rarr[0];
    $rarr[1] = -2 unless defined $rarr[1];
    cmp_ok $rarr[0], '>=', 0, 'findText.start is valid';
    cmp_ok $rarr[1], '>=', $rarr[0], 'findText.end is valid';

    # and for this batch, want it to _not_ be found
    $ret = editor()->findText( $SCFIND_NONE, 0, 9999,  "OtherUniqueText"."ToNotFind" );
    note "\t", sprintf qq|editor()->findText() should not be found this time: explain(retval) = "%s"\n|, explain($ret//'<undef>');
    is $ret, undef, 'editor()->findText() not found this time';
}

#addStyledText(c):int
#	SCI_ADDSTYLEDTEXT(position length, cell *c):<undef>
#getStyledText(start, end):tuple
#	SCI_GETSTYLEDTEXT(<unused>, Sci_TextRange *tr):position
{
    # prepare to undo everything I add
    notepad()->newFile();
    editor()->beginUndoAction();

    # run with single style
    my $condition = "with single style";
    my $start = editor()->getCurrentPos();
    my $ret = editor()->addStyledText("Hello World", 3);
    my $stop = editor()->getCurrentPos();
    note "\t", sprintf qq|editor()->addStyledText() $condition: explain(retval) = "%s"\n|, explain($ret//'<undef>');
    note "\t", sprintf qq|\trange:(%d,%d)\n|, $start, $stop;
    is $stop-$start, 11, "editor()->addStyledText() $condition: added correct number of characters";
    # getStyledText() for verification
    my ($text, $styles) = editor->getStyledText($start, $stop);
    note "\t", sprintf qq|\t"%s" [%s]\n|, $text, join(',',@$styles);
    is $text, "Hello World", "editor()->getStyledText() $condition: string matches addStyledText()";
    is_deeply $styles, [(3)x11], "editor()->getStyledText() $condition: styles all correct";

    # run with address of array
    $condition = "with style list";
    my @a=(1,2,3);
    $start = editor()->getCurrentPos();
    $ret = editor()->addStyledText("One", \@a);
    $stop = editor()->getCurrentPos();
    note "\t", sprintf qq|editor()->addStyledText() $condition: explain(retval) = "%s"\n|, explain($ret//'<undef>');
    note "\t", sprintf qq|\trange:(%d,%d)\n|, $start, $stop;
    is $stop-$start, 3, "editor()->addStyledText() $condition: added correct number of characters";
    # getStyledText() for verification
    ($text, $styles) = editor->getStyledText($start, $stop);
    note "\t", sprintf qq|\t"%s" [%s]\n|, $text, join(',',@$styles);
    is $text, "One", "editor()->getStyledText() $condition: string matches addStyledText()";
    is_deeply $styles, \@a, "editor()->getStyledText() $condition: styles all correct";

    # run with anonymous aref
    $condition = "with anonymous style list";
    $start = editor()->getCurrentPos();
    $ret = editor()->addStyledText("Two", [9,8,7] );
    $stop = editor()->getCurrentPos();
    note "\t", sprintf qq|editor()->addStyledText() $condition: explain(retval) = "%s"\n|, explain($ret//'<undef>');
    note "\t", sprintf qq|\trange:(%d,%d)\n|, $start, $stop;
    is $stop-$start, 3, "editor()->addStyledText() $condition: added correct number of characters";
    # getStyledText() for verification
    ($text, $styles) = editor->getStyledText($start, $stop);
    note "\t", sprintf qq|\t"%s" [%s]\n|, $text, join(',',@$styles);
    is $text, "Two", "editor()->getStyledText() $condition: string matches addStyledText()";
    is_deeply $styles, [9,8,7], "editor()->getStyledText() $condition: styles all correct";

    # check for error
    $condition = "should die with error";
    my $ugh;
    $start = editor()->getCurrentPos();
    eval { editor()->addStyledText("LongWord", [1,2] ); 1 } or do { $ugh = $@ };
    $stop = editor()->getCurrentPos();
    note "\t", sprintf qq|editor()->addStyledText() $condition: explain(retval) = "%s"\n|, explain($ugh//'<undef>');
    note "\t", sprintf qq|\trange:(%d,%d)\n|, $start, $stop;
    is $stop-$start, 0, "editor()->addStyledText() $condition: didn't add any number of characters";

    # undo any changes made
    editor()->endUndoAction();
    editor()->undo();
    notepad()->close();
}

#getTextRange(start, end):str
#	SCI_GETTEXTRANGE(<unused>, Sci_TextRange *tr):position
#   similar to getStyledText, but without the interleaving
{
    # prepare to undo everything I add
    notepad()->newFile();
    editor()->beginUndoAction();

    # add text
    editor()->addStyledText("Hello ", 0);
    my $start = editor()->getCurrentPos();
    my $ret = editor()->addStyledText("World", 0);
    my $stop = editor()->getCurrentPos();
    note "\t", sprintf qq|editor()->appendText(): explain(retval) = "%s"\n|, explain($ret//'<undef>');
    note "\t", sprintf qq|\trange:(%d,%d)\n|, $start, $stop;
    is $stop-$start, 5, "editor()->appendText(): added correct number of characters";

    # getTextRange() for verification
    my $text = editor->getTextRange($start, $stop);
    note "\t", sprintf qq|\teditor()->getTextRange(): retval="%s"\n|, $text;
    is $text, "World", "editor()->getTextRange(): string matches appendText()";

    # undo any changes made
    editor()->endUndoAction();
    editor()->undo();
    notepad()->close();

}

#formatRange(draw, fr):<undef>
#	SCI_FORMATRANGE(bool draw, Sci_RangeToFormat *fr):position
{
    local $@;
    eval {
        use warnings FATAL => 'Win32::Mechanize::NotepadPlusPlus::Editor';
        editor()->formatRange();
        1;
    };
    my $ugh = $@;
    like $ugh, qr/\QformatRange(): not yet implemented.\E/, 'editor()->formatRange()';
    note "\t", sprintf qq|editor()->formatRange(): warning = "%s"\n|, $ugh//'<undef>';
}

# 2020-Feb-21: issue #8 = addText() does not work
#   => make addText a manual sub, rather than auto-generated
{
    # new file
    notepad->newFile();
    select undef,undef,undef,0.25;

    # add known text
    editor->addText("Hello, World");
    select undef,undef,undef,0.25;

    # verify text is added
    my $txt = editor->getText();
    is $txt, "Hello, World", 'addText() coverage per issue #8';
    note "\t", sprintf qq|editor()->setText(): added text = "%s"\n|, $txt//'<undef>';

    # cleanup
    editor->undo();
    notepad->close();
}

# HELPER: getEOLString()        2020-Mar-06
{
    # blank slate
    notepad->newFile();

    # setup for loop
    my @expect = ("\r\n", "\r", "\n");
    my @names = qw/SC_EOL_CRLF SC_EOL_CR SC_EOL_LF/;

    # verify all three EOL modes, both value and string
    for my $mode_name ( @names ) {
        my $set_mode = $SC_EOL{$mode_name};

        editor->setEOLMode($SC_EOL{$mode_name});
        my $mode = editor->getEOLMode();
        is $mode, $SC_EOL{$mode_name}, "editor->getEOLMode() helper method matches $mode_name";

        my $eol  = editor->getEOLString();
        is $eol, shift(@expect), "editor->getEOLString() helper method matches $mode_name"
            or diag sprintf "\tgetEOLString() returned '%s'\n", dumper($eol);
    }

    # cleanup
    editor->setSavePoint(); # pretends like it's been saved, so Notepad++ won't prompt for confirmation
    notepad->close();
}

# HELPER: getFileEndPosition()  2020-Mar-06
{
    # blank slate
    notepad->newFile();

    # with empty file, getFileEndPosition should be 0, I think
    my $pos = editor->getFileEndPosition();
    is $pos, 0, 'getFileEndPosition() helper method: empty file should end at 0';

    # with populated file, getFileEndPosition should be non-zero
    editor->addText("1");
    $pos = editor->getFileEndPosition();
    is $pos, 1, 'getFileEndPosition() helper method: populated file should end beyond 0';

    # cleanup
    editor->setSavePoint(); # pretends like it's been saved, so Notepad++ won't prompt for confirmation
    notepad->close();
}

# HELPER: getTargetText()   2020-Apr-12
#   This test is equivalent creating a file containing "Hello World", then
#   Running the PythonScript
#       editor.setTargetRange(6,11)
#       editor.getTargetText()
#   Or, equivlanently, NppExec gives:
#       ================ READY ================
#       sci_sendmsg SCI_SETTARGETRANGE 6 11
#       SCI_SENDMSG: SCI_SETTARGETRANGE 6 11
#       ================ READY ================
#       sci_sendmsg SCI_GETTARGETTEXT 0 @"<str>"
#       SCI_SENDMSG: SCI_GETTARGETTEXT 0 @"<str>"
#       ================ READY ================
#       echo $(MSG_RESULT) $(MSG_WPARAM) $(MSG_LPARAM)
#       5  World
#   The autogenerated getTargetText didn't properly handle
#       this test, so it was switched to a manual wrapper method,
#       and now passes.
{
    # prep
    notepad->newFile();

    editor->beginUndoAction();

    # add data
    editor->setText("Hello World");
    my $got = editor->getText();
    is $got, "Hello World", 'setText("Hello World") should set text';

    # test
    my $exp = 'World';  # position 6-11
    $got = undef;
    editor->setTargetRange(6,11);
    is editor->getTargetStart, 6, 'getTargetStart() should be 6';
    is editor->getTargetEnd, 11, 'getTargetEnd() should be 11';
    eval { $got = editor->getTargetText(); 1; } or do { $got = "<crash: $@>"; };
    is $got, $exp, 'getTargetText() from (6,11) should be "World"';

    # cleanup
    editor->endUndoAction();
    editor->undo();
    notepad->close();
}

done_testing;
