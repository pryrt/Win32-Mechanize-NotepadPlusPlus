use lib './lib';
use lib '../lib';
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__npp_msgs; # for %nppm
use Win32::GuiTest ':FUNC';
use Data::Dumper; $Data::Dumper::Useqq=1;
use strict;
use warnings;

my $menuHandle = notepad()->SendMessage( $nppm{NPPM_GETMENUHANDLE} , 1, 0);     printf "0x%016x\n", $menuHandle;

# GetMenu(): https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmenu
my $menuID = GetMenu(notepad()->{_hwnd});  printf "menuID => 0x%016x\n", $menuID;
my $count = GetMenuItemCount($menuID);      printf "menuItemCount => %d\n", $count;
for my $i ( 0 .. $count-1 ) {
    local $, = ", ";
    print GetMenuItemInfo( $menuID, $i ), "\n";
    local $, = "";
    print "\t GetSubMenu = ", GetSubMenu($menuID, $i), "\n";
}

