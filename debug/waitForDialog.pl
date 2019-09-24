#!/usr/bin/env perl

use lib '..\lib';
use lib '.\lib';
use Win32::Mechanize::NotepadPlusPlus ':main';
use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;  # exports %scimsg, which contains the messages used by Scintilla editors
use Win32::GuiTest qw/:FUNC/;
use strict;
use warnings;

my $npp = notepad();
my $edwin = $npp->editor()->{_hwobj};

# try forking to find window in one, reload in the other
{
    $edwin->SendMessage( $scimsg{SCI_CLEARALL});

    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        warn sprintf "CHILD: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'FindWindowLike';
        my $f = WaitWindowLike(0, qr/^Reload/, undef, undef, undef, 5);
        warn sprintf "CHILD: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'Found? ' . ($f//'<undef>');
        my $p = GetParent($f);
        warn sprintf qq|\tfound: %d "%s" "%s"\n\tparent: %d "%s" "%s"\n|,
            $f, GetWindowText($f), GetClassName($f),
            $p, GetWindowText($p), GetClassName($p),
            ;
        exit;
    } else {            # parent
        warn sprintf "PARENT: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'execute reload';
        $npp->reloadCurrentDocument();
    }
    warn sprintf "CONTINUED JUST ONCE: in %d: %s", $$, scalar localtime;
    warn sprintf "NPP_HWND = %s\nACTIVE_HWND = %s\n", $npp->{_hwnd}, GetForegroundWindow();
}