use 5.006;
use strict;
use warnings;
#use Test::More tests => 6;
use Carp;

use lib './lib';    # if run from <DIST> directory, `perl debug/sendMessage.pl` will properly see the development libraries in this DIST

use Win32::Mechanize::NotepadPlusPlus ':main';

# instantiate the NPP object
my $npp = notepad(); carp "!!DEBUG!! npp = ", $npp;

# enumerate the scintilla HWNDs; returns the first visible HWND,
#   which is probably one of the editors
my $sci_hwnd = $npp->_debug_FindScintillaHwnds();        carp "!!DEBUG!! sci_hwnd = ", $sci_hwnd;

# start debugging the message sending
$npp->_debug_sendVariousMessages($sci_hwnd);