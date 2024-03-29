package myTestHelpers;
use 5.010;
use strict;
use warnings;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/nppPath.inc'; require $f if -f $f; }

use Win32::GuiTest qw/:FUNC/;
use Exporter 5.57 qw/import/;
use Test::More;
use POSIX ":sys_wait_h";

use Path::Tiny 0.058 qw/path tempfile/; # 0.018 needed for rootdir and cwd; 0.058 needed for sibling

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;  # for %SCIMSG

=head1 NAME

myTestHelpers

=head1 DESCRIPTION

These functions help with my test suite.

Items starting with C<:> are import tags.
Items starting with C<myTestHelpers::> cannot be exported, and must always be called
fully qualified.

=over

=item runCodeAndClickPopup( sub{...}, $regex, $n )

The C<sub{...}> contains the code that will spawn a dialog box.

The C<$regex> needs to match the title of the dialog, like C<qr/^MyTitle$/>.

The C<$n> indicates which button needs to be pressed (0 means the first button).

    runCodeAndClickPopup( sub { fakeMessageBox(title=>'MyTitle') }, qr/^MyTitle$/, 0 );

=back

=cut

BEGIN {
    if(exists $ENV{HARNESS_PERL_SWITCHES} ){
        *runCodeAndClickPopup = \&__devel_cover__runCodeAndClickPopup;
    } else {
        *runCodeAndClickPopup = \&__runCodeAndClickPopup;
    }
}

=over

=item   myTestHelpers::setChildEndDelay($sec)

