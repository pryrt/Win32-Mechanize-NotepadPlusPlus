package Win32::Mechanize::NotepadPlusPlus::Console;
use 5.006;
use warnings;
use strict;
use Exporter 'import';

our $VERSION = '0.000001';  # TODO = make this automatically the same version as NotepadPlusPlus.pm

=pod

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Console - The Console object for Notepad++ automation

=head1 SYNOPSIS

    my $cli = console();
    $cli->show();
    $cli->write("Hello, world\n");
    $cli->run("cmd /c echo yo!");

=head1 DESCRIPTION

The console object for Notepad++ automation using L<Win32::Mechanize::NotepadPlusPlus>

=head1 PythonScript API

    Console.write(string)
    Writes text to the console.

    Console.writeError(string)
    Writes text to the console in red

    Console.clear()
    Clears the console

    Console.show()
    Shows the console window.

    Console.hide()
    Hides the console window

    Console.run(commandLine[, stdout[, stderr]])
    Runs an external program, with output optionally directed to the given objects (which must support a write method).

    Not supplying stdout means that the console is used for stdout.

    Not supplying stderr means that the default values from sys.stderr (normally the console, in red) is used.

    e.g.:

    # The basic form, run a normal command line.
    console.run('cl.exe "myfile.c"')

    # Create a new document in Notepad++
    notepad.new()

    # Run someprogram.exe, and have the output written to the new document.
    console.run('someprogram.exe', editor)
    To run a batch file, you need to call cmd.exe with the /c parameter - like this:

    console.run(r'cmd.exe /c c:\path\to\mybatch.bat arg1 arg2')
    The r before the quote signifies the text should be treated as “raw”, and hence the backslashes should be treated as plain backslashes, not an escape.

    The console will automatically parse Python, Visual Studio and GCC style errors and warnings. The filenames are then clickable to open the file at the line number given. If you would like some other form of warnings or errors parsed, please send me an email (davegb@pobox.com). Also if you find a line that is parsed as an error or warning and it shouldn’t have been, also let me know.

    Console.editor
    An Editor object for the console window. This enables you to change colours, styles, even add and remove text if you so wish, from the console window. Note that the console window is always left in a read-only state, so in order to change text, you would need to first perform a console.editor.setReadOnly(0). Any subsequent console.write or console.writeError calls will make the console read-only again.


=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>


=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2018 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;