package Win32::Mechanize::NotepadPlusPlus;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use Carp;

our $VERSION = '0.000001';  # rrr.mmmsss : rrr is major revision; mmm is minor revision; sss is sub-revision; optionally use _sss instead, for alpha sub-releases

=pod

=head1 NAME

Win32::Mechanize::NotepadPlusPlus - Automate the Windows application Notepad++

=head1 SYNOPSIS

    use Win32::Mechanize::NotepadPlusPlus ':main';
    my $npp = notepad();    # main application

=head1 DESCRIPTION

Automate the Windows application L<Notepad++|https://notepad-plus-plus.org/>.  This is inspired by the
Notepad++ plugin PythonScript, but I decided to automate the application from the outside, rather than
from inside a Notepad++ plugin.  But the intention is to have similar naming conventions and interface.

=cut

our @EXPORT = ();   # by default, export nothing
our @EXPORT_MAIN = qw/notepad editor editor1 editor2 console/;
our @EXPORT_OTHER = qw//;   # maybe eventually, functions to create and destroy additional NPP instances
our @EXPORT_OK = (@EXPORT_MAIN, @EXPORT_OTHER);
our %EXPORT_TAGS = (
    main            => [@EXPORT_MAIN],
    other           => [@EXPORT_OTHER],
    all             => [@EXPORT_OK],
);

my %default = (
    notepad => undef,
    editor1 => undef,
    editor2 => undef,
    console => undef,
);

BEGIN { _initialize_default_instances(); }

sub _initialize_default_instances
{
    1;
}

=head1 SUBCLASSES

These give you access to the Notepad++ application, the Scintilla editor components, and the console
window inside Notepad++.  The main module exports functions that return the default instances.

=head2 Notepad

L<Win32::Mechanize::NotepadPlusPlus::Notepad> gives access to the actual Notepad++ application.

    my $npp = notepad();
    $npp->CloseAll();

=cut

sub notepad
{
    $default{notepad} // croak "not initialized";
}

=head2 Editor

L<Win32::Mechanize::NotepadPlusPlus::Editor>  gives access to the underlying Scintilla component(s) used to actually edit the text files in Notepad++.

In PythonScript, the default instance is called C<editor> for the active editor window. There are two additional
instances, C<editor1> and C<editor2> for accessing the specific "left" and "right" editor panes.

    my $left_pane = editor1();
    my $right_pane = editor2();
    if( editor() == $left_pane ) { ... }    # do this only if left pane is active pane

=cut

sub editor1
{
    $default{editor1} or croak "not initialized";
}

sub editor2
{
    $default{editor1} or croak "not initialized";
}

sub editor
{
    # choose either editor1 or editor2, depending on which is active
    $default{editor1} and $default{editor2} or croak "not initialized";
    return editor1 if editor1->is_active;
    return editor2 if editor2->is_active;
    croak "no active editor?  not possible";
}

=head2 Console

L<Win32::Mechanize::NotepadPlusPlus::Console> gives access to the Notepad++ console, which is a simple
command-line window.

    my $cli = console();
    $cli->show();
    $cli->write("Hello, world\n");
    $cli->run("cmd /c echo yo!");

=cut

sub console
{
    $default{console} or croak "not initialized";
}

=head1 INSTALLATION

To install this module, use your favorite CPAN client.

For a manual install, type the following:

    perl Makefile.PL
    make
    make test
    make install

(On Windows machines, you may need to use "dmake" or "gmake" instead of "make", depending on your setup.)

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=begin html

<a href="https://metacpan.org/pod/Win32::Mechanize::NotepadPlusPlus><img src="https://img.shields.io/cpan/v/Win32-Mechanize-NotepadPlusPlus.svg?colorB=00CC00" alt="" title="metacpan"></a>
<a href="http://matrix.cpantesters.org/?dist=Win32-Mechanize-NotepadPlusPlus"><img src="http://cpants.cpanauthors.org/dist/Win32-Mechanize-NotepadPlusPlus.png" alt="" title="cpan testers"></a>
<a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/releases"><img src="https://img.shields.io/github/release/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="github release"></a>
<a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues"><img src="https://img.shields.io/github/issues/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="issues"></a>
<a href="https://travis-ci.org/pryrt/Win32-Mechanize-NotepadPlusPlus"><img src="https://travis-ci.org/pryrt/Win32-Mechanize-NotepadPlusPlus.svg?branch=master" alt="" title="build status"></a>
<a href="https://coveralls.io/github/pryrt/Win32-Mechanize-NotepadPlusPlus?branch=master"><img src="https://coveralls.io/repos/github/pryrt/Win32-Mechanize-NotepadPlusPlus/badge.svg?branch=master" alt="" title="test coverage"></a>

=end html

=head1 COPYRIGHT

Copyright (C) 2018 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;