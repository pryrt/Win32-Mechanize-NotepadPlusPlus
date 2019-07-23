rem call svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
call h2ph -d . -e Notepad_plus_msgs.h
call sed -e "s/require 'windows.ph'/eval 'sub WM_USER () { 0x400; }' unless defined(\&WM_USER)/" -e "/require 'tchar.ph'/d" -e "/no warnings/d" -e "s/require '_h2ph.*/package Win32::Mechanize::NotepadPlusPlus::__npp_msgs;/" Notepad_plus_msgs.ph > __npp_msgs.pm
@echo __npp_msgs.pm eventually needs to go to a different path...
perl -e "use warnings; use strict; BEGIN { require './__npp_msgs.pm'; }; print STDERR Win32::Mechanize::NotepadPlusPlus::__npp_msgs::WM_USER;"