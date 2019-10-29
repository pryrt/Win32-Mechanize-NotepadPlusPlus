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
    like $err, qr/\QUndefined subroutine DoesNotExist called at\E/, "autoload(editor()->DoesNotExist) expects error";
    note sprintf qq|\tDoesNotExist => err:"%s"\n|, explain $err//'<undef>';
}

# method (getText) does autovivify, or bail out
{
    my $err;
    eval { editor()->getText; 1; } or do { chomp($err = $@) };
    isnt defined($err), "autoload(editor()->getText) expects works";
    note sprintf qq|\tgetText => err:"%s"\n|, explain $err//'<undef>';

    # after the eval to vivify it, the object should pass can_ok test
    can_ok editor(), qw/getText/
        or BAIL_OUT 'cannot getText even after AUTOLOAD';
}

# method(no-args) -> str        # use getText()
{
    my $txt = editor()->getText();
    ok defined($txt), 'editor()->getText() grabbed defined text';
    # note sprintf "\tgetText => qq|%s|\n", explain encode('utf8',$txt//'<undef>');
    my $l = length($txt);
    substr($txt,77) = '...' if $l > 80;
    $txt =~ s/[\r\n]/ /g;
    note sprintf "\tgetText => qq|%s| [%d]\n", $txt, $l;
}

# method(one-arg) -> str        # use getLine(1)
{
    # grab expected value from manual SCI_GETLINE
    my $expect = editor()->{_hwobj}->SendMessage_getRawString( $scimsg{SCI_GETLINE}, 1, { trim => 'retval' } );

    # compare to auto-generated method result
    my $line = editor()->getLine(1);
    $line =~ s/\0*$//;
    is $line, $expect, "getLine(1) grabbed the same as a manual SendMessage retrieval";
    note sprintf qq|\tgetLine(1) => "%s"\n|, $line//'<undef>';
}

done_testing;