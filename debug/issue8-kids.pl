#!/usr/bin/env perl

use Win32::Mechanize::NotepadPlusPlus qw/:all/;

notepad->newFile();
sleep(1);
editor->addText("Hello, World");    # I would expect this to add text, but it doesn't; setText() works
sleep(5);
editor->undo();
sleep(1);
notepad->close();