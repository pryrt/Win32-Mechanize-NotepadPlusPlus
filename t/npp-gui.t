########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for GUI manipulation
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;
use Win32;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__npp_msgs; # for %nppm

# setStatusBar
{
    my $ret = notepad()->setStatusBar( $nppm{STATUSBAR_DOC_TYPE}, "I have ruined the status bar: sorry!" );
    ok $ret, 'setStatusBar(nppm{STATUSBAR_DOC_TYPE}): retval'; note sprintf qq(\t=> "%s"\n), $ret // '<undef>';
    <STDIN>;

    # need the current language type and language description to be able to revert the section
    my $langType = notepad()->getLangType();    # get language-type index for the current buffer
    ok $langType, 'getLangType(): retval'; note sprintf qq(\t=> "%s"\n), $langType // '<undef>';
    my $langDesc = notepad()->getLanguageDesc($langType); # not yet implemented
    ok $langDesc, 'getLanguageDesc()'; note sprintf qq(\t=> "%s"\n), $langDesc;
    my $langName = notepad()->getLanguageName($langType); # not yet implemented
    ok $langName, 'getLanguageName()'; note sprintf qq(\t=> "%s"\n), $langName;

    $ret = notepad()->setStatusBar( 'STATUSBAR_DOC_TYPE', $langDesc );
    ok $ret, sprintf 'setStatusBar(STATUSBAR_DOC_TYPE): reset to languageDesc';
}

done_testing;