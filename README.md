# NAME

Win32::Mechanize::NotepadPlusPlus - Automate the Windows application Notepad++

# SYNOPSIS

    TODO

# DESCRIPTION

Automate the Windows application [Notepad++](https://notepad-plus-plus.org/).  This is inspired by the
Notepad++ plugin PythonScript: there needs to be Perl-based automation for Notepad++ if there is Python-based.
I decided to automate the application from the outside, rather than from inside a Notepad++ plugin, but the
intention is to have similar naming conventions.

# INSTALLATION

To install this module, use your favorite CPAN client.

For a manual install, type the following:

    perl Makefile.PL
    make
    make test
    make install

(On Windows machines, you may need to use "dmake" or "gmake" instead of "make", depending on your setup.)

# AUTHOR

Peter C. Jones `<petercj AT cpan DOT org>`

Please report any bugs or feature requests emailing `<bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.org>`
or thru the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus),
or thru the repository's interface at [https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues).

<div>
    <a href="https://metacpan.org/pod/Win32::Mechanize::NotepadPlusPlus><img src="https://img.shields.io/cpan/v/Win32-Mechanize-NotepadPlusPlus.svg?colorB=00CC00" alt="" title="metacpan"></a>
    <a href="http://matrix.cpantesters.org/?dist=Win32-Mechanize-NotepadPlusPlus"><img src="http://cpants.cpanauthors.org/dist/Win32-Mechanize-NotepadPlusPlus.png" alt="" title="cpan testers"></a>
    <a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/releases"><img src="https://img.shields.io/github/release/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="github release"></a>
    <a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues"><img src="https://img.shields.io/github/issues/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="issues"></a>
    <a href="https://travis-ci.org/pryrt/Win32-Mechanize-NotepadPlusPlus"><img src="https://travis-ci.org/pryrt/Win32-Mechanize-NotepadPlusPlus.svg?branch=master" alt="" title="build status"></a>
    <a href="https://coveralls.io/github/pryrt/Win32-Mechanize-NotepadPlusPlus?branch=master"><img src="https://coveralls.io/repos/github/pryrt/Win32-Mechanize-NotepadPlusPlus/badge.svg?branch=master" alt="" title="test coverage"></a>
</div>

# COPYRIGHT

Copyright (C) 2018 Peter C. Jones

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
