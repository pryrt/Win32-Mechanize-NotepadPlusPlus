########################################################################
# Verifies Notepad object messages / methods work
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
#   Might rename this file the "npp-buffer" suite, because that way I can group

my $ret = $npp->activateIndex(0,0); # activate view 0, index 0
ok $ret, sprintf 'msg{NPPM_ACTIVATEDOC} ->activateIndex(view,index): %d', $ret;

my $oFile = path('src/Scintilla.h');
$ret = $npp->open(''.$oFile->absolute->canonpath);
ok $ret, sprintf 'msg{NPPM_DOOPEN} ->open("%s""): %d', $oFile->absolute->canonpath, $ret;

#done_testing(); exit;

my $bufferid = $npp->getCurrentBufferID();
ok $bufferid, sprintf 'msg{NPPM_GETCURRENTBUFFERID} ->getCurrentBufferID() = 0x%08x', $bufferid;

my $buff_enc = $npp->getEncoding($bufferid);
ok $buff_enc, sprintf 'msg{NPPM_GETBUFFERENCODING} ->getEncoding(0x%08x) = %d', $bufferid, $buff_enc;

$buff_enc = $npp->getEncoding();
ok $buff_enc, sprintf 'msg{NPPM_GETBUFFERENCODING} ->getEncoding() = %d', $buff_enc;

done_testing();