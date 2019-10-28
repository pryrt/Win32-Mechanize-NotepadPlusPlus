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
use myTestHelpers;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# DoesNotExist doesn't autovivify
{
    my $err;
    eval { editor()->DoesNotExist; 1; } or do { chomp($err = $@) };
    like $err, qr/\QUndefined subroutine DoesNotExist called at\E/, "autoload(editor()->DoesNotExist) expects error";
    note sprintf qq|\tDoesNotExist => err:"%s"\n|, explain $err//'<undef>';
}

# getText does autovivify
{

    my $err;
    eval { editor()->getText; 1; } or do { chomp($err = $@) };
    isnt defined($err), "autoload(editor()->getText) expects works";
    note sprintf qq|\tgetText => err:"%s"\n|, explain $err//'<undef>';

    # after the eval to vivify it, the object should pass can_ok test
    can_ok editor(), qw/getText/
        or BAIL_OUT 'cannot getText even after AUTOLOAD';

select STDERR;
$|++;
select STDOUT;
printf STDERR "line#%04d\n", __LINE__;
    my $txt = editor()->getText();
    ok defined($txt), 'editor()->getText() grabbed defined text';
    note sprintf "\tgetText => qq|%s|\n", explain encode('utf8',$txt//'<undef>');
    use Data::Dumper; $Data::Dumper::Useqq++;
    note Dumper $txt;
printf STDERR "line#%04d\n", __LINE__;
    note Dumper editor()->{_hwobj}->SendMessage_getRawString( $scimsg{SCI_GETTEXT}, 100, { trim => 'retval' } );
    # TODO: even here, it seems to be getting the length from the wparam rather than the retval; need to debug this, but out of time for now
}

done_testing;