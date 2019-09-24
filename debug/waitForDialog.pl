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

#$edwin->SendMessage( $scimsg{SCI_CLEARALL});

#$npp->reloadCurrentDocument();

#for my $hw ( FindWindowLike($npp->{_hwnd}) ) {
#    printf STDERR "PID($$) Found $hw: TITLE:\"%s\" CLASS:\"%s\"\n",
#        GetWindowText($hw),
#        GetClassName($hw),
#        ;
#}

# try forking...
END { warn sprintf "EXIT: in %d: %s", $$, scalar localtime; }

# now try to FindWindowLike from the child
{
    $edwin->SendMessage( $scimsg{SCI_CLEARALL});

    for my $hw ( FindWindowLike($npp->{_hwnd}) ) {
        printf STDERR "PID($$) Found $hw: TITLE:\"%s\" CLASS:\"%s\"\n",
            GetWindowText($hw),
            GetClassName($hw),
            ;
    }

    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        warn sprintf "CHILD: %d in %d: %s -- Active %s", $pid, $$, scalar localtime, GetActiveWindow($npp->{_hwnd});
        warn sprintf "CHILD: %d in %d: %s -- Foreground %s", $pid, $$, scalar localtime, GetForegroundWindow();
        warn sprintf "CHILD: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'FindWindowLike';
        sleep(3);
        for my $hw ( FindWindowLike($npp->{_hwnd}) ) {
            printf STDERR "PID($$) Found $hw: TITLE:\"%s\" CLASS:\"%s\"\n",
                GetWindowText($hw),
                GetClassName($hw),
                ;
        }
        warn sprintf "CHILD: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'Found';
        my $f = WaitWindowLike(0, qr/^Reload/, undef, undef, undef, 2);
        warn sprintf "CHILD: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'Found? ' . ($f//'<undef>');
        warn sprintf "CHILD: %d in %d: %s -- Active %s", $pid, $$, scalar localtime, GetActiveWindow($npp->{_hwnd});
        warn sprintf "CHILD: %d in %d: %s -- Foreground %s", $pid, $$, scalar localtime, GetForegroundWindow();
        exit;
    } else {            # parent
        warn sprintf "PARENT: %d in %d: %s -- Active %s", $pid, $$, scalar localtime, GetActiveWindow($npp->{_hwnd});
        warn sprintf "PARENT: %d in %d: %s -- Foreground %s", $pid, $$, scalar localtime, GetForegroundWindow();
        warn sprintf "PARENT: %d in %d: %s -- %s", $pid, $$, scalar localtime, 'execute reload';
        $npp->reloadCurrentDocument();
        warn sprintf "PARENT: %d in %d: %s -- Active %s", $pid, $$, scalar localtime, GetActiveWindow($npp->{_hwnd});
        warn sprintf "PARENT: %d in %d: %s -- Foreground %s", $pid, $$, scalar localtime, GetForegroundWindow();
    }
    warn sprintf "CONTINUED JUST ONCE: in %d: %s", $$, scalar localtime;
}