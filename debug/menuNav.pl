use lib './lib';
use lib '../lib';
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__npp_msgs; # for %nppm
use Win32::GuiTest ':FUNC';
use Data::Dumper; $Data::Dumper::Useqq=1;
use strict;
use warnings;

my $menuHandle = notepad()->SendMessage( $nppm{NPPM_GETMENUHANDLE} , 1, 0);     #printf "0x%016x\n", $menuHandle;

# GetMenu(): https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmenu
my $menuID = GetMenu(notepad()->{_hwnd});  #printf "menuID => 0x%016x\n", $menuID;
my $count = GetMenuItemCount($menuID);     #printf "menuItemCount => %d\n", $count;
for my $i ( 0 .. $count-1 ) {
    local $, = ", ";
    #print GetMenuItemInfo( $menuID, $i ), "\n";
    local $, = "";
    #print "\t GetSubMenu = ", GetSubMenu($menuID, $i), "\n";
}
print Dumper recurseMenu($menuID);
exit;

sub recurseMenu {
    my $menuID = shift;
    my $count = GetMenuItemCount( $menuID );
    my @toRecurse;
    my @entries;

    # look through this whole menu first, gathering info
    for my $idx ( 0 .. $count-1 ) {
        my %h = GetMenuItemInfo( $menuID, $idx );
        if( $h{type} eq 'separator') {
            $entries[$idx] = "separator";
        } elsif ( $h{type} eq 'string') {
            $entries[$idx]{text} = $h{text};
            ($entries[$idx]{plaintext} = $h{text}) =~ s/\&//;   # remove the hotkey indicator
            $entries[$idx]{plaintext} =~ s/\t.*//;             # remove anything after TABs (which are usually the shortcut listing)
            my $submenu = GetSubMenu($menuID, $idx);
            if($submenu) {
                $entries[$idx]{MenuID} = $submenu;
                push @toRecurse, $idx;
            } else {
                $entries[$idx]{MenuItemID} = GetMenuItemID( $menuID, $idx );
            }
        } else {
            $entries[$idx] = "!!type: $h{type}!!";
        }
    }

    # now recurse into any that need it:
    for my $idx ( @toRecurse ) {
        $entries[$idx]{submenu} = recurseMenu( $entries[$idx]{MenuID} );
    }

    return [@entries];
}

__END__
perl debug\menuNav.pl > recurse.pm && notepad++ recurse.pm