########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for menuCommands
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use Win32;
use Win32::GuiTest 1.64 qw':FUNC !SendMessage';

use FindBin;
use lib $FindBin::Bin;
use myTestHelpers;
myTestHelpers::setChildEndDelay(6);

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;


# menuCommand
{
    my $ret = notepad()->menuCommand('IDM_VIEW_CLONE_TO_ANOTHER_VIEW');
    ok $ret, 'menuCommand("IDM_VIEW_CLONE_TO_ANOTHER_VIEW"): retval from string-param'; note sprintf qq(\t=> "0x%08x"\n), $ret // '<undef>';

    # close the cloned window, which also tests value-based menuCommand...
    $ret = notepad()->menuCommand($NPPIDM{IDM_FILE_CLOSE});
    ok $ret, 'menuCommand(NPPIDM{IDM_FILE_CLOSE}): retval from value-param'; note sprintf qq(\t=> "0x%08x"\n), $ret // '<undef>';
}

# runMenuCommand
{
    # for runMenuCommand, I am going to SHA-256 on active selection; which means I need a selection, and need to know what it is.
    my $expected = 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e';
    my $algorithm = 'SHA-256';

    # 1. create new file
    notepad()->newFile();
    select undef,undef,undef,0.25;

    # 2. add known text
    editor()->{_hwobj}->SendMessage_sendRawString( $SCIMSG{SCI_SETTEXT}, 0, "Hello World" );
    select undef,undef,undef,0.25;

    # 3. select that text
    notepad()->menuCommand('IDM_EDIT_SELECTALL');
    select undef,undef,undef,0.25;

    # 4. run the menu command
    my $ret = notepad()->runMenuCommand( "Tools | $algorithm", 'Generate from selection into clipboard');
    unless(defined $ret) {
        $algorithm = 'MD5';
        $expected = 'b10a8db164e0754105b7a99be72e3fe5';
        $ret = notepad()->runMenuCommand( "Tools | $algorithm", 'Generate from selection into clipboard');
    }
    ok $ret, "runMenuCommand(Tools | $algorithm | Generate from selection into clipboard): retval"; note sprintf qq(\t=> "%s"\n), $ret // '<undef>';

    # 5. paste the resulting text
    notepad()->menuCommand('IDM_EDIT_PASTE');

    # 6. get the resulting textlength and text
    my $len = editor()->{_hwobj}->SendMessage( $SCIMSG{SCI_GETTEXTLENGTH} );    note sprintf qq(\t=> "%s"\n), $len // '<undef>';
    {
        my $txt;
        eval {
            $txt = editor()->{_hwobj}->SendMessage_getRawString( $SCIMSG{SCI_GETTEXT}, $len+1, { trim => 'wparam' } );
        } or do {
            diag "eval(getRawString) = '$@'";
            $txt = '';
        };
        $txt =~ s/[\0\s]+$//;   # remove trailing spaces and nulls
        is $txt, $expected, "runMenuCommand(): resulting $algorithm text"; note sprintf qq(\t%s => "%s"\n), $algorithm, $txt // '<undef>';
    }

    # 7. clear the editor, so I can close without a dialog
    editor()->{_hwobj}->SendMessage_sendRawString( $SCIMSG{SCI_SETTEXT}, 0, "\0" );

    # 8. close
    notepad()->close();
}

# runPluginCommand
#   2020-Apr-03: per issue#30, need to rework the test suite, to make sure caching is working right, etc
#   new outline:
#       * compare ->{_menuID} to getMainMenuHandle
#       * verify Plugins menu exists in main menu
#           * if not, exit
#       * ok ->getPluginMenuHandle()
# new:
SKIP: {
    # won't actually skip until partway through, but by wrapping the whole sequence in
    # the SKIP: block, I can jump out at one or more spots without having to manually control that
    # the only thing i have to do is keep the number of skipped tests correct
    my $r = rand();
    ok 1, "line ".__LINE__.": $r";
    skip "why ".__LINE__, 2 if $r<0.5;
    ok 1, "line ".__LINE__.": $r";
    skip "why ".__LINE__, 1 if $r<0.95;
    ok 1, "line ".__LINE__.": $r";
    warn "die on line ", __LINE__, "\n";
}

# original
{
    # for runPluginCommand, I cannot guarantee the presence of any give plugin, so (until I have the ability to add to menu) try to just do Plugins Admin dialog
    #   some experimenting showed (..., qr/^Plugins Admin$/, 4) as the appropriate args
    my $ret;
    myTestHelpers->setDebugInfo(0);
    runCodeAndClickPopup( sub { $ret = notepad()->runPluginCommand( 'Plugins Admin...') }, qr/^Plugins Admin$/, 4, 1 ); # wait an extra 1s before pushing the button, which makes it more reliable

    if(defined $ret) {
        ok $ret, 'runPluginCommand(Plugins | Plugins Admin...): retval' or diag sprintf qq(\t=> "%s"\n), $ret // '<undef>';
    } else {
        diag "runPluginCommand(Plugins Admin...) didn't work, and I don't know why... Trying alternative";
        my $menuID = notepad()->{_menuID}; note "notepad()->{_menuID} = ", $menuID//'<undef>';
        my $count = GetMenuItemCount( $menuID ); note "GetMenuItemCount() = ", $count // '<undef>';
        my $submenu;
        for my $idx ( 0 .. $count-1 ) {
            my %h = GetMenuItemInfo( $menuID, $idx );
            if( $h{type} eq 'string' ) {
                (my $cleanText = $h{text}) =~ s/(\&|\t.*)//;
                note sprintf "\t%-20s | %s\n", $h{text}, $cleanText;
                $submenu = GetSubMenu($menuID, $idx) if $cleanText eq 'Plugins';
            }
        }
        note sprintf "Plugins submenu #%s#\n", $submenu // '<undef>';
        my $does_have_folder;
        my $does_have_admin;
        if(defined $submenu) {
            note "submenu GetMenuItemCount() = ", my $count = GetMenuItemCount( $submenu ) // '<undef>';
            for my $idx ( 0 .. $count-1 ) {
                my %h = GetMenuItemInfo( $submenu, $idx );
                if( $h{type} eq 'string' ) {
                    (my $cleanText = $h{text}) =~ s/(\&|\t.*)//;
                    note sprintf "\t%-20s | %s\n", $h{text}, $cleanText;
                    $does_have_admin = 1 if $cleanText =~ /Plugins Admin/;
                    $does_have_folder = 1 if $cleanText =~ /Open Plugins Folder/;
                }
            }
        }
        ok !$does_have_admin, 'Plugins | Plugins Admin should not exist, because runPluginCommand(Plugins | Plugins Admin) didnt work'; diag sprintf "\tdoes have admin = %s", $does_have_admin//'<undef>';

        if($does_have_folder) {
            $ret = notepad()->runPluginCommand('Open Plugins Folder...');
            ok $ret, 'runPluginCommand(Plugins | Open Plugins Folder...): retval' or diag sprintf qq(\t=> "%s"\n), $ret // '<undef>';
            diag "Sorry for opening the extra Explorer window. You may close it now.\n";
        }
    }
}

done_testing;
