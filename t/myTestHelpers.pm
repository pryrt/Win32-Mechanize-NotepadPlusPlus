package myTestHelpers;
use Win32::GuiTest qw/:FUNC/;
use Exporter 5.57 qw/import/;
use Test::More;
use POSIX ":sys_wait_h";
use strict;
use warnings;

=head1 NAME

myTestHelpers

=head1 DESCRIPTION

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

our @EXPORT_OK = qw/runCodeAndClickPopup/;
our @EXPORT = @EXPORT_OK;

# have to fork to be able to respond to the popup, because $cref->() holds until the dialog goes away
#   unfortunately, Devel::Cover doesn't work if threads are involved.
#   TODO = figure out how to detect that we're running under Devel::Cover, and take an alternate test-flow
sub __runCodeAndClickPopup {
    my ($cref, $re, $n) = @_;

    my $pid = fork();
    if(!defined $pid) { # failed
        die "fork failed: $!";
    } elsif(!$pid) {    # child: pid==0
        my $f = WaitWindowLike(0, $re, undef, undef, 3, 5);
        my $p = GetParent($f);
        if(0) {
            note "runCodeAndClickPopup(..., $re, $n):\n";
            note sprintf qq|\tfound: %d t:"%s" c:"%s"\n\tparent: %d t:"%s" c:"%s"\n|,
                $f, GetWindowText($f), GetClassName($f),
                $p, GetWindowText($p), GetClassName($p),
                ;
        }
        # Because localization, cannot assume YES button will match qr/\&Yes/
        #   instead, assume first child of Reload dialog is always YES or equivalent
        my @buttons = FindWindowLike( $f, undef, qr/^Button$/, undef, 2);
        if(0) { note sprintf "\tbutton:\t%d t:'%s' c:'%s' id=%d\n", $_, GetWindowText($_), GetClassName($_), GetWindowID($_) for grep { $_ } @buttons[0..4]; }
        if($n>$#buttons) {
            diag sprintf "You asked to click button #%d, but there are only %d buttons.\n", $n, scalar @buttons;
            diag sprintf "clicking the first (#0) instead.  Good luck with that.\n";
            $n = 0;
        }
        my $h = $buttons[$n];
        my $id = GetWindowID($h);
        if(0) { note sprintf "\tCHOSEN:\t%d t:'%s' c:'%s' id=%d\n", $h, GetWindowText($h), GetClassName($h), $id; }

        # first push to select, second push to click
        PushChildButton( $f, $id, 0.1 ) for 1..2;
        exit;   # terminate the child process once I've clicked
    } else {            # parent
        $cref->();
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


1;