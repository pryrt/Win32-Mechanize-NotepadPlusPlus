########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: those necessary for file and session open/close
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;
use Win32;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus ':main';

# need to choose forked (normal clicker) vs unforked (Devel::Cover cannot handle windows[fork->thread] )
BEGIN {
    if(exists $ENV{HARNESS_PERL_SWITCHES} ){
        *runCodeAndClickPopup = \&__devel_cover__runCodeAndClickPopup;
    } else {
        *runCodeAndClickPopup = \&__runCodeAndClickPopup;
    }
}

# outline:
#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.

our $saveUserFileList;
BEGIN {
    use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;  # for %scimsg
    my $unsaved = 0;
    for my $view (0, 1) {
        my $nb = notepad()->getNumberOpenFiles($view);
        for my $idoc ( 0 .. $nb-1 ) {
            notepad()->activateIndex($view,$idoc);
            $unsaved++ if editor()->{_hwobj}->SendMessage( $scimsg{SCI_GETMODIFY} );
            push @$saveUserFileList, notepad()->getCurrentFilename();
        }
    }
    no Win32::Mechanize::NotepadPlusPlus::__sci_msgs;
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
}

#   prepopulate any tempfile locations
our ($saveUserSession, $knownSession, $fnew1, $fnew2);
BEGIN {
    # use tempfiles for the "new" and "save as" files
    $fnew1 = tempfile( TEMPLATE => 'nppNewFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew1->canonpath();
    $fnew2 = tempfile( TEMPLATE => 'nppDupFile_XXXXXXXX', SUFFIX => '.txt'); note $fnew2->canonpath();
    $knownSession = tempfile( TEMPLATE => 'nppKnownSession_XXXXXXXX', SUFFIX => '.xml'); note $knownSession->canonpath();

    # for saveUserSession, use a named session, which I can point out to the user if necessary, or delete if safe.
    $saveUserSession = $fnew1->sibling('EmergencyNppSession.xml'); note $saveUserSession->canonpath(); # don't want to delete the session
    # the list of files was saved above, because I was already looping through all the open files.
}

#   ->saveCurrentSession($saveUserSession)
#       => this also avoids messing up the user's current Notepad++ instance.
#           STOP IMMEDIATELY IF THIS FAILS
#       => attempt to reload that session on exit (END block),
#           and if there's a problem with reload, point user
#           to where the session file is.
{
    my $ret = notepad()->saveCurrentSession( $saveUserSession->canonpath() );
    ok $ret, sprintf 'saveCurrentSession("%s"): retval = %d', $saveUserSession->canonpath(), $ret;
    my $size = $saveUserSession->is_file ? $saveUserSession->stat()->size : 0;
    ok $size, sprintf 'saveCurrentSession(): size(file) = %d', $size
        or do {
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
}

# as last event in test (even after done_testing), make sure the files
#   from the user's original session are all loaded, and bail out with
#   emergency message if not:
our $inChildFork;   # if in a child fork, don't want to do the cleanup, because we're not done with the test, just with that temporary fork
END {
    if(!$inChildFork) {
        # in case any are left open, close them
        notepad()->closeAll;

        # should load just the user's files
        notepad()->loadSession($saveUserSession->absolute->canonpath);

        # check for any missing files
        my $missing = 0;
        for my $f ( @$saveUserFileList ) {
            ++$missing unless notepad()->activateFile($f);
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
        diag "Verified user session files re-loaded.";
    }
}

#   ->closeAll()
#       => gives a blank slate to work with.
{
    my $ret = notepad()->closeAll();
    ok $ret, sprintf 'closeAll(): retval = %d', $ret;

    my $nOpen = notepad()->getNumberOpenFiles(0);
    is $nOpen, 1, sprintf 'closeAll(): getNumberOpenFiles(0) = %d', $nOpen;

    my $fName = notepad()->getCurrentFilename();
    like $fName, qr/^new \d/i, sprintf 'closeAll(): getCurrentFilename() = "%s"', $fName;
}

#   ->loadSession()
#       => gets us to a known state with a prebuilt session
{
    # generate the session file on the fly, because it needs absolute directories, which I cannot have until the test suite runs
    my @src = qw/00-load.t 10-defaults.t/;
    $knownSession->append(qq{<NotepadPlus><Session activeView="0"><mainView activeIndex="0">\n});
    $knownSession->append(sprintf qq{<File firstVisibleLine="0" xOffset="0" filename="%s" />\n}, $_)
        for map { path($0)->sibling($_)->absolute->canonpath() } @src;
    $knownSession->append(qq{</mainView><subView activeIndex="0" /></Session></NotepadPlus>\n});
    #note $knownSession->slurp();

    my $ret = notepad()->loadSession( $knownSession->absolute->canonpath );
    ok $ret, sprintf 'loadSession("%s"): retval = %d', $knownSession->absolute->canonpath, $ret;

    my $nOpen = notepad()->getNumberOpenFiles(0);
    is $nOpen, 2, sprintf 'loadSession(): getNumberOpenFiles(0) = %d', $nOpen;

    my @files = map { $_->[0] } @{ notepad()->getFiles() };
    for my $i (0,1) {
        like $files[$i], qr/\b\Q$src[$i]\E\b/i, sprintf 'loadSession(): getFiles()->[%d][0] = "%s"', $i, $files[$i];
    }
}

#   ->newFile()
#       => create a blank, editable document
{
    my $ret = notepad()->newFile();
    ok $ret, sprintf 'newFile(): retval = %d', $ret;

    my $fName = notepad()->getCurrentFilename();
    like $fName, qr/^new \d/i, sprintf 'newFile(): getCurrentFilename() = "%s"', $fName;
}

#   ->saveAs( $fnew1 )
#       => give it a name
{
    my $text = sprintf 'saveAs("%s")', $fnew1->basename();
    editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $text );

    my $ret = notepad()->saveAs( $fnew1->absolute->canonpath() );
    ok $ret, sprintf 'saveAs(): retval = %d', $ret;

    my $fName = path( notepad()->getCurrentFilename() )->basename();
    is $fName, $fnew1->basename(), sprintf 'saveAs(): getCurrentFilename() = "%s"', $fName;
}

#   ->saveAsCopy( $fnew2 )
#       => give it a second name (but ->getCurrentFilename() should remain the same)
{
    my $ret = notepad()->saveAsCopy( $fnew2->absolute->canonpath() );
    ok $ret, sprintf 'saveAsCopy(): retval = %d', $ret;

    my $fName = path( notepad()->getCurrentFilename() )->basename();
    isnt $fName, $fnew2->basename(), sprintf 'saveAsCopy(): getCurrentFilename() = "%s"', $fName;
    is $fName, $fnew1->basename(), sprintf 'saveAsCopy(): getCurrentFilename() = "%s"', $fName;
}

#   ->open( $fnew2 )
#       => bring it in and edit it
{
    my $ret = notepad()->open( $fnew2->absolute->canonpath() );
    ok $ret, sprintf 'open("%s"): retval = %d', $fnew2->absolute->canonpath(), $ret;

    my $fName = path( notepad()->getCurrentFilename() )->basename();
    is $fName, $fnew2->basename(), sprintf 'open(): getCurrentFilename() = "%s"', $fName;
}

#   ->save()
#       => edit it, and make sure that it changes on disk
{
    my $origFileSize = $fnew2->stat()->size();
    ok $origFileSize, sprintf 'save(): original size before edit and save: %d', $origFileSize;

    my $text = "this is new text";
    my $expect = length($text);
    editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $text );

    my $ret = notepad()->save();
    ok $ret, sprintf 'save(): retval = %d', $ret;

    my $newFileSize = $fnew2->stat()->size();
    is $newFileSize, $expect, sprintf 'save(): new size after edit and save: %d', $newFileSize;
}

#   ->saveSession( $tempsessionfilename )
#       => include a subset of files; see whether they all have to be open or not
TODO: {
    local $TODO = "!!saveSession not implemented!!";
    ok 0, sprintf 'saveSession(%s)', $knownSession;
}

#   ->getSessionFiles()
#       => test to make sure it includes all the files I passed to ->saveSession
TODO: {
    local $TODO = "!!getSessionFiles not finalized!!";
    my @ret = notepad()->getSessionFiles($saveUserSession);     # TODO = switch to $knownSession
    ok scalar @ret, sprintf 'getSessionFiles(): found %d sessions', scalar @ret;
    ok $_, sprintf 'getSessionFiles(): "%s"', $_    for @ret;
}

#   ->saveAllFiles()
#       => _after_ editing both open files
#       => need to make sure that it changes on disk
{
    my $nView0 = notepad()->getNumberOpenFiles(0);
    is $nView0, 4, sprintf 'saveAllFiles(): first make sure expected number are open: %d', $nView0;

    # last modified when?
    my ($tmod1, $tmod2) = map { $_->stat()->mtime() } $fnew1, $fnew2;
    ok $tmod1, sprintf 'saveAllFiles(): "%s" previously modified at %s', $fnew1->basename(), scalar localtime $tmod1;
    ok $tmod2, sprintf 'saveAllFiles(): "%s" previously modified at %s', $fnew2->basename(), scalar localtime $tmod2;

    # edit both files
    for my $di ( $nView0-1,$nView0-2 ) {
        notepad()->activateIndex(0,$di);
        my $text = sprintf qq(editing "%s"\r\n%s\r\n), notepad->getCurrentFilename(), scalar localtime;
        editor()->{_hwobj}->SendMessage_sendRawString( $scimsg{SCI_SETTEXT}, 0, $text );
        sleep(1);
    }

    # now save them
    my $ret = notepad->saveAllFiles();
    ok $ret, sprintf 'saveAllFiles(): ret = %d', $ret;

    # should be more-recently modified
    my ($tmod1x, $tmod2x) = map { $_->stat()->mtime() } $fnew1, $fnew2;
    ok $tmod1x-$tmod1, sprintf 'saveAllFiles(): "%s" modified at %s; delta = %d', $fnew1->basename(), scalar localtime $tmod1x, $tmod1x-$tmod1;
    ok $tmod2x-$tmod2, sprintf 'saveAllFiles(): "%s" modified at %s; delta = %d', $fnew2->basename(), scalar localtime $tmod2x, $tmod2x-$tmod2;
}

#   ->closeAllButCurrent()
#       => only one file should be there
{
    my $ret = notepad()->closeAllButCurrent();
    ok $ret, sprintf 'closeAllButCurrent(): ret = %d', $ret;

    my $num = notepad()->getNumberOpenFiles(0);
    is $num, 1, sprintf 'closeAllButCurrent(): %d file%s open', $num, $num==1?'':'s';
}

#   ->close()
#       => all that remains should be the "new 1" empty buffer
{
    my $oldname = notepad()->getCurrentFilename();

    my $ret = notepad()->close();
    ok $ret, sprintf 'close(): ret = %d', $ret;

    my $name = notepad()->getCurrentFilename();
    like $name, qr/^new \d/i, sprintf 'close(): filename should be /new #/: "%s"', $name;
    isnt $name, $oldname, sprintf 'close(): filename should not match old name ("%s")', $oldname;
}

done_testing;


use Win32::GuiTest ':FUNC';
# have to fork to be able to respond to the popup, because $cref->() holds until the dialog goes away
#   unfortunately, Devel::Cover doesn't work if threads are involved, so have two alternate versions of the
sub __runCodeAndClickPopup {
    my ($cref, $re) = @_;

    my $ret;
    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        $inChildFork = 1;
        my $f = WaitWindowLike(0, $re, undef, undef, 3, 5) or do { diag $!; exit };
        my $p = GetParent($f);
        note sprintf qq|__%04d__->runCodeAndClickPopup()\n\tfound: %d "%s" "%s"\n\tparent: %d "%s" "%s"\n|,
            (caller)[2],
            $f, GetWindowText($f), GetClassName($f),
            $p, GetWindowText($p), GetClassName($p),
            ;
        # Because localization, cannot assume YES button will match qr/\&Yes/
        #   instead, assume first child of Reload dialog is always YES or equivalent
        my ($h) = FindWindowLike( $f, undef, undef, undef, 2);
        my $id = GetWindowID($h);
        note sprintf "\tbutton:\t%d '%s' '%s' id=%d\n", $h, GetWindowText($h), GetClassName($h), $id;

        # first push to select, second push to click
        PushChildButton( $f, $id, 0.1 ) for 1..2;
        exit;   # terminate the child process once I've clicked
    } else {            # parent
        undef $inChildFork;
        use POSIX ":sys_wait_h";
        $ret = $cref->();
        my $t0 = time;
        while(waitpid(-1, WNOHANG) > 0) {
            last if time()-$t0 > 30;        # no more than 30sec waiting for end
        }
    }
    return $ret;
}

sub __devel_cover__runCodeAndClickPopup {
    my ($cref, $re) = @_;
    diag "Running in coverage / Devel::Cover mode\n";
    diag "\n\nYou need to click YES or equivalent in the dialog coming soon\n\n";
    diag "caller(0): ", join ';', map {$_//'<undef>'} caller(0);
    return $cref->();
}
