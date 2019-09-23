########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for bufferID-based functionality
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;

use Path::Tiny 0.018;

use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::Notepad;

my $npp = notepad();

# while looking at some of the bufferID related methods, I think the sequence I am going
#   to need:
#   0. activate the primary view, index 0 ->activateIndex(0,0)
#   1. open three files
#   2. move one of those three to the second view
#   3. use activateIndex() to cycle through the two in the first view and the one in the second view; probably have to cycle through them all, and use getCurrentDocIndex or something to determine which are the files under test (so that I don't interfere with other files that the user already had open)
#   As I go through those, I'll probably see more of the messages that I'll need for that test sequence.

# activate primary view, index 0, so that I'm sure of active view
my $ret = $npp->activateIndex(0,0); # activate view 0, index 0
ok $ret, sprintf 'msg{NPPM_ACTIVATEDOC} ->activateIndex(view,index): %d', $ret;

my @opened;
foreach ( 'src/Scintilla.h', 'src/convertHeaders.pl' ) {
    # open the file
    my $oFile = path($_)->absolute->canonpath;
    note "oFile = ", $oFile, "\n";
    $ret = $npp->open($oFile);
    ok $ret, sprintf 'msg{NPPM_DOOPEN} ->open("%s"): %d', $oFile, $ret;

    # getCurrentBufferID
    my $bufferid = $npp->getCurrentBufferID();
    ok $bufferid, sprintf 'msg{NPPM_GETCURRENTBUFFERID} ->getCurrentBufferID() = 0x%08x', $bufferid;

    # getCurrentDocIndex
    my $docindex = $npp->getCurrentDocIndex(0);
    ok $docindex, sprintf 'msg{NPPM_GETCURRENTDOCINDEX} ->getCurrentDocIndex() = %d', $docindex;

    # getCurrentView
    my $myview = $npp->getCurrentView();
    is $myview, 0, sprintf 'msg{NPPM_GETCURRENTVIEW} ->getCurrentView() = %d', $myview;

    # getCurrentScintilla
    my $myscint = $npp->getCurrentScintilla();
    is $myscint, 0, sprintf 'msg{NPPM_GETCURRENTSCINTILLA} ->getCurrentScintilla() = %d', $myscint;

    # moveCurrentToOtherView    => need to do this to verify getCurrentView/getCurrentScintilla can properly recognize either view
    $ret = $npp->moveCurrentToOtherView();
    is $ret, 1, sprintf 'menucmd{IDM_VIEW_GOTO_ANOTHER_VIEW} ->moveCurrentToOtherView() = %d', $ret;

    # getCurrentView
    $myview = $npp->getCurrentView();
    is $myview, 1, sprintf 'msg{NPPM_GETCURRENTVIEW} ->getCurrentView() = %d (should be in other)', $myview;

    # getCurrentScintilla
    $myscint = $npp->getCurrentScintilla();
    is $myscint, 1, sprintf 'msg{NPPM_GETCURRENTSCINTILLA} ->getCurrentScintilla() = %d (should be in other)', $myscint;

    # return to first view
    $ret = $npp->moveCurrentToOtherView();
    is $ret, 1, sprintf 'menucmd{IDM_VIEW_GOTO_ANOTHER_VIEW} ->moveCurrentToOtherView() = %d (return to first)', $ret;

    # getCurrentFilename
    my $rfile = $npp->getCurrentFilename();
    like $rfile, qr/\Q$oFile\E/, sprintf 'msg{NPPM_GETFULLPATHFROMBUFFERID} ->getCurrentFilename() = "%s"', $rfile;

    # also getBufferFilename
    my $bfile = $npp->getBufferFilename();
    like $bfile, qr/\Q$oFile\E/, sprintf 'msg{NPPM_GETFULLPATHFROMBUFFERID} ->getBufferFilename(0x%08x) = "%s"', $bufferid, $bfile;

    # getCurrentLang
    my $mylang = $npp->getCurrentLang();
    ok $mylang, sprintf 'msg{NPPM_GETCURRENTLANGTYPE} ->getCurrentLang() = %d', $mylang;

    push @opened, {oFile => $oFile, bufferID => $bufferid, docIndex => $docindex, view=>0, rFile => $rfile, myLang => $mylang };
}

# activateBufferID
{
    my $ret = $npp->activateBufferID( $opened[1]{bufferID} );
    ok $ret, sprintf '->activateBufferID(0x%08x) = %d', $opened[1]{bufferID}, $ret;
    my $rFile = $npp->getCurrentFilename();
    my $oFile = $opened[1]{oFile};
    like $rFile, qr/\Q$oFile\E/, sprintf '->activateBufferID() verify correct file active';
}

# activateFile
{
    my $ret = $npp->activateFile( $opened[0]{oFile} );
    ok $ret, sprintf '->activateFile(%s) = %d', $opened[0]{oFile}, $ret;
    my $rFile = $npp->getCurrentFilename();
    my $oFile = $opened[0]{oFile};
    like $rFile, qr/\Q$oFile\E/, sprintf '->activateFile() verify correct file active';
}

# getFiles
{
    my $tuples = $npp->getFiles();
    my $found = '';
    $found .= join("\x00", '', @{$_}[3,2,0])    for @$tuples;
    foreach my $h ( @opened ) {
        my $match = join("\x00", '', @{$h}{qw/view docIndex oFile/});
        like $found, qr/\Q$match\E/, sprintf "->getFiles(): look for %s", explain($match);
    }
}

# getLangType: similar to getCurrentLang, but needs bufferID; TODO = compare to the $mylang result (propagate thru array to here)
{
    for my $h (@opened) {
        my $lang = $npp->getLangType($h->{bufferID});
        is $lang, $h->{myLang}, sprintf 'msg{NPPM_GETBUFFERLANGTYPE} ->getLangType(0x%08x) = %d', $h->{bufferID}, $lang;
        TODO: {
            local $TODO = "need to auto-map language integer to language name (and maybe vice versa)";
            my $langName;
            like $langName, qr/^.+$/, sprintf 'LanguageName(%d) = "%s"', $lang, $langName // '<undef>';
        }

    }
}

# setCurrentLang, setLangType
{
    my $keep = $npp->getLangType();
    my $ret = $npp->setCurrentLang(7);
    my $rdbk = $npp->getCurrentLang();
    is $rdbk, 7, sprintf 'msg{NPPM_SETCURRENTLANGTYPE} ->setCurrentLang(%d): %d', 7, $rdbk;

    $ret = $npp->setLangType(5);
    $rdbk = $npp->getCurrentLang();
    is $rdbk, 5, sprintf 'msg{NPPM_SETCURRENTLANGTYPE} ->setLangType(%d, nobuffer): %d', 5, $rdbk;

    $ret = $npp->setCurrentLang(3, $npp->getCurrentBufferID );
    $rdbk = $npp->getCurrentLang();
    is $rdbk, 3, sprintf 'msg{NPPM_SETBUFFERLANGTYPE} ->setLangType(%d, 0x%08x): %d', 3, $npp->getCurrentBufferID, $rdbk;

    $ret = $npp->setCurrentLang($keep);
    $rdbk = $npp->getCurrentLang();
    is $rdbk, $keep, sprintf 'msg{NPPM_SETCURRENTLANGTYPE} ->setCurrentLang(keep=%d): %d', $keep, $rdbk;

}

# getEncoding
{
    my $buff_enc = $npp->getEncoding($opened[0]{bufferID});
    ok $buff_enc, sprintf 'msg{NPPM_GETBUFFERENCODING} ->getEncoding(0x%08x) = %d', $opened[0]{bufferID}, $buff_enc;

    $buff_enc = $npp->getEncoding();
    ok $buff_enc, sprintf 'msg{NPPM_GETBUFFERENCODING} ->getEncoding() = %d', $buff_enc;
}

# getFormatType setFormatType
{
    my $keep = $npp->getFormatType();
    my $rdbk = $npp->getFormatType();
    cmp_ok $rdbk, '>', -1, sprintf 'msg{NPPM_GETBUFFERFORMAT} ->getFormatType()=%d (DEFAULT)',  $rdbk;

    my $ret = $npp->setFormatType(1);   # skip optional bufferid
    my $rdbk = $npp->getFormatType();
    is $rdbk, 1, sprintf 'msg{NPPM_GETBUFFERFORMAT} ->setFormatType(%d): getFormatType()=%d', 1, $rdbk;

    $ret = $npp->setFormatType(2);   # skip optional bufferid
    $rdbk = $npp->getFormatType();
    is $rdbk, 2, sprintf 'msg{NPPM_GETBUFFERFORMAT} ->setFormatType(%d): getFormatType()=%d', 2, $rdbk;

    $ret = $npp->setFormatType($keep, $npp->getCurrentBufferID);   # include optional bufferid
    $rdbk = $npp->getFormatType();
    is $rdbk, $keep, sprintf 'msg{NPPM_GETBUFFERFORMAT} ->setFormatType(%d, 0x%08x): %d', $keep, $npp->getCurrentBufferID, $rdbk;

}

# loop through and close the opened files
while(my $h = pop @opened) {
    $npp->activateIndex(0, $h->{docIndex});
    $npp->close();
}

$npp->activateIndex(0,0); # activate view 0, index 0

done_testing();