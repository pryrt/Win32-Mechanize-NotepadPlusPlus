package Win32::Mechanize::NotepadPlusPlus::Notepad;
use 5.006;
use warnings;
use strict;
use Exporter 'import';

our $VERSION = '0.000001';  # TODO = make this automatically the same version as NotepadPlusPlus.pm

=pod

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Notepad - The main application object for Notepad++ automation

=head1 SYNOPSIS

    xxx

=head1 DESCRIPTION

The editor object for Notepad++ automation using L<Win32::Mechanize::NotepadPlusPlus>

=head1 PythonScript API

    Notepad.activateBufferID(bufferID)
    Activates the given bufferID:

    bufferID = notepad.getCurrentBufferID()
    ...
    notepad.activateBufferID(bufferID)
    Notepad.activateFile(filename)
    Activates the document with the given filename

    Notepad.activateIndex(view, index)
    Activates the document with the given view and index. view is 0 or 1.

    Notepad.callback(function, notifications)
    Registers a callback function for a notification. notifications is a list of messages to call the function for.:

    def my_callback(args):
            console.write("Buffer Activated %d\n" % args["bufferID"]

    notepad.callback(my_callback, [NOTIFICATION.BUFFERACTIVATED])
    The NOTIFICATION enum corresponds to the NPPN_* plugin notifications. The function arguments is a map, and the contents vary dependant on the notification.

    Note that the callback will live on past the life of the script, so you can use this to perform operations whenever a document is opened, saved, changed etc.

    Also note that it is good practice to put the function in another module (file), and then import that module in the script that calls notepad.callback(). This way you can unregister the callback easily.

    For Scintilla notifications, see editor.callback()

    Returns:
    True if the registration was successful
    Notepad.clearCallbacks()
    Unregisters all callbacks

    Notepad.clearCallbacks(function)
    Unregisters all callbacks for the given function. Note that this uses the actual function object, so if the function has been redefined since it was registered, this will fail. If this has happened, use one of the other clearCallbacks() functions.

    Notepad.clearCallbacks(eventsList)
    Unregisters all callbacks for the given list of events.:

    notepad.clearCallbacks([NOTIFICATION.BUFFERACTIVATED, NOTIFICATION.FILESAVED])
    See NOTIFICATION

    Notepad.clearCallbacks(function, eventsList)
    Unregisters the callback for the given callback function for the list of events.

    Notepad.close()
    Closes the currently active document

    Notepad.closeAll()
    Closes all open documents

    Notepad.closeAllButCurrent()
    Closes all but the currently active document

    Notepad.createScintilla()
    Create a new Scintilla handle. Returns an Editor object

    Notepad.destroyScintilla(editor)
    Destroy a Scintilla handle created with createScintilla

    Notepad.getCommandLine()
    Gets the command line used to start Notepad++

    Notepad.getCurrentBufferID()
    Gets the bufferID of the currently active buffer

    Notepad.getCurrentDocIndex(view)
    Gets the current active index for the given view (0 or 1)

    Notepad.getCurrentFilename()
    Gets the filename of the active document

    Notepad.getCurrentLang()
    Get the current language type

    Returns:
    LANGTYPE
    Notepad.getCurrentView()
    Get the currently active view (0 or 1)

    Notepad.getEncoding([bufferID]) → BUFFERENCODING
    Gets the encoding of the given bufferID. If no bufferID is given, then the encoding of the currently active buffer is returned.

    Returns:
    BUFFERENCODING
    Notepad.getFiles()
    Gets a list of the open filenames.

    Returns:
    A list of tuples containing (filename, bufferID, index, view)
    Notepad.getFormatType([bufferID]) → FORMATTYPE
    Gets the format type (i.e. Windows, Unix or Mac) of the given bufferID. If no bufferID is given, then the format of the currently active buffer is returned.

    Returns:
    FORMATTYPE
    Notepad.getLangType([bufferID]) → LANGTYPE
    Gets the language type of the given bufferID. If no bufferID is given, then the language of the currently active buffer is returned.

    Returns:
    LANGTYPE
    Notepad.getNppDir() → str
    Gets the directory Notepad++ is running in (i.e. the location of notepad++.exe)

    Notepad.getPluginConfigDir() → str
    Gets the plugin config directory.

    Notepad.getPluginMenuHandle() → int
    Gets the handle for the Plugins menu.

    Notepad.getVersion() → tuple
    Gets the Notepad++ version as a tuple - e.g. 5.6.8 becomes (5,6,8)

    Notepad.getPluginVersion() → str
    Gets the PythonScript plugin version as a string. There is always four parts to it. e.g. ‘0.9.2.0’

    Notepad.hideTabBar()
    Hides the Tab bar

    Notepad.menuCommand(menuCommand)
    Runs a Notepad++ menu command. Use the MENUCOMMAND enum, or integers directly from the nativeLang.xml file.

    Notepad.messageBox(message[, title[, flags]]) → MessageBoxFlags
    Displays a message box with the given message and title.

    Flags can be 0 for a standard ‘OK’ message box, or a combination of MESSAGEBOXFLAGS. title is “Python Script for Notepad++” by default, and flags is 0 by default.

    Returns:
    A RESULTxxxx member of MESSAGEBOXFLAGS as to which button was pressed.
    Notepad.new()
    Create a new document.

    Notepad.open(filename)
    Opens the given file.

    Notepad.prompt(prompt, title[, defaultText]) → str
    Prompts the user for some text. Optionally provide the default text to initialise the entry field.

    Returns:
    The string entered.

    None if cancel was pressed (note that is different to an empty string, which means that no input was given)
    Notepad.reloadBuffer(bufferID)
    Reloads the given bufferID

    Notepad.reloadCurrentDocument()
    Reloads the current document

    Notepad.reloadFile(filename)
    Reloads a filename.

    Notepad.runMenuCommand(menuName, menuOption[, refreshCache]) → bool
    Runs a command from the menus. For built-in menus use notepad.menuCommand(), for non built-in menus (e.g. TextFX and macros you’ve defined), use notepad.runMenuCommand(menuName, menuOption). For other plugin commands (in the plugin menu), use Notepad.runPluginCommand(pluginName, menuOption)_

    Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runMenuCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

    Returns:
    True if the menu command was found, otherwise False
    e.g.:

    notepad.runMenuCommand('TextFX Edit', 'Delete Blank Lines')
    Notepad.runPluginCommand(pluginName, menuOption[, refreshCache])
    Runs a command from the plugin menu. Use to run direct commands from the Plugins menu. To call TextFX or other menu functions, either use notepad.menuCommand(menuCommand)_ (for Notepad++ menu commands), or notepad.runMenuCommand(menuName, menuOption)_ for TextFX or non standard menus (such as macro names).

    Note that menuOption can be a submenu in a plugin’s menu. So:

    notepad.runPluginCommand('Python Script', 'demo script')
    Could run a script called “demo script” from the Scripts submenu of Python Script.

    Menus are searched for the text, and when found, the internal ID of the menu command is cached. When runPluginCommand is called, the cache is first checked if it holds the internal ID for the given menuName and menuOption. If it does, it simply uses the value from the cache. If the ID could have been updated (for example, you’re calling the name of macro that has been removed and added again), set refreshCache to True. This is False by default.

    e.g.::
    notepad.runPluginCommand(‘XML Tools’, ‘Pretty Print (XML only)’)
    Notepad.save()
    Save the current file

    Notepad.saveAllFiles()
    Saves all currently unsaved files

    Notepad.saveAs(filename)
    Save the current file as the specified filename

    Only works in Notepad++ 5.7 onwards

    Notepad.saveAsCopy(filename)
    Save the current file as the specified filename, but don’t change the filename for the buffer in Notepad++

    Only works in Notepad++ 5.7 onwards

    Notepad.saveCurrentSession(filename)
    Save the current session (list of open files) to a file.

    Notepad.saveSession(filename, filesList)
    Saves a session file with the list of filenames.

    Notepad.setCurrentLang(langType)
    Set the language type of the currently active buffer (see LANGTYPE)

    Notepad.setFormatType(formatType[, bufferID])
    Sets the format type (i.e. Windows, Unix or Mac) of the specified buffer ID. If not bufferID is passed, then the format type of the currently active buffer is set.

    Notepad.setLangType(langType[, bufferID])
    Sets the language type of the given bufferID. If not bufferID is given, sets the language for the currently active buffer.

    Notepad.setStatusBar(statusBarSection, text)
    Sets the status bar text. For statusBarSection, use one of the STATUSBARSECTION constants.

    Notepad.showTabBar()
    Shows the Tab bar


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