Some tests, when using C<runCodeAndClickPopup>, need an extra delay
before closing the child process (some sort of race condition which
I haven't figured out); you can use this function to set a delay
for child processes that goes into an END block (to avoid ending the
child too early).

=back

=cut

my $_END_DELAY = 0;
sub setChildEndDelay($) {
    $_END_DELAY = shift;
}

# the child process created in runCodeAndClickPopup() is exiting too quickly,
# causing a race condition; add a delay at END if it's not the master process
my $_savePID;
BEGIN { $_savePID = $$; }
END   { sleep($_END_DELAY) if $_savePID and $$ != $_savePID; }

our @EXPORT_OK = qw/runCodeAndClickPopup saveUserSession restoreUserSession wrapGetLongPathName setShortcutMapper dumper/;
our @EXPORT = qw/runCodeAndClickPopup/;
our %EXPORT_TAGS = (
    userSession => [qw/saveUserSession restoreUserSession/],
    all => [@EXPORT_OK],
);
my $IAMCHILDDONOTRESTORE;

my $DEBUG_INFO = 0;

=over

=item   myTestHelpers::setDebugInfo($flag)

If $flag is true, myTestHelpers will print additional debug information.

=back

=cut

sub setDebugInfo { shift if $_[0] eq __PACKAGE__; $DEBUG_INFO = shift; }

# have to fork to be able to respond to the popup, because $cref->() holds until the dialog goes away
#   unfortunately, Devel::Cover doesn't work if threads are involved.
#   The BEGIN block above figures out how to detect that we're running under Devel::Cover, and take an alternate test-flow
sub __runCodeAndClickPopup {
    my ($cref, $re, $n, $xtraDelay) = @_;
    $xtraDelay ||= 0;

    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        my $f = WaitWindowLike(0, $re, undef, undef, 3, 10);    # parent, title, class, id, depth, wait
        my $p = GetParent($f);
        if($DEBUG_INFO) {
            note "runCodeAndClickPopup(..., /$re/, n:$n, delay:$xtraDelay): ", scalar(localtime), "\n";
            note sprintf qq|\tfound: %d t:"%s" c:"%s"\n\tparent: %d t:"%s" c:"%s"\n|,
                $f, GetWindowText($f), GetClassName($f),
                $p, GetWindowText($p), GetClassName($p),
                ;
        }
        # Because localization, cannot assume YES button will match qr/\&Yes/
        #   instead, assume $n-th child of spawned dialog is always the one that you want

        WaitWindowLike($f, undef, qr/^Button$/, undef, 2, 5);   # parent, title, class, id, depth, wait -- wait up to 5s for Button
        my @buttons = FindWindowLike( $f, undef, qr/^Button$/, undef, 2);   # then list all the buttons
        if($DEBUG_INFO) {
            note sprintf "\tbutton:\t%d t:'%s' c:'%s' id=%d vis:%d grey:%d chkd:%d\n", $_,
                    GetWindowText($_), GetClassName($_), GetWindowID($_),
                    IsWindowVisible($_), IsGrayedButton($_), IsCheckedButton($_)
                for grep { $_ } @buttons;
        }
        if($n>$#buttons) {
            diag sprintf "You asked to click button #%d, but there are only %d buttons.\n", $n, scalar @buttons;
            diag sprintf "clicking the first (#0) instead.  Good luck with that.\n";
            $n = 0;
            for my $i (0..30) {
                my @c = map { $_//'' } caller($i);
                last unless @c;
                print "caller($i): ", join(', ', @c), $/;
            }
        }

        my $h = $buttons[$n] // 0;
        my $id = GetWindowID($h);
        if($DEBUG_INFO) { note sprintf "\tCHOSEN:\t%d t:'%s' c:'%s' id=%d\n", $h, GetWindowText($h), GetClassName($h), $id; }
        _mysleep_ms($xtraDelay*1000) if $xtraDelay;

        # first push to select, second push to click
        PushChildButton( $f, $id, 0.5 ) for 1..2;
        if($DEBUG_INFO) { sleep 1; }
        $IAMCHILDDONOTRESTORE = 1;
        exit;   # terminate the child process once I've clicked
    } else {            # parent
        undef $IAMCHILDDONOTRESTORE;
        $cref->(); # run the process
        my $t0 = time;
        while(waitpid(-1, WNOHANG) > 0) {
            last if time()-$t0 > 30;        # no more than 30sec waiting for end
        }
    }
}

sub __devel_cover__runCodeAndClickPopup {
    my ($cref, $re, $n) = @_;
    diag "Running in coverage / Devel::Cover mode\n";
    diag "\n\nYou need to click the ${n}th button in the dialog which should appear soon\n\n";
    diag "caller(0): ", join ';', map {$_//'<undef>'} caller(0);
    $cref->();
}

=over

=item   :userSession

=item   saveUserSession()

=item   restoreUserSession()

    BEGIN { $EmergencySessionHash = saveUserSession(); }
    END { restoreUserSession( $EmergencySessionHash ); }

This pair of functions can be used in BEGIN/END blocks to ensure that
the user session is properly saved at the start of test, and restored
when test is over, so that the user doesn't notice a change in his
session.

=back

=cut

sub _mysleep_ms($) {
    my $t = abs(shift)/1000;
    if($t < 5) {
        select(undef, undef, undef, $t);
    } else {
        sleep($t);
    }
}

sub saveUserSession {
    my ($saveUserFileList, $saveUserSession);
    my $unsaved = 0;
    for my $view (0, 1) {
        _mysleep_ms(1000);      # 400-500ms required; use 1000 for guardband
        #printf STDERR "__%04d__ v#%d\n", __LINE__, $view;
        my $nbView = ($VIEW{PRIMARY_VIEW}, $VIEW{SECOND_VIEW})[$view];
        my $nb = notepad()->getNumberOpenFiles($nbView);
        for my $idoc ( 0 .. $nb-1 ) {
            #printf STDERR "__%04d__ i#%d\n", __LINE__, $idoc;
            notepad()->activateIndex($view,$idoc);
            _mysleep_ms(100);
            $unsaved++ if editor()->{_hwobj}->SendMessage( $SCIMSG{SCI_GETMODIFY} );
            push @$saveUserFileList, notepad()->getCurrentFilename();
        }
    }
    if($unsaved) {
        my $err = "\n"x4;
        $err .= sprintf "%s\n", '!'x80;
        $err .= sprintf "You have %d unsaved file%s in Notepad++!\n", $unsaved, ($unsaved>1)?'s':'';
        $err .= sprintf "Please save or close %s, then re-run the module test or installation.\n", ($unsaved>1)?'them':'it';
        $err .= sprintf "%s\n", '!'x80;
        $err .= "\n"x4;
        diag($err);
        BAIL_OUT('Unsaved Files: Please read the message between the !!!-lines.');
    }

    $saveUserSession = tempfile('XXXXXXXX')->sibling('EmergencyNppSession.xml');

    my $ret = notepad()->saveCurrentSession( $saveUserSession->canonpath() );
    note sprintf 'saveCurrentSession("%s"): retval = %d', $saveUserSession->canonpath(), $ret;
    my $size = $saveUserSession->is_file ? $saveUserSession->stat()->size : 0;
    note sprintf sprintf 'saveCurrentSession(): size(file) = %d', $size;
    if(!$size) {
        my $err = "\n"x4;
        $err .= sprintf "%s\n", '!'x80;
        $err .= sprintf "I could not save your session for you!\n";
        $err .= sprintf "Because of this, I am not willing to continue running the test suite,.\n";
        $err .= sprintf "as I may not be able to restore your files.\n";
        $err .= sprintf "\n";
        $err .= sprintf "Please close all your files, and try to re-run the module test or installation\n";
        $err .= sprintf "%s\n", '!'x80;
        $err .= "\n"x4;
        diag($err);
        BAIL_OUT('Could not save session.  Please read the message between the !!!-lines.');
    };

    note "saveUserSession: ", $saveUserSession->canonpath(); # don't want to delete the session
    return { session => $saveUserSession, list => $saveUserFileList };

}

sub restoreUserSession {
    my $h = shift;
    my $saveUserSession = $h->{session};
    my $saveUserFileList = $h->{list};

    # don't restore from child process
    return if $IAMCHILDDONOTRESTORE;

    # in case any are left open, close them
    notepad()->closeAll;

    # should load just the user's files
    notepad()->loadSession($saveUserSession->absolute->canonpath);

    # check for any missing files
    my $missing = 0;
    for my $f ( @$saveUserFileList ) {
        ++$missing unless notepad()->activateFile($f) or $f =~ /^new \d/;
    }
    if($missing) {
        my $err = "\n"x4;
        $err .= sprintf "%s\n", '!'x80;
        $err .= sprintf "I could not restore your session for you!\n";
        $err .= sprintf "It should be saved in \"%s\".\n", $saveUserSession->absolute->canonpath;
        $err .= sprintf "Feel free to try to File > Load Session... for that file\n";
        $err .= sprintf "\n";
        $err .= sprintf "Sorry for any inconvenience.  I tried.\n";
        $err .= sprintf "%s\n", '!'x80;
        $err .= "\n"x4;
        diag $err;
        BAIL_OUT(sprintf 'File > Load Session... > "%s"', $saveUserSession->absolute->canonpath);
    }

    # only delete the file if the session has been successfully loaded.
    $saveUserSession->remove();
    note "\n\nrestoreUserSession(): Verified user session files re-loaded.\n\n";
}

=over

=item   wrapGetLongPathName()

    my $long = wrapGetLongPathName( $short );

The Win32::GetLongPathName() occasionally/frequently returns '' if it
is used in the test suite; I am hoping this wrapper over the kernel32.dll function
doesn't have that same problem.

=back

=cut

use Win32::API;
BEGIN {
    Win32::API::->Import("kernel32","DWORD GetLongPathNameA( LPCWSTR lpszShortPath, LPWSTR lpszLongPath, DWORD cchBuffer )") or die "GetLongPathNameA: $^E";  # uncoverable branch true
}

sub wrapGetLongPathName {
    my $inPath = shift;
    my $lpszShortPath = $inPath; #'\\\\?\\' . $inPath;        # prepend literal \?\ to path to remove 260-character limit
    my ($lpszLongPath, $cchBuffer) = ("",0);
    my $ret = GetLongPathNameA( $lpszShortPath, $lpszLongPath, $cchBuffer);
    $lpszLongPath = "\0" x ($ret ? $ret : 1024);
    $cchBuffer = $ret ? $ret : 1024;
    $ret = GetLongPathNameA( $lpszShortPath, $lpszLongPath, $cchBuffer );
    $lpszLongPath =~ s/\0*$//g;   # trim trailing NULs
    #printf STDERR "%-07d # GetLongPathNameA( '%s', '%s', %s ) = %s\n", map $_//'<undef>', 0+$ARGV[0], $lpszShortPath, $lpszLongPath, $cchBuffer, $ret;
    return $lpszLongPath;
}

=over

=item setShortcutMapper

    setShortcutMapper($tab, $entry, $ctrl, $alt, $shift, $char);

Will use the Shortcut Mapper on tab $tab to set $entry's shortcut to $ctrl + $alt + $shift + $char.

=back

=cut

sub setShortcutMapper {
    my ($tab, $entry, $ctrl, $alt, $shift, $char) = @_;
    print STDERR "setShortcutMapper($tab, $entry, $ctrl, $alt, $shift, $char)\n";
setDebugInfo(1);
    #runCodeAndClickPopup( sub {
    #    notepad->menuCommand( $NPPIDM{IDM_SETTING_SHORTCUT_MAPPER} );
    #    sleep(1);
    #    print "\ttab:$_\n" for GetTabItems(529272);
    #} , qr/^Shortcut mapper$/ , 3 );

    # duplicate the code from runCodeAndClickPopup, then customize to select the right tab and entry, then set the shortcut, before exiting
    my ($re, $nModify, $nClose, $xtraDelay) = (qr/^Shortcut mapper$/, 0, 3, 1);
    $xtraDelay ||= 0;

    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        my $f = WaitWindowLike(0, $re, undef, undef, 3, 10);    # parent, title, class, id, depth, wait
        my $p = GetParent($f);
        if($DEBUG_INFO) {
            note "similar to runCodeAndClickPopup(..., /$re/, nModify:$nModify nClose:$nClose, delay:$xtraDelay): ", scalar(localtime), "\n";
            note sprintf qq|\tfound: %d t:"%s" c:"%s"\n\tparent: %d t:"%s" c:"%s"\n|,
                $f, GetWindowText($f), GetClassName($f),
                $p, GetWindowText($p), GetClassName($p),
                ;
        }
        # Because localization, cannot assume YES button will match qr/\&Yes/
        #   instead, assume $n-th child of spawned dialog is always the one that you want

        # Bring Shortcut Mapper to the foreground
        SetForegroundWindow($p);
        SetForegroundWindow($f);

        # Select the ${tab}th tab
        WaitWindowLike($f, undef, qr/^SysTabControl32$/, undef, 2);   # parent, title, class, id, depth, wait -- wait up to 2s for Button
        my $tabctrl = (FindWindowLike( $f, undef, qr/^SysTabControl32$/, undef, 2))[0];   # then grab the tabctrl
        if($DEBUG_INFO) { print STDERR __LINE__, "\ttab:$_\n" for GetTabItems($tabctrl); }
        SelTabItem($tabctrl, $tab); # select the nth tab from the ShortcutMapper tabbar
        _mysleep_ms(500);

        # activate the BABYGRID control
        my $babygrid = (FindWindowLike( $f, undef, qr/^BABYGRID$/, undef, 2))[0];
        if( defined $babygrid ) {
            SetForegroundWindow($babygrid);
        } else {
            # hit TAB 5x to get to the top of the GRID
            note "want to have GRID selected...\n" if $DEBUG_INFO;
            #SendKeys("{TAB}{PAUSE 1000}" x 5);
            SendKeys("+{TAB}{PAUSE 1000}");
            note "should have GRID selected...\n" if $DEBUG_INFO;
        }
        _mysleep_ms(500);

        # Grab the list of buttons,and save the Modify and Close buttons.
        WaitWindowLike($f, undef, qr/^Button$/, undef, 2, 2);   # parent, title, class, id, depth, wait -- wait up to 2s for Button
        my @buttons = FindWindowLike( $f, undef, qr/^Button$/, undef, 2);   # then list all the buttons
        if($DEBUG_INFO) {
            note sprintf "\tbutton:\t%d t:'%s' c:'%s' id=%d vis:%d grey:%d chkd:%d\n", $_,
                    GetWindowText($_), GetClassName($_), GetWindowID($_),
                    IsWindowVisible($_), IsGrayedButton($_), IsCheckedButton($_)
                for grep { $_ } @buttons;
        }
        my $modifyButton = $buttons[$nModify] // 0;
        my $modifyButtonID = GetWindowID($modifyButton);
        my $closeButton = $buttons[$nClose] // 0;
        my $closeButtonID = GetWindowID($closeButton);
        if($DEBUG_INFO) {
            for ($modifyButton, $closeButton) {
                note sprintf "\tkeep button:\t%d t:'%s' c:'%s' id=%d vis:%d grey:%d chkd:%d\n", $_,
                    GetWindowText($_), GetClassName($_), GetWindowID($_),
                    IsWindowVisible($_), IsGrayedButton($_), IsCheckedButton($_)
                ;
            }
        }

        # push the MODIFY button
        if($DEBUG_INFO) { note sprintf "\tMODIFY BUTTON:\t%d t:'%s' c:'%s' id=%d\n", $modifyButton, GetWindowText($modifyButton), GetClassName($modifyButton), $modifyButtonID; }
        sleep($xtraDelay) if $xtraDelay;
        PushChildButton( $f, $modifyButtonID, 0.5 ) for 1..2;   # first push to select, second push to click
note "pushed MODIFY\n";
        _mysleep_ms(500);

        # find the MODIFY SHORTCUT dialog
        my $shortcutWindow = WaitWindowLike(0, qr/^Shortcut$/, undef, undef, 3, 2);   # parent, title, class, id, depth, wait -- wait up to 2s for Button
        if($DEBUG_INFO) {
            for ($shortcutWindow) {
                note sprintf "\tmodify window:\t%d t:'%s' c:'%s'\n", $_,
                    GetWindowText($_), GetClassName($_)
                ;
            }
        }
        _mysleep_ms(500);

        # find the children of the MODIFY SHORTCUT dialog
        my ($btnCtrl, $btnAlt, $btnShift, $comboBox, $btnOk);
        for (GetChildWindows($shortcutWindow)) {
            if($DEBUG_INFO) {
                note sprintf "%d\tSHORTCUT child(%d) = t:'%s' c:'%s' id=%d vis:%d grey:%d chkd:%d\n", __LINE__, $_,
                        GetWindowText($_), GetClassName($_), GetWindowID($_),
                        IsWindowVisible($_), IsGrayedButton($_), IsCheckedButton($_)
                ;
            }
            $btnOk    = $_ if GetWindowID($_) == 1;
            $btnCtrl  = $_ if GetWindowID($_) == 5001;
            $btnAlt   = $_ if GetWindowID($_) == 5002;
            $btnShift = $_ if GetWindowID($_) == 5003;
            $comboBox = $_ if GetWindowID($_) == 5004;
        }
        note sprintf "\tOK:%d CTRL:%d ALT:%d SHIFT:%d COMBO:%d\n", $btnOk, $btnCtrl, $btnAlt, $btnShift, $comboBox;
        _mysleep_ms(500);

        # TODO: Set Shortcut keys
note "CTRL:  ", IsCheckedButton($btnCtrl);
        $ctrl  ? CheckButton($btnCtrl)  : UnCheckButton($btnCtrl);
note "CTRL:  ", IsCheckedButton($btnCtrl);
        _mysleep_ms(100);
note "ALT:   ", IsCheckedButton($btnAlt);
        $alt   ? CheckButton($btnAlt )  : UnCheckButton($btnAlt);
note "ALT:   ", IsCheckedButton($btnAlt);
        _mysleep_ms(100);
note "SHIFT: ", IsCheckedButton($btnShift);
        $shift ? CheckButton($btnShift) : UnCheckButton($btnShift);
note "SHIFT: ", IsCheckedButton($btnShift);
        _mysleep_ms(100);
note "modifiers done\n";
        SelComboItemText($comboBox, $char);
note "character done\n";
        _mysleep_ms(1000);
note "done\n";

        # Push OK
#        SetFocus($btnOk);
#note "focused\n";
#        _mysleep_ms(5000);

        #PushChildButton( $shortcutWindow, 1, 1 ) for 1..2;   # first push to select, second push to click
        #SendKeys("{ENTER}"); note "hit ENTER\n";
        #CheckButton( $btnOk );
PushButton("OK"); note "PushButton OK\n"; _mysleep_ms(100);
#PushButton("OK"); note "PushButton OK\n"; _mysleep_ms(100);

sleep(5);   # done with the MODIFY dialog

# print __LINE__, "\ttab:$_\n" for GetTabItems($f);
# for my $ch (GetChildWindows($f)) {
# printf "%d\tchild(%d) = t:'%s' c:'%s' id=%d\n", __LINE__, $ch, GetWindowText($ch), GetClassName($ch), GetWindowID($ch);
# }
#

        # push the ShortcutMapper::CLOSE button
        if($DEBUG_INFO) { note sprintf "\tCLOSE BUTTON:\t%d t:'%s' c:'%s' id=%d\n", $closeButton, GetWindowText($closeButton), GetClassName($closeButton), $closeButtonID; }
        sleep($xtraDelay) if $xtraDelay;
        PushChildButton( $f, $closeButtonID, 0.5 ) for 1..2;   # first push to select, second push to click

        # END of CHILD process
        if($DEBUG_INFO) { sleep 1; }
        $IAMCHILDDONOTRESTORE = 1;
        exit;   # terminate the child process once I've clicked
    } else {            # parent
        undef $IAMCHILDDONOTRESTORE;
        notepad->menuCommand( $NPPIDM{IDM_SETTING_SHORTCUT_MAPPER} ); # run the process
        my $t0 = time;
        while(waitpid(-1, WNOHANG) > 0) {
            last if time()-$t0 > 30;        # no more than 30sec waiting for end
        }
    }


setDebugInfo(0);


}

=over

=item   dumper()

    diag dumper($var1, $var2);

Will look for any characters not in the range C<[\x20-\x7e]> and replace them with a hex notation:

    diag dumper("\n\0");      # prints \x{0A}\x{00}

=back

=cut

sub dumper(@) {
    my @args = @_;
    map { $_='<undef>' unless defined $_; s/([^\x20-\x7e])/sprintf'\\x{%02X}',ord($1)/ge; $_ } @args;
}


1;
