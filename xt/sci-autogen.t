################################################################################
# verify that Editor.pm::%autogen doesn't try to access messages that don't exist
################################################################################
use 5.010;
use warnings;
use strict;
use Test::More;

use Win32::Mechanize::NotepadPlusPlus qw/:all/;

# __test_autogen is used in the test suite to expose the contents of %autogen
#   for verification purposes.  There is no reason for the end-user to ever use
#   __test_autogen()
my %autogen = Win32::Mechanize::NotepadPlusPlus::Editor::__test_autogen();

# required: every entry in autogen _must_ correspond to a message in %SCIMSG
for my $got (sort keys %autogen) {
    ok exists $SCIMSG{$got}, sprintf "Checking for msg:'%s' in %%SCIMSG", $got//'<undef>';
}

# 'twould be nice: every message in %SCIMSG, except those manually implemented,
#   should be in %autogen
# manually-implemented, thus not in autogen
my @man = qw'
    SCI_ADDTEXT
    SCI_ADDSTYLEDTEXT
    SCI_FINDTEXT
    SCI_GETPROPERTYINT
    SCI_GETSTYLEDTEXT
    SCI_GETTEXTRANGE
    SCI_GETTARGETTEXT
';
# deprecated, thus not in autogen
my @deprecated = qw'
    SCI_GETUSEPALETTE
    SCI_SETUSEPALETTE

    SCI_GETKEYSUNICODE
    SCI_SETKEYSUNICODE

    SCI_GETTWOPHASEDRAW
    SCI_SETTWOPHASEDRAW

    SCI_GETSTYLEBITS
    SCI_GETSTYLEBITSNEEDED
    SCI_SETSTYLEBITS
';
# only implementable with notifications
my @need_notify = qw'
    SCI_CHANGEINSERTION
';
# extras: not actually messages, but in %SCIMSG
my @extras = qw'
    WM_USER
    SCI_START
    SCI_LEXER_START
    SCI_OPTIONAL_START
';
# fully skip the manually-implemented and deprecated messages, and messages that require notifications to work
my $skip = join '|', map { quotemeta } @man, @deprecated, @need_notify, @extras;
# known notes on unimplemented messages
my %note;
$note{SCI_FORMATRANGE} = 'confusing, need to study';
$note{SCI_PROPERTYNAMES} = 'older';
$note{SCI_EOLANNOTATIONCLEARALL}            = 'v794, s4.46';
$note{SCI_EOLANNOTATIONGETSTYLE}            = 'v794, s4.46';
$note{SCI_EOLANNOTATIONGETSTYLEOFFSET}      = 'v794, s4.46';
$note{SCI_EOLANNOTATIONGETTEXT}             = 'v794, s4.46';
$note{SCI_EOLANNOTATIONGETVISIBLE}          = 'v794, s4.46';
$note{SCI_EOLANNOTATIONSETSTYLE}            = 'v794, s4.46';
$note{SCI_EOLANNOTATIONSETSTYLEOFFSET}      = 'v794, s4.46';
$note{SCI_EOLANNOTATIONSETTEXT}             = 'v794, s4.46';
$note{SCI_EOLANNOTATIONSETVISIBLE}          = 'v794, s4.46';
$note{SCI_GETSELECTIONNENDVIRTUALSPACE}     = 'v794, s4.46';
$note{SCI_GETSELECTIONNSTARTVIRTUALSPACE}   = 'v794, s4.46';
$note{SCI_GETTABMINIMUMWIDTH}               = 'v794, s4.46';
$note{SCI_SETTABMINIMUMWIDTH}               = 'v794, s4.46';
$note{SCI_GETTARGETENDVIRTUALSPACE}         = 'v794, s4.46';
$note{SCI_SETTARGETENDVIRTUALSPACE}         = 'v794, s4.46';
$note{SCI_GETTARGETSTARTVIRTUALSPACE}       = 'v794, s4.46';
$note{SCI_SETTARGETSTARTVIRTUALSPACE}       = 'v794, s4.46';
$note{SCI_SETILEXER}                        = 'v794, s4.46';

# do a note() for each SCIMSG element that isn't in autogen and isn't manually implemented
#   thus visible in `prove -vl xt\`, but not in normal testing
for my $msg (sort keys %SCIMSG) {
    next if $msg =~ m{^($skip)$};
    next if exists $autogen{$msg};
    note sprintf "Message exists in %%SCIMSG but not in %%autogenMessage: %-32s\t%s\n",
        "'".($msg//'<undef>')."'",
        exists($note{$msg}) ? "NOTE: ".($note{$msg}//'<undef>') : '';
    ;
}

done_testing();
