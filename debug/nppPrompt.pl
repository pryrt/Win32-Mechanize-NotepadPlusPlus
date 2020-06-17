use Win32::Mechanize::NotepadPlusPlus qw/:main/;
#notepad->messageBox("hello world", "title");
print STDERR notepad->prompt("multiline\r\nprompt", 'title', 'default'), "\n";
