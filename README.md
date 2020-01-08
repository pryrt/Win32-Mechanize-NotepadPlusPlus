# NAME

Win32::Mechanize::NotepadPlusPlus - Automate the Windows application Notepad++

# SYNOPSIS

    use Win32::Mechanize::NotepadPlusPlus ':main';
    my $npp = notepad();    # main application

# DESCRIPTION

Automate the Windows application [Notepad++](https://notepad-plus-plus.org/).  This is inspired by the
Notepad++ plugin PythonScript, but I decided to automate the application from the outside, rather than
from inside a Notepad++ plugin.  But the intention is to have similar naming conventions and interface.

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

Please report any bugs or feature requests
thru the repository's interface at [https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues),
or by emailing `<bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.org>`
or thru the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus).

<div>
    <a href="https://metacpan.org/pod/Win32::Mechanize::NotepadPlusPlus><img src="https://img.shields.io/cpan/v/Win32-Mechanize-NotepadPlusPlus.svg?colorB=00CC00" alt="" title="metacpan"></a>
    <a href="http://matrix.cpantesters.org/?dist=Win32-Mechanize-NotepadPlusPlus"><img src="http://cpants.cpanauthors.org/dist/Win32-Mechanize-NotepadPlusPlus.png" alt="" title="cpan testers"></a>
    <a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/releases"><img src="https://img.shields.io/github/release/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="github release"></a>
    <a href="https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues"><img src="https://img.shields.io/github/issues/pryrt/Win32-Mechanize-NotepadPlusPlus.svg" alt="" title="issues"></a>
    <a href="https://ci.appveyor.com/project/pryrt/win32-mechanize-notepadplusplus"><img src="https://ci.appveyor.com/api/projects/status/6gv0lnwj1t6yaykp/branch/master?svg=true" alt="" title="test coverage"></a>
</div>

# COPYRIGHT

Copyright (C) 2019,2020 Peter C. Jones

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
