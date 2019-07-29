########################################################################
# Verifies Notepad object messages / methods work
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;

use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::Notepad;

my $npp = notepad();

my $bufferid = $npp->getCurrentBufferID();      diag sprintf 'BufferID: 0x%08x', $bufferid;
ok $bufferid, 'msg{NPPM_GETCURRENTBUFFERID} ->getCurrentBufferID()';
# TODO = getEncoding is crashing Notepad++.  Looks like I still have open issues with sending it messages.
#       when I compare to PythonScript=hex(notepad.getCurrentBufferID()), pysc says 0x1a8a4e0c990L ,
#       whereas Perl says 0xffffffffa4e0ccf0, so Perl appears to be missing the upper nibbles
#       Need to look into why that is.  is pysc appending something, or is the Win32::GuiTest::SendMessage clipping to 32bit but perl interprets as 64bit with 32bit-sign-extended?
#my $buff_enc = $npp->getEncoding($bufferid);    diag sprintf 'BufferEncoding() = %d', $buff_enc;
#ok $buff_enc, 'msg{NPPM_GETBUFFERENCODING} ->getEncoding(bufferID)';


done_testing();