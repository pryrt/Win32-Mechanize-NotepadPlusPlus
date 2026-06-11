########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for macro state (v8.3.3 and newer)
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use myTestHelpers;
myTestHelpers::setChildEndDelay(6);

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# version check: skip if before v8.3.3
use version;
my $ver = version->parse( notepad->getNppVersion() );
plan skip_all => "isAutoIndentOn() not implemented in $ver" if $ver < version->parse(v8.3.3);

# default status: should start idle
my $got = notepad->getCurrentMacroStatus();
is $got, '0', 'getCurrentMacroStatus() should be Idle during testing, and return 0';
is $MACROSTATUS{$got//-1}, 'Idle', 'getCurrentMacroStatus() should be Idle during testing, and $MACROSTATUS{$got} should say "Idle"';

# start recording
notepad()->runMenuCommand( "Macro", "Start Recording");
$got = notepad->getCurrentMacroStatus();
is $got, '1', 'getCurrentMacroStatus() should be RecordInProgress during testing, and return 1';
is $MACROSTATUS{$got//-1}, 'RecordInProgress', 'getCurrentMacroStatus() should be RecordInProgress during testing, and $MACROSTATUS{$got} should say "RecordInProgress"';

# do something to record
editor()->selectAll();

# stop recording
notepad()->runMenuCommand( "Macro", "Stop Recording");
$got = notepad->getCurrentMacroStatus();
is $got, '2', 'getCurrentMacroStatus() should be RecordingStopped during testing, and return 2';
is $MACROSTATUS{$got//-1}, 'RecordingStopped', 'getCurrentMacroStatus() should be RecordingStopped during testing, and $MACROSTATUS{$got} should say "RecordingStopped"';


# playback
SKIP: {
    skip 'because the author does not know of a macro that would take long enough to catch it in the act of playing back', 2;
    $got = notepad->getCurrentMacroStatus();
    diag "got => ", $got, " => ", $MACROSTATUS{$got//-1}//'<undef>', "\n";
    is $got, '3', 'getCurrentMacroStatus() should be PlayingBack during testing, and return 2';
    is $MACROSTATUS{$got//-1}, 'PlayingBack', 'getCurrentMacroStatus() should be PlayingBack during testing, and $MACROSTATUS{$got} should say "PlayingBack"';
}

# clear the state: by starting and stopping with no activity, it will go back to "Idle"
editor()->setSel(0,0);   # clears selection
notepad()->runMenuCommand( "Macro", "Start Recording");
notepad()->runMenuCommand( "Macro", "Stop Recording");
$got = notepad->getCurrentMacroStatus();
is $got, '0', 'getCurrentMacroStatus() should be Idle during testing, and return 0';
is $MACROSTATUS{$got//-1}, 'Idle', 'getCurrentMacroStatus() should be Idle during testing, and $MACROSTATUS{$got} should say "Idle"';

done_testing(10);
