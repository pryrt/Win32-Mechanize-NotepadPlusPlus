########################################################################
# these tests cover the scintilla helper functions
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;

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
}

# https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/15
# file:///C:/usr/local/apps/notepad++/plugins/PythonScript/doc/scintilla.html#editor.forEachLine

# notepad->forEachLine
#   Need to test that it can iterate thorugh all the lines normally
#   And try one where it the return value will make it increment 0
# do two tests: the first (here) where I test 1, 2, 0, and undef retvals
#   the second (below) where I test the example code
{
    editor->addText("$_\r\n") for 0..5;

    my @state;
    my $callback = sub {
        my ($contents, $lineNumber, $totalLines) = @_;
        #diag sprintf "callback(\"%s\",%s,%s)\n", dumper($contents), $lineNumber, $totalLines;
        push @state, $lineNumber;
        # will return 1 for line0, 2 for line1, 0 for the first line 5, and undef for any other line
        # this tests all the conditions described in the PythonScript docs on forEachLine()
        if(0 == $lineNumber) {
            return 1;
        } elsif(1 == $lineNumber) {
            return 2;
        } elsif (5==$lineNumber and $state[-2]!=$lineNumber) {
            return 0;
        }
        return;
    };

    editor->forEachLine( $callback );
    is_deeply \@state, [0,1,3,4,5,5,6], 'forEachLine state';
    #note sprintf "\tstate = (%s)\n", join ',', @state;

    # cleanup
    editor->setText("");
    notepad->closeAll();
}

# notepad->forEachLine: implement the example code
# which also verifies deleteLine and replaceLine methods
TODO: if(1) {
    local $TODO = "need to implement deleteLine and replaceLine";

    # setup
    my $txt = "keep\nrubbish\nsomething old\nlittle something\nend of file";
    editor->setText($txt);
    (my $exp = $txt) =~ s/something old/something new/;
    $exp =~ s/little something/BIG\r\nSOMETHING/;
    $exp =~ s/rubbish\n//;

    sub testContents {
        my ($contents, $lineNumber, $totalLines) = @_;
        chomp($contents);
printf STDERR "testContents('%s')\n", dumper $contents;
        if($contents eq 'rubbish') {
printf STDERR "\tdelete the rubbish\n";
            eval { editor->deleteLine($lineNumber); 1; } and
            return 0; # stay on same line, because it's deleted
printf STDERR "\terr = '$@'\n";
        } elsif($contents eq 'something old') {
printf STDERR "\tchange the old\n";
            eval{ editor->replaceLine($lineNumber, "something new"); 1; };
printf STDERR "\terr = '$@'\n" if $@;
        } elsif($contents eq 'little something') {
printf STDERR "\tembiggen\n";
            eval{ editor->replaceLine($lineNumber, "BIG\r\nSOMETHING"); 1; };
printf STDERR "\terr = '$@'\n" if $@;
            return 2;   # replaced single with two lines, so need to go the extra line
        }
printf STDERR "\tcontinue\n";
        # could return 1 here, but undef works as well;
        #   note in perl, you _could_ just exit without returning, as in the PythonScript example,
        #   but in perl, that would return the last statement value, which isn't what you want
        return;
    }

    editor->forEachLine(\&testContents);

    my $got = editor->getText();
    is $got, $exp, 'forEachLine example code came out right';
    diag sprintf "final: '%s'\n", dumper $got;

    # cleanup
    editor->setText("");
    notepad->closeAll();
}

notepad->closeAll();

done_testing;

__END__
sub Win32::Mechanize::NotepadPlusPlus::Editor::forEachLine {
    my $self = shift;
    my $fn = shift;
    my $delta = 1;

    for(my $l=0; $l<$self->getLineCount(); $l += $delta ) {
        my $ret = $fn->( $self->getLine($l), $l, $self->getLineCount() );
        $delta = $ret//1;
    }
}
