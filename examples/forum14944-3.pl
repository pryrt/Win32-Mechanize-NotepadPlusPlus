#!/usr/bin/env perl
##########################################
# based on my final PythonScript reply
#   to https://community.notepad-plus-plus.org/topic/14944/macro-complex-instructions
# this Perl version creates both example files,
# then runs the algorithm I originally posted
# It will be treated as a single undo action
##########################################
use warnings;
use strict;
use Win32::Mechanize::NotepadPlusPlus qw/:main/;

$/=("\r\n", "\r", "\n")[ editor->getEOLMode() ];

##########################################
# create data
##########################################

# go to first view, whichever file is currently active in that view
notepad->activateIndex( 0, notepad()->getCurrentDocIndex(0));

# populate "file1" with aaa, bbb, ccc, ...
notepad->newFile();
editor1->addText("aaa$/bbb$/ccc$/ddd$/");

# populate "file2" with the twoline xxx replacement text
notepad->newFile();
notepad->moveCurrentToOtherView();
editor->addText($_.$/) for (
    "Blue Box xxx$/It contains grapes and xxx",
    "Red Box xxx$/It contains tomatoes and xxx",
    "Green Box xxx$/It contains oranges and xxx",
    "Yellow Box xxx$/It contains lemons and xxx"
);

##########################################
# perform algorithm
##########################################

editor1->beginUndoAction();
my $nLines = editor1->getLineCount();
for my $l ( 0 .. $nLines-1 ) {
    local $_ = editor1->getLine($l);
    chomp;
    print STDERR "editor1: #$l = \"$_\"$/";

    editor2->documentEnd();
    my $end2 = editor2->getCurrentPos();
    editor2->documentStart();
    my $start2 = editor2->getCurrentPos();
    print STDERR "editor2: $start2 .. $end2$/";
}
editor1->endUndoAction();
