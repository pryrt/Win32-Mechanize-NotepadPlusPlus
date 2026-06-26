#!perl
package Win32::Mechanize::NotepadPlusPlus::Prompt;

use 5.014; # strict, //, s///r
use warnings;

our $VERSION = '0.012'; # auto-populated from W::M::NPP

require XSLoader;
XSLoader::load('Win32::Mechanize::NotepadPlusPlus::Prompt', $VERSION);

sub prompt($$$;$) {
    $_[0] //= 0;                                            # hwnd
    $_[1] //= '<Forgot Prompt Text>';                       # prompt
    $_[2] //= 'W32MNPP prompt';                             # title
    $_[3] //= '';                                           # default
    $_[4] = 0;
    _c_prompt(@_);
}

sub prompt_multiline($$$;$) {
    $_[0] //= 0;                                            # hwnd
    $_[1] //= '<Forgot Prompt Text>';                       # prompt
    $_[2] //= 'W32MNPP prompt_multiline';                   # title
    $_[3] //= '';                                           # default
    $_[4] = 1;
    _c_prompt(@_);
}

=encoding utf8

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Prompt - Helper module for doing XS-based Prompt

=head1 SYNOPSIS

    use Win32::Mechanize::NotepadPlusPlus ':main';
    my $answer = notepad->prompt("Message", "Title", "default");
    my $answer = notepad->prompt_multiline("Message\nmultiline", "Title", "default");

=head1 DESCRIPTION

=over

=item prompt

    notepad->prompt($prompt, $title, $defaultText);
    notepad->prompt($prompt, $title);

Don't need use it directly; instead, see L<editor-E<gt>prompt|Win32::Mechanize::NotepadPlusPlus::Notepad/prompt>.

If you insist on calling it directly, then its first argument is an HWND (or 0), rather than the notepad() object.

=item prompt_multiline

    notepad->prompt_multiline($prompt, $title, $defaultText);
    notepad->prompt_multiline($prompt, $title);

Don't need use it directly; instead, see L<editor-E<gt>prompt_multiline|Win32::Mechanize::NotepadPlusPlus::Notepad/prompt_multiline>.

If you insist on calling it directly, then its first argument is an HWND (or 0), rather than the notepad() object.

=back

=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2026 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
