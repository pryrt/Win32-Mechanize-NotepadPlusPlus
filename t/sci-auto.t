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

# DoesNotExist doesn't autovivify
{
    my $err;
    eval { editor()->DoesNotExist; 1; } or do { chomp($err = $@) };
    like $err, qr/\QUndefined subroutine DoesNotExist called at\E/, "autoload: verify error on unknown method";
    note sprintf qq|\tautoload: editor()->DoesNotExist\n\t\t=> err:"%s"\n|, explain $err//'<undef>';
}

# method (getText) does autovivify, or bail out
{
    my $err;
    eval { editor()->getText; 1; } or do { chomp($err = $@) };
    isnt defined($err), "autoload: verify works with known method";
    note sprintf qq|\tautoload: editor()->getText\n\t\t=> err:"%s"\n|, explain $err//'<undef>';

    # after the eval to vivify it, the object should pass can_ok test
    can_ok editor(), qw/getText/
        or BAIL_OUT 'cannot getText even after AUTOLOAD';
}

# method(no-args) -> str        # use getText()
{
    my $txt = editor()->getText();
    ok defined($txt), 'method(): return string';
    my $l = length($txt);
    substr($txt,77) = '...' if $l > 80;
    $txt =~ s/[\r\n]/ /g;
    note sprintf "\teditor()->getText => qq|%s| [%d]\n", $txt, $l;
}

# method(one-arg__w) -> str        # use getLine(1)
{
    # grab expected value from manual SCI_GETLINE
    my $expect = editor()->{_hwobj}->SendMessage_getRawString( $scimsg{SCI_GETLINE}, 1, { trim => 'retval' } );

    # compare to auto-generated method result
    my $line = editor()->getLine(1);
    $line =~ s/\0*$//;
    is $line, $expect, "method(integer): return string";
    $line =~ s/[\r\n]*$//;
    note sprintf qq|\teditor()->getLine(1) => "%s"\n|, $line//'<undef>';
}

# method(wparam=const char*) -> str # use encodedFromUTF8(str)
#   in PythonScript, editor.encodedFromUTF8(u"START\x80") yields 'START\xc2\x80'
{
    my $str = "ThisString";
    my $got = editor()->encodedFromUTF8($str);
    is $got, $str, 'method(string): return string';
    note sprintf qq|\teditor()->encodedFromUTF8("%s") => "%s"\n|, $str//'<undef>', $got//'<undef>';
}

# method(no-args) -> message(no-args) -> most return types
#                               # use clearAll() and undo() as examples
{
    my $ret = editor()->clearAll();
    ok defined $ret, 'method(no-args):message(no-args): return value';
    note "\t", 'editor()->clearAll(): retval = ', $ret//'<undef>';

    (my $txt = editor()->getText()) =~ s/\0*$//;
    my $l = length( $txt );
    is $l, 0, 'method(no-args):message(no-args): return value';
    note "\t", 'editor()->clearAll(): getText() shows zero length = ', $l, "\n";

    sleep(1);
    $ret = editor()->undo();
    ok defined $ret, 'method(no-args):message(no-args): return value';
    note "\t", 'editor()->undo(): retval = ', $ret//'<undef>';

    ($txt = editor()->getText()) =~ s/\0*$//;
    $l = length( $txt );
    ok $l, 'method(no-args):message(no-args): verify previous method had correct effect, not just correct retval';
    note "\t", 'editor()->getText() shows valid length after undo: ', $l, "\n";

}

# method(<unused>, lparam=const char*) -> *     # use setText(str)
{
    my $str = "method(unused, lparam=const char*)";
    my $ret = editor()->setText($str);
    ok defined($ret), 'method(string):message(<unused>, string): return value';
    note sprintf qq|\teditor->setText("%s"): retval = %s\n|, $str, $ret//'<undef>';
    my $got = editor()->getText();
    $got =~ s/[\r\n]*\0*$//;    # remove trailing newlines and nulls
    is $got, $str, 'method(string):message(<unused>, string): verify action';
    note sprintf qq|\teditor->getText() after setText(): text = "%s"\n|, $got//'<undef>';

    # undo changes (avoid ask-for-save during exit)
    editor()->undo();
}

done_testing;