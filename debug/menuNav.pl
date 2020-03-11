use lib './lib';
use lib '../lib';
use Win32::Mechanize::NotepadPlusPlus ':main %NPPMSG';
use Win32::GuiTest ':FUNC';
use Data::Dumper; $Data::Dumper::Useqq=1;
use strict;
use warnings;
use 5.010;

my $menuHandle = notepad()->SendMessage( $NPPMSG{NPPM_GETMENUHANDLE} , 1, 0);
    printf "GETMENUHANDLE(1): 0x%016x\n", $menuHandle;
    printf "\tID = %d\n", GetMenu($menuHandle);
    printf "\tparent = 0x%016x\n", GetParent($menuHandle);
$menuHandle = notepad()->getMainMenuHandle;
    printf "getMainMenuHandle: 0x%016x\n", $menuHandle;
my $mPluginHandle = notepad()->getPluginMenuHandle;
    printf "getPluginMenuHandle: 0x%016x\n", $mPluginHandle;
    printf "\tID = %d\n", GetMenu($mPluginHandle);
    printf "\tparent = 0x%016x\n", GetParent($mPluginHandle);
printf "%s\n", "note that GETMENUHANDLE doesn't seem to help, because it doesn't seem to give a parentable hWnd, or a MenuID";
printf "%s\n\n", "-"x40;


# GetMenu(): https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmenu
my $menuID = GetMenu(notepad()->{_hwnd});  #printf "menuID => 0x%016x\n", $menuID;
    printf "Main MenuID = 0x%016x\n", $menuID;
my $count = GetMenuItemCount($menuID);     #printf "menuItemCount => %d\n", $count;
for my $i ( 0 .. $count-1 ) {
    local $, = ", ";
    #print GetMenuItemInfo( $menuID, $i ), "\n";
    local $, = "";
    #print "\t GetSubMenu = ", GetSubMenu($menuID, $i), "\n";
}
#print Dumper recurseMenu($menuID);

my $found = findActionInMenu($menuID, qw/Tools MD5 Generate.../) // '<undef>';
print STDERR "ActionID = $found\n";

$found = findActionInMenu($menuID, qw/MD5 Generate.../) // '<undef>';
print STDERR "ActionID = $found\n";

$found = findActionInMenu($menuID, qw/Plugins George/) // '<undef>';
print STDERR "ActionID = $found\n";

$found = findActionInMenu($menuID, 'Show Symbol | Show White Space and TAB') // '<undef>';
print STDERR "ActionID = $found\n";

exit;

sub findActionInMenu {
    my $menuID = shift;
    my ($top, @hier) = @_;
    my $count = GetMenuItemCount( $menuID );
    state $topID = undef;
    $topID = $menuID unless defined $topID;
    state @recurse = ();                            # originally, was a my @recurse, so it went depth-first; by being state-with-shift, it holds its value in recursion, so it becomes a breadth-first

    if($top =~ /\|/) {   # need to split into multiple levels
        print STDERR "found PIPE '|'\n";
        my @tmp = split /\|/, $top;
        s/^\s+|\s+$//g for @tmp;     # trim spaces
        $top = shift @tmp;          # top is really just the first element of the original top
        unshift @hier, @tmp;        # prepend the @hier with the remaining elements of the split top
        print STDERR "new (", join(', ', map { qq/'$_'/ } $top, @hier), ")\n";
    }

    for my $idx ( 0 .. $count-1 ) {
        my %h = GetMenuItemInfo( $menuID, $idx );
        if( $h{type} eq 'string' ) {
            my $realText = $h{text};
            (my $cleanText = $realText) =~ s/(\&|\t.*)//;
            if( $top eq $realText or $top eq $cleanText ) {
                #print STDERR "FOUND($top): $realText => $cleanText\n";
                if( my $submenu = GetSubMenu($menuID, $idx) ) {
                    return findActionInMenu( $submenu, @hier );
                } elsif ( my $action = GetMenuItemID( $menuID, $idx ) ) {
                    #print STDERR "\tthe action ID = $action\n";
                    return $action;
                } else {
                    #print STDERR "\tcouldn't go deeper in the menu\n";
                    return 0;
                }
            }
        }
        # this idx didn't match... but I may need it later (assuming it's a submenu)
        if( my $submenu = GetSubMenu($menuID, $idx) ) {
            push @recurse, $submenu;
        }
    }
    #print STDERR "$menuID# ($top | @hier) wasn't found; try to recurse: (@recurse)\n";
    if($menuID == $topID) { # only try recursion if we're at the top level
        while( my $submenu = shift @recurse ) {
            my $found = findActionInMenu( $submenu, $top, @hier );
            return $found if $found;
        }
        #print STDERR "$menuID# ($top | @hier) wasn't found, even after recusion\n";
    }
    return undef;
}

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
