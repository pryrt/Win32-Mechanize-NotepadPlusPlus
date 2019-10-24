package Win32::Mechanize::NotepadPlusPlus::Editor;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use Carp;
use Win32::Mechanize::NotepadPlusPlus::__hwnd;
use Win32::Mechanize::NotepadPlusPlus::__sci_msgs;  # exports %scimsg, which contains the messages used by the Scintilla editor

use Data::Dumper; $Data::Dumper::Useqq++;


our $VERSION = '0.000001'; # auto-populated from W::M::NPP

our @EXPORT_VARS = qw/%scimsg/;
our @EXPORT_OK = (@EXPORT_VARS);
our %EXPORT_TAGS = (
    vars            => [@EXPORT_VARS],
    all             => [@EXPORT_OK],
);


=pod

=encoding utf8

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::Editor - The editor object for Notepad++ automation

=head1 SYNOPSIS

    xxx

=head1 DESCRIPTION

The editor object for Notepad++ automation using L<Win32::Mechanize::NotepadPlusPlus>

=cut

# Win32::Mechanize::NotepadPlusPlus::Editor->new(hwnd)
#   Normally, the user won't call this; it will be instantiated for the two main view-scintillas by the Notepad.pm object;
#   If the user wants to create a new (behind the scenes) Scintilla, use the ->create method, instead
sub new
{
    my ($class, $hwnd, $parent) = @_;
    my $self = bless {}, $class;
    $self->{_hwnd} = $hwnd;
    $self->{_hwobj} = Win32::Mechanize::NotepadPlusPlus::__hwnd->new( $self->{_hwnd} ); # create an object
    if( defined $parent ) {
        # set the Editor's parent, if it's been passed
        if( ref($parent) ) {
            # if it's an object, error out on unknown, else set the parent
            croak "unknown object $parent" unless $parent->isa('Win32::Mechanize::NotepadPlusPlus::__hwnd');
            $self->{_parent_hwobj} = $parent;
        } else {
            # when non-reference, assume it's the parent window's HWND
            $self->{_parent_hwobj} = Win32::Mechanize::NotepadPlusPlus::__hwnd->new( $parent );
        }
    }
    return $self;
}

sub create
{
    my ($class, @args) = @_;
    croak "$class->create() is not yet implemented; sorry";
}

# doc to pod+code:
# tested at regexr.com/4n9gb
#   ^(?s)\h*(Editor\.)(.*?)(\R)\h*(.*?)\h*(See Scintilla documentation for)\h*(\w+)
#   =item editor\(\)->$2$3$3$4$5 L<$6|https://www.scintilla.org/ScintillaDoc.html/#$6>$3$3=cut$3$3sub $2 { ... $6 ... }
#
# tested at regexr.com/4nhob for similar...
#   (?s)^    Editor\.(.*?)(\R)(.*?)\2    (See Scintilla documentation for )(\w+)\2+
#   =item editor\(\)->$1$2$2$3$2$4 L<$5|https://www.scintilla.org/ScintillaDoc.html#$5>$2$2=cut$2$2\$autogen{$5} = {$2    subProto => '$1',$2    sciProto => '$5',$2};$2$2
#
#   I can use that for auto-generating a sub framework, or if I use hash notation instead,
#   starting to populate the autoload map

=head1 PythonScript API: Reordered to ScintillaDocs.html order

=head2 Text retrieval and modification

=begin scintilla

SCI_GETTEXT(position length, char *text) → position
SCI_SETTEXT(<unused>, const char *text)
SCI_SETSAVEPOINT
SCI_GETLINE(line line, char *text) → position
SCI_REPLACESEL(<unused>, const char *text)
SCI_SETREADONLY(bool readOnly)
SCI_GETREADONLY → bool
SCI_GETTEXTRANGE(<unused>, Sci_TextRange *tr) → position
SCI_ALLOCATE(position bytes)
SCI_ADDTEXT(position length, const char *text)
SCI_ADDSTYLEDTEXT(position length, cell *c)
SCI_APPENDTEXT(position length, const char *text)
SCI_INSERTTEXT(position pos, const char *text)
SCI_CHANGEINSERTION(position length, const char *text)
SCI_CLEARALL
SCI_DELETERANGE(position start, position lengthDelete)
SCI_CLEARDOCUMENTSTYLE
SCI_GETCHARAT(position pos) → int
SCI_GETSTYLEAT(position pos) → int
SCI_GETSTYLEDTEXT(<unused>, Sci_TextRange *tr) → position
SCI_RELEASEALLEXTENDEDSTYLES
SCI_ALLOCATEEXTENDEDSTYLES(int numberStyles) → int
SCI_TARGETASUTF8(<unused>, char *s) → position
SCI_ENCODEDFROMUTF8(const char *utf8, char *encoded) → position
SCI_SETLENGTHFORENCODE(position bytes)

=end scintilla

=over

=item editor()->setText(text)

Replace the contents of the document with the argument text.

See Scintilla documentation for  L<SCI_SETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTEXT>

=cut

$autogen{SCI_SETTEXT} = {
    subProto => 'setText(text)',
    sciProto => 'SCI_SETTEXT',
};

=item editor()->getText() → str

Retrieve all the text in the document. Returns number of characters retrieved.

See Scintilla documentation for  L<SCI_GETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXT>

=cut

$autogen{SCI_GETTEXT} = {
    subProto => 'getText() → str',
    sciProto => 'SCI_GETTEXT',
};

=item editor()->setSavePoint()

Remember the current position in the undo history as the position at which the document was saved.

See Scintilla documentation for  L<SCI_SETSAVEPOINT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSAVEPOINT>

=cut

$autogen{SCI_SETSAVEPOINT} = {
    subProto => 'setSavePoint()',
    sciProto => 'SCI_SETSAVEPOINT',
};

=item editor()->getLine(line) → str

Retrieve the contents of a line. Returns the length of the line.

See Scintilla documentation for  L<SCI_GETLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINE>

=cut

$autogen{SCI_GETLINE} = {
    subProto => 'getLine(line) → str',
    sciProto => 'SCI_GETLINE',
};

=item editor()->replaceSel(text)

Replace the selected text with the argument text.

See Scintilla documentation for  L<SCI_REPLACESEL|https://www.scintilla.org/ScintillaDoc.html#SCI_REPLACESEL>

=cut

$autogen{SCI_REPLACESEL} = {
    subProto => 'replaceSel(text)',
    sciProto => 'SCI_REPLACESEL',
};

=item editor()->setReadOnly(readOnly)

Set to read only or read write.

See Scintilla documentation for  L<SCI_SETREADONLY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETREADONLY>

=cut

$autogen{SCI_SETREADONLY} = {
    subProto => 'setReadOnly(readOnly)',
    sciProto => 'SCI_SETREADONLY',
};

=item editor()->getReadOnly() → bool

In read-only mode?

See Scintilla documentation for  L<SCI_GETREADONLY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETREADONLY>

=cut

$autogen{SCI_GETREADONLY} = {
    subProto => 'getReadOnly() → bool',
    sciProto => 'SCI_GETREADONLY',
};

=item editor()->getTextRange(start, end) → str

Retrieve a range of text. Return the length of the text.

See Scintilla documentation for  L<SCI_GETTEXTRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXTRANGE>

=cut

$autogen{SCI_GETTEXTRANGE} = {
    subProto => 'getTextRange(start, end) → str',
    sciProto => 'SCI_GETTEXTRANGE',
};

=item editor()->allocate(bytes)

Enlarge the document to a particular size of text bytes.

See Scintilla documentation for  L<SCI_ALLOCATE|https://www.scintilla.org/ScintillaDoc.html#SCI_ALLOCATE>

=cut

$autogen{SCI_ALLOCATE} = {
    subProto => 'allocate(bytes)',
    sciProto => 'SCI_ALLOCATE',
};

=item editor()->addText(text) → int

Add text to the document at current position.

See Scintilla documentation for  L<SCI_ADDTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDTEXT>

=cut

$autogen{SCI_ADDTEXT} = {
    subProto => 'addText(text) → int',
    sciProto => 'SCI_ADDTEXT',
};

=item editor()->addStyledText(c) → int

Add array of cells to document.

See Scintilla documentation for  L<SCI_ADDSTYLEDTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDSTYLEDTEXT>

=cut

$autogen{SCI_ADDSTYLEDTEXT} = {
    subProto => 'addStyledText(c) → int',
    sciProto => 'SCI_ADDSTYLEDTEXT',
};

=item editor()->appendText(text) → int

Append a string to the end of the document without changing the selection.

See Scintilla documentation for  L<SCI_APPENDTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_APPENDTEXT>

=cut

$autogen{SCI_APPENDTEXT} = {
    subProto => 'appendText(text) → int',
    sciProto => 'SCI_APPENDTEXT',
};

=item editor()->insertText(pos, text)

Insert string at a position.

See Scintilla documentation for  L<SCI_INSERTTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_INSERTTEXT>

=cut

$autogen{SCI_INSERTTEXT} = {
    subProto => 'insertText(pos, text)',
    sciProto => 'SCI_INSERTTEXT',
};

=item editor()->SCI_CHANGEINSERTION

TODO

See Scintilla documentation for  L<SCI_CHANGEINSERTION|https://www.scintilla.org/ScintillaDoc.html#SCI_CHANGEINSERTION>

=cut

$autogen{SCI_CHANGEINSERTION} = {
    subProto => 'SCI_CHANGEINSERTION',
    sciProto => 'SCI_CHANGEINSERTION',
};

=item editor()->clearAll()

Delete all text in the document.

See Scintilla documentation for  L<SCI_CLEARALL|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARALL>

=cut

$autogen{SCI_CLEARALL} = {
    subProto => 'clearAll()',
    sciProto => 'SCI_CLEARALL',
};

=item editor()->deleteRange(pos, deleteLength)

Delete a range of text in the document.

See Scintilla documentation for  L<SCI_DELETERANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_DELETERANGE>

=cut

$autogen{SCI_DELETERANGE} = {
    subProto => 'deleteRange(pos, deleteLength)',
    sciProto => 'SCI_DELETERANGE',
};

=item editor()->clearDocumentStyle()

Set all style bytes to 0, remove all folding information.

See Scintilla documentation for  L<SCI_CLEARDOCUMENTSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARDOCUMENTSTYLE>

=cut

$autogen{SCI_CLEARDOCUMENTSTYLE} = {
    subProto => 'clearDocumentStyle()',
    sciProto => 'SCI_CLEARDOCUMENTSTYLE',
};

=item editor()->getCharAt(pos) → int

Returns the character byte at the position.

See Scintilla documentation for  L<SCI_GETCHARAT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCHARAT>

=cut

$autogen{SCI_GETCHARAT} = {
    subProto => 'getCharAt(pos) → int',
    sciProto => 'SCI_GETCHARAT',
};

=item editor()->getStyleAt(pos) → int

Returns the style byte at the position.

See Scintilla documentation for  L<SCI_GETSTYLEAT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEAT>

=cut

$autogen{SCI_GETSTYLEAT} = {
    subProto => 'getStyleAt(pos) → int',
    sciProto => 'SCI_GETSTYLEAT',
};

=item editor()->getStyledText(start, end) → tuple

Retrieve a buffer of cells. Returns the number of bytes in the buffer not including terminating NULs.

See Scintilla documentation for  L<SCI_GETSTYLEDTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEDTEXT>

=cut

$autogen{SCI_GETSTYLEDTEXT} = {
    subProto => 'getStyledText(start, end) → tuple',
    sciProto => 'SCI_GETSTYLEDTEXT',
};

=item editor()->releaseAllExtendedStyles()

Release all extended (>255) style numbers

See Scintilla documentation for  L<SCI_RELEASEALLEXTENDEDSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_RELEASEALLEXTENDEDSTYLES>

=cut

$autogen{SCI_RELEASEALLEXTENDEDSTYLES} = {
    subProto => 'releaseAllExtendedStyles()',
    sciProto => 'SCI_RELEASEALLEXTENDEDSTYLES',
};

=item editor()->allocateExtendedStyles(numberStyles) → int

Allocate some extended (>255) style numbers and return the start of the range

See Scintilla documentation for  L<SCI_ALLOCATEEXTENDEDSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_ALLOCATEEXTENDEDSTYLES>

=cut

$autogen{SCI_ALLOCATEEXTENDEDSTYLES} = {
    subProto => 'allocateExtendedStyles(numberStyles) → int',
    sciProto => 'SCI_ALLOCATEEXTENDEDSTYLES',
};

=item editor()->targetAsUTF8() → str

Returns the target converted to UTF8. Return the length in bytes.

See Scintilla documentation for  L<SCI_TARGETASUTF8|https://www.scintilla.org/ScintillaDoc.html#SCI_TARGETASUTF8>

=cut

$autogen{SCI_TARGETASUTF8} = {
    subProto => 'targetAsUTF8() → str',
    sciProto => 'SCI_TARGETASUTF8',
};

=item editor()->encodedFromUTF8() → str

Translates a UTF8 string into the document encoding. Return the length of the result in bytes. On error return 0.

See Scintilla documentation for  L<SCI_ENCODEDFROMUTF8|https://www.scintilla.org/ScintillaDoc.html#SCI_ENCODEDFROMUTF8>

=cut

$autogen{SCI_ENCODEDFROMUTF8} = {
    subProto => 'encodedFromUTF8() → str',
    sciProto => 'SCI_ENCODEDFROMUTF8',
};

=item editor()->setLengthForEncode(bytes)

Set the length of the utf8 argument for calling EncodedFromUTF8. Set to -1 and the string will be measured to the first nul.

See Scintilla documentation for  L<SCI_SETLENGTHFORENCODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLENGTHFORENCODE>

=cut

$autogen{SCI_SETLENGTHFORENCODE} = {
    subProto => 'setLengthForEncode(bytes)',
    sciProto => 'SCI_SETLENGTHFORENCODE',
};

=back

=head2 Searching

=begin scintilla

SCI_SETTARGETSTART(position start)
SCI_GETTARGETSTART → position
SCI_SETTARGETEND(position end)
SCI_GETTARGETEND → position
SCI_SETTARGETRANGE(position start, position end)
SCI_TARGETFROMSELECTION
SCI_TARGETWHOLEDOCUMENT
SCI_SETSEARCHFLAGS(int searchFlags)
SCI_GETSEARCHFLAGS → int
SCI_SEARCHINTARGET(position length, const char *text) → position
SCI_GETTARGETTEXT(<unused>, char *text) → position
SCI_REPLACETARGET(position length, const char *text) → position
SCI_REPLACETARGETRE(position length, const char *text) → position
SCI_GETTAG(int tagNumber, char *tagValue) → int

SCI_FINDTEXT(int searchFlags, Sci_TextToFind *ft) → position
SCI_SEARCHANCHOR
SCI_SEARCHNEXT(int searchFlags, const char *text) → position
SCI_SEARCHPREV(int searchFlags, const char *text) → position

=end scintilla

=over

=item editor()->setTargetStart(pos)

Sets the position that starts the target which is used for updating the document without affecting the scroll position.

See Scintilla documentation for  L<SCI_SETTARGETSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTARGETSTART>

=cut

$autogen{SCI_SETTARGETSTART} = {
    subProto => 'setTargetStart(pos)',
    sciProto => 'SCI_SETTARGETSTART',
};

=item editor()->getTargetStart() → int

Get the position that starts the target.

See Scintilla documentation for  L<SCI_GETTARGETSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTARGETSTART>

=cut

$autogen{SCI_GETTARGETSTART} = {
    subProto => 'getTargetStart() → int',
    sciProto => 'SCI_GETTARGETSTART',
};

=item editor()->setTargetEnd(pos)

Sets the position that ends the target which is used for updating the document without affecting the scroll position.

See Scintilla documentation for  L<SCI_SETTARGETEND|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTARGETEND>

=cut

$autogen{SCI_SETTARGETEND} = {
    subProto => 'setTargetEnd(pos)',
    sciProto => 'SCI_SETTARGETEND',
};

=item editor()->getTargetEnd() → int

Get the position that ends the target.

See Scintilla documentation for  L<SCI_GETTARGETEND|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTARGETEND>

=cut

$autogen{SCI_GETTARGETEND} = {
    subProto => 'getTargetEnd() → int',
    sciProto => 'SCI_GETTARGETEND',
};

=item editor()->SCI_SETTARGETRANGE

TODO

See Scintilla documentation for  L<SCI_SETTARGETRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTARGETRANGE>

=cut

$autogen{SCI_SETTARGETRANGE} = {
    subProto => 'SCI_SETTARGETRANGE',
    sciProto => 'SCI_SETTARGETRANGE',
};

=item editor()->targetFromSelection()

Make the target range start and end be the same as the selection range start and end.

See Scintilla documentation for  L<SCI_TARGETFROMSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_TARGETFROMSELECTION>

=cut

$autogen{SCI_TARGETFROMSELECTION} = {
    subProto => 'targetFromSelection()',
    sciProto => 'SCI_TARGETFROMSELECTION',
};

=item editor()->SCI_TARGETWHOLEDOCUMENT

TODO

See Scintilla documentation for  L<SCI_TARGETWHOLEDOCUMENT|https://www.scintilla.org/ScintillaDoc.html#SCI_TARGETWHOLEDOCUMENT>

=cut

$autogen{SCI_TARGETWHOLEDOCUMENT} = {
    subProto => 'SCI_TARGETWHOLEDOCUMENT',
    sciProto => 'SCI_TARGETWHOLEDOCUMENT',
};

=item editor()->setSearchFlags(flags)

Set the search flags used by SearchInTarget.

See Scintilla documentation for  L<SCI_SETSEARCHFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSEARCHFLAGS>

=cut

$autogen{SCI_SETSEARCHFLAGS} = {
    subProto => 'setSearchFlags(flags)',
    sciProto => 'SCI_SETSEARCHFLAGS',
};

=item editor()->getSearchFlags() → int

Get the search flags used by SearchInTarget.

See Scintilla documentation for  L<SCI_GETSEARCHFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSEARCHFLAGS>

=cut

$autogen{SCI_GETSEARCHFLAGS} = {
    subProto => 'getSearchFlags() → int',
    sciProto => 'SCI_GETSEARCHFLAGS',
};

=item editor()->searchInTarget(text) → int

Search for a counted string in the target and set the target to the found range. Text is counted so it can contain NULs. Returns length of range or -1 for failure in which case target is not moved.

See Scintilla documentation for  L<SCI_SEARCHINTARGET|https://www.scintilla.org/ScintillaDoc.html#SCI_SEARCHINTARGET>

=cut

$autogen{SCI_SEARCHINTARGET} = {
    subProto => 'searchInTarget(text) → int',
    sciProto => 'SCI_SEARCHINTARGET',
};

=item editor()->SCI_GETTARGETTEXT

TODO

See Scintilla documentation for  L<SCI_GETTARGETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTARGETTEXT>

=cut

$autogen{SCI_GETTARGETTEXT} = {
    subProto => 'SCI_GETTARGETTEXT',
    sciProto => 'SCI_GETTARGETTEXT',
};

=item editor()->replaceTarget(text) → int

Replace the target text with the argument text. Text is counted so it can contain NULs. Returns the length of the replacement text.

See Scintilla documentation for  L<SCI_REPLACETARGET|https://www.scintilla.org/ScintillaDoc.html#SCI_REPLACETARGET>

=cut

$autogen{SCI_REPLACETARGET} = {
    subProto => 'replaceTarget(text) → int',
    sciProto => 'SCI_REPLACETARGET',
};

=item editor()->replaceTargetRE(text) → int

Replace the target text with the argument text after \d processing. Text is counted so it can contain NULs. Looks for \d where d is between 1 and 9 and replaces these with the strings matched in the last search operation which were surrounded by \( and \). Returns the length of the replacement text including any change caused by processing the \d patterns.

See Scintilla documentation for  L<SCI_REPLACETARGETRE|https://www.scintilla.org/ScintillaDoc.html#SCI_REPLACETARGETRE>

=cut

$autogen{SCI_REPLACETARGETRE} = {
    subProto => 'replaceTargetRE(text) → int',
    sciProto => 'SCI_REPLACETARGETRE',
};

=item editor()->getTag(tagNumber) → str

Retrieve the value of a tag from a regular expression search.

See Scintilla documentation for  L<SCI_GETTAG|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTAG>

=cut

$autogen{SCI_GETTAG} = {
    subProto => 'getTag(tagNumber) → str',
    sciProto => 'SCI_GETTAG',
};

=item editor()->findText(flags, start, end, ft) → object

Find some text in the document.

See Scintilla documentation for  L<SCI_FINDTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_FINDTEXT>

=cut

$autogen{SCI_FINDTEXT} = {
    subProto => 'findText(flags, start, end, ft) → object',
    sciProto => 'SCI_FINDTEXT',
};

=item editor()->searchAnchor()

Sets the current caret position to be the search anchor.

See Scintilla documentation for  L<SCI_SEARCHANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_SEARCHANCHOR>

=cut

$autogen{SCI_SEARCHANCHOR} = {
    subProto => 'searchAnchor()',
    sciProto => 'SCI_SEARCHANCHOR',
};

=item editor()->searchNext(flags, text) → int

Find some text starting at the search anchor. Does not ensure the selection is visible.

See Scintilla documentation for  L<SCI_SEARCHNEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_SEARCHNEXT>

=cut

$autogen{SCI_SEARCHNEXT} = {
    subProto => 'searchNext(flags, text) → int',
    sciProto => 'SCI_SEARCHNEXT',
};

=item editor()->searchPrev(flags, text) → int

Find some text starting at the search anchor and moving backwards. Does not ensure the selection is visible.

See Scintilla documentation for  L<SCI_SEARCHPREV|https://www.scintilla.org/ScintillaDoc.html#SCI_SEARCHPREV>

=cut

$autogen{SCI_SEARCHPREV} = {
    subProto => 'searchPrev(flags, text) → int',
    sciProto => 'SCI_SEARCHPREV',
};

=back

=head2 Overtype

=begin scintilla

SCI_SETOVERTYPE(bool overType)
SCI_GETOVERTYPE → bool

=end scintilla

=over

=item editor()->setOvertype(overtype)

Set to overtype (true) or insert mode.

See Scintilla documentation for  L<SCI_SETOVERTYPE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETOVERTYPE>

=cut

$autogen{SCI_SETOVERTYPE} = {
    subProto => 'setOvertype(overtype)',
    sciProto => 'SCI_SETOVERTYPE',
};

=item editor()->getOvertype() → bool

Returns true if overtype mode is active otherwise false is returned.

See Scintilla documentation for  L<SCI_GETOVERTYPE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETOVERTYPE>

=cut

$autogen{SCI_GETOVERTYPE} = {
    subProto => 'getOvertype() → bool',
    sciProto => 'SCI_GETOVERTYPE',
};

=back

=head2 Cut, Copy, and Paste

=begin scintilla

SCI_CUT
SCI_COPY
SCI_PASTE
SCI_CLEAR
SCI_CANPASTE → bool
SCI_COPYRANGE(position start, position end)
SCI_COPYTEXT(position length, const char *text)
SCI_COPYALLOWLINE
SCI_SETPASTECONVERTENDINGS(bool convert)
SCI_GETPASTECONVERTENDINGS → bool

=end scintilla

=over

=item editor()->cut()

Cut the selection to the clipboard.

See Scintilla documentation for  L<SCI_CUT|https://www.scintilla.org/ScintillaDoc.html#SCI_CUT>

=cut

$autogen{SCI_CUT} = {
    subProto => 'cut()',
    sciProto => 'SCI_CUT',
};

=item editor()->copy()

Copy the selection to the clipboard.

See Scintilla documentation for  L<SCI_COPY|https://www.scintilla.org/ScintillaDoc.html#SCI_COPY>

=cut

$autogen{SCI_COPY} = {
    subProto => 'copy()',
    sciProto => 'SCI_COPY',
};

=item editor()->paste()

Paste the contents of the clipboard into the document replacing the selection.

See Scintilla documentation for  L<SCI_PASTE|https://www.scintilla.org/ScintillaDoc.html#SCI_PASTE>

=cut

$autogen{SCI_PASTE} = {
    subProto => 'paste()',
    sciProto => 'SCI_PASTE',
};

=item editor()->clear()

Clear the selection.

See Scintilla documentation for  L<SCI_CLEAR|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEAR>

=cut

$autogen{SCI_CLEAR} = {
    subProto => 'clear()',
    sciProto => 'SCI_CLEAR',
};

=item editor()->canPaste() → bool

Will a paste succeed?

See Scintilla documentation for  L<SCI_CANPASTE|https://www.scintilla.org/ScintillaDoc.html#SCI_CANPASTE>

=cut

$autogen{SCI_CANPASTE} = {
    subProto => 'canPaste() → bool',
    sciProto => 'SCI_CANPASTE',
};

=item editor()->copyRange(start, end)

Copy a range of text to the clipboard. Positions are clipped into the document.

See Scintilla documentation for  L<SCI_COPYRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_COPYRANGE>

=cut

$autogen{SCI_COPYRANGE} = {
    subProto => 'copyRange(start, end)',
    sciProto => 'SCI_COPYRANGE',
};

=item editor()->copyText(text) → int

Copy argument text to the clipboard.

See Scintilla documentation for  L<SCI_COPYTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_COPYTEXT>

=cut

$autogen{SCI_COPYTEXT} = {
    subProto => 'copyText(text) → int',
    sciProto => 'SCI_COPYTEXT',
};

=item editor()->copyAllowLine()

Copy the selection, if selection empty copy the line with the caret

See Scintilla documentation for  L<SCI_COPYALLOWLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_COPYALLOWLINE>

=cut

$autogen{SCI_COPYALLOWLINE} = {
    subProto => 'copyAllowLine()',
    sciProto => 'SCI_COPYALLOWLINE',
};

=item editor()->setPasteConvertEndings(convert)

Enable/Disable convert-on-paste for line endings

See Scintilla documentation for  L<SCI_SETPASTECONVERTENDINGS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPASTECONVERTENDINGS>

=cut

$autogen{SCI_SETPASTECONVERTENDINGS} = {
    subProto => 'setPasteConvertEndings(convert)',
    sciProto => 'SCI_SETPASTECONVERTENDINGS',
};

=item editor()->getPasteConvertEndings() → bool

Get convert-on-paste setting

See Scintilla documentation for  L<SCI_GETPASTECONVERTENDINGS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPASTECONVERTENDINGS>

=cut

$autogen{SCI_GETPASTECONVERTENDINGS} = {
    subProto => 'getPasteConvertEndings() → bool',
    sciProto => 'SCI_GETPASTECONVERTENDINGS',
};

=back

=head2 Error handling

=begin scintilla

SCI_SETSTATUS(int status)
SCI_GETSTATUS → int

=end scintilla

=over

=item editor()->setStatus(statusCode)

Change error status - 0 = OK.

See Scintilla documentation for  L<SCI_SETSTATUS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSTATUS>

=cut

$autogen{SCI_SETSTATUS} = {
    subProto => 'setStatus(statusCode)',
    sciProto => 'SCI_SETSTATUS',
};

=item editor()->getStatus() → int

Get error status.

See Scintilla documentation for  L<SCI_GETSTATUS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSTATUS>

=cut

$autogen{SCI_GETSTATUS} = {
    subProto => 'getStatus() → int',
    sciProto => 'SCI_GETSTATUS',
};

=back

=head2 Undo and redo

=begin scintilla

SCI_UNDO
SCI_CANUNDO → bool
SCI_EMPTYUNDOBUFFER
SCI_REDO
SCI_CANREDO → bool
SCI_SETUNDOCOLLECTION(bool collectUndo)
SCI_GETUNDOCOLLECTION → bool
SCI_BEGINUNDOACTION
SCI_ENDUNDOACTION
SCI_ADDUNDOACTION(int token, int flags)

=end scintilla

=over

=item editor()->undo()

Undo one action in the undo history.

See Scintilla documentation for  L<SCI_UNDO|https://www.scintilla.org/ScintillaDoc.html#SCI_UNDO>

=cut

$autogen{SCI_UNDO} = {
    subProto => 'undo()',
    sciProto => 'SCI_UNDO',
};

=item editor()->canUndo() → bool

Are there any undoable actions in the undo history?

See Scintilla documentation for  L<SCI_CANUNDO|https://www.scintilla.org/ScintillaDoc.html#SCI_CANUNDO>

=cut

$autogen{SCI_CANUNDO} = {
    subProto => 'canUndo() → bool',
    sciProto => 'SCI_CANUNDO',
};

=item editor()->emptyUndoBuffer()

Delete the undo history.

See Scintilla documentation for  L<SCI_EMPTYUNDOBUFFER|https://www.scintilla.org/ScintillaDoc.html#SCI_EMPTYUNDOBUFFER>

=cut

$autogen{SCI_EMPTYUNDOBUFFER} = {
    subProto => 'emptyUndoBuffer()',
    sciProto => 'SCI_EMPTYUNDOBUFFER',
};

=item editor()->canRedo() → bool

Are there any redoable actions in the undo history?

See Scintilla documentation for  L<SCI_CANREDO|https://www.scintilla.org/ScintillaDoc.html#SCI_CANREDO>

=cut

$autogen{SCI_CANREDO} = {
    subProto => 'canRedo() → bool',
    sciProto => 'SCI_CANREDO',
};

=item editor()->redo()

Redoes the next action on the undo history.

See Scintilla documentation for  L<SCI_REDO|https://www.scintilla.org/ScintillaDoc.html#SCI_REDO>

=cut

$autogen{SCI_REDO} = {
    subProto => 'redo()',
    sciProto => 'SCI_REDO',
};

=item editor()->setUndoCollection(collectUndo)

Choose between collecting actions into the undo history and discarding them.

See Scintilla documentation for  L<SCI_SETUNDOCOLLECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETUNDOCOLLECTION>

=cut

$autogen{SCI_SETUNDOCOLLECTION} = {
    subProto => 'setUndoCollection(collectUndo)',
    sciProto => 'SCI_SETUNDOCOLLECTION',
};

=item editor()->getUndoCollection() → bool

Is undo history being collected?

See Scintilla documentation for  L<SCI_GETUNDOCOLLECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETUNDOCOLLECTION>

=cut

$autogen{SCI_GETUNDOCOLLECTION} = {
    subProto => 'getUndoCollection() → bool',
    sciProto => 'SCI_GETUNDOCOLLECTION',
};

=item editor()->beginUndoAction()

Start a sequence of actions that is undone and redone as a unit. May be nested.

See Scintilla documentation for  L<SCI_BEGINUNDOACTION|https://www.scintilla.org/ScintillaDoc.html#SCI_BEGINUNDOACTION>

=cut

$autogen{SCI_BEGINUNDOACTION} = {
    subProto => 'beginUndoAction()',
    sciProto => 'SCI_BEGINUNDOACTION',
};

=item editor()->endUndoAction()

End a sequence of actions that is undone and redone as a unit.

See Scintilla documentation for  L<SCI_ENDUNDOACTION|https://www.scintilla.org/ScintillaDoc.html#SCI_ENDUNDOACTION>

=cut

$autogen{SCI_ENDUNDOACTION} = {
    subProto => 'endUndoAction()',
    sciProto => 'SCI_ENDUNDOACTION',
};

=item editor()->addUndoAction(token, flags)

Add a container action to the undo stack

See Scintilla documentation for  L<SCI_ADDUNDOACTION|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDUNDOACTION>

=cut

$autogen{SCI_ADDUNDOACTION} = {
    subProto => 'addUndoAction(token, flags)',
    sciProto => 'SCI_ADDUNDOACTION',
};

=back

=head2 Selection and information

=begin scintilla

SCI_GETTEXTLENGTH → position
SCI_GETLENGTH → position
SCI_GETLINECOUNT → line
SCI_LINESONSCREEN → line
SCI_GETMODIFY → bool
SCI_SETSEL(position anchor, position caret)
SCI_GOTOPOS(position caret)
SCI_GOTOLINE(line line)
SCI_SETCURRENTPOS(position caret)
SCI_GETCURRENTPOS → position
SCI_SETANCHOR(position anchor)
SCI_GETANCHOR → position
SCI_SETSELECTIONSTART(position anchor)
SCI_GETSELECTIONSTART → position
SCI_SETSELECTIONEND(position caret)
SCI_GETSELECTIONEND → position
SCI_SETEMPTYSELECTION(position caret)
SCI_SELECTALL
SCI_LINEFROMPOSITION(position pos) → line
SCI_POSITIONFROMLINE(line line) → position
SCI_GETLINEENDPOSITION(line line) → position
SCI_LINELENGTH(line line) → position
SCI_GETCOLUMN(position pos) → position
SCI_FINDCOLUMN(line line, position column) → position
SCI_POSITIONFROMPOINT(int x, int y) → position
SCI_POSITIONFROMPOINTCLOSE(int x, int y) → position
SCI_CHARPOSITIONFROMPOINT(int x, int y) → position
SCI_CHARPOSITIONFROMPOINTCLOSE(int x, int y) → position
SCI_POINTXFROMPOSITION(<unused>, position pos) → int
SCI_POINTYFROMPOSITION(<unused>, position pos) → int
SCI_HIDESELECTION(bool hide)
SCI_GETSELTEXT(<unused>, char *text) → position
SCI_GETCURLINE(position length, char *text) → position
SCI_SELECTIONISRECTANGLE → bool
SCI_SETSELECTIONMODE(int selectionMode)
SCI_GETSELECTIONMODE → int
SCI_GETMOVEEXTENDSSELECTION → bool
SCI_GETLINESELSTARTPOSITION(line line) → position
SCI_GETLINESELENDPOSITION(line line) → position
SCI_MOVECARETINSIDEVIEW
SCI_POSITIONBEFORE(position pos) → position
SCI_POSITIONAFTER(position pos) → position
SCI_TEXTWIDTH(int style, const char *text) → int
SCI_TEXTHEIGHT(line line) → int
SCI_CHOOSECARETX
SCI_MOVESELECTEDLINESUP
SCI_MOVESELECTEDLINESDOWN
SCI_SETMOUSESELECTIONRECTANGULARSWITCH(bool mouseSelectionRectangularSwitch)
SCI_GETMOUSESELECTIONRECTANGULARSWITCH → bool

=end scintilla

=over

=item editor()->getTextLength() → int

Retrieve the number of characters in the document.

See Scintilla documentation for  L<SCI_GETTEXTLENGTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXTLENGTH>

=cut

$autogen{SCI_GETTEXTLENGTH} = {
    subProto => 'getTextLength() → int',
    sciProto => 'SCI_GETTEXTLENGTH',
};

=item editor()->getLength() → int

Returns the number of bytes in the document.

See Scintilla documentation for  L<SCI_GETLENGTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLENGTH>

=cut

$autogen{SCI_GETLENGTH} = {
    subProto => 'getLength() → int',
    sciProto => 'SCI_GETLENGTH',
};

=item editor()->getLineCount() → int

Returns the number of lines in the document. There is always at least one.

See Scintilla documentation for  L<SCI_GETLINECOUNT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINECOUNT>

=cut

$autogen{SCI_GETLINECOUNT} = {
    subProto => 'getLineCount() → int',
    sciProto => 'SCI_GETLINECOUNT',
};

=item editor()->linesOnScreen() → int

Retrieves the number of lines completely visible.

See Scintilla documentation for  L<SCI_LINESONSCREEN|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESONSCREEN>

=cut

$autogen{SCI_LINESONSCREEN} = {
    subProto => 'linesOnScreen() → int',
    sciProto => 'SCI_LINESONSCREEN',
};

=item editor()->getModify() → bool

Is the document different from when it was last saved?

See Scintilla documentation for  L<SCI_GETMODIFY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMODIFY>

=cut

$autogen{SCI_GETMODIFY} = {
    subProto => 'getModify() → bool',
    sciProto => 'SCI_GETMODIFY',
};

=item editor()->setSel(start, end)

Select a range of text.

See Scintilla documentation for  L<SCI_SETSEL|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSEL>

=cut

$autogen{SCI_SETSEL} = {
    subProto => 'setSel(start, end)',
    sciProto => 'SCI_SETSEL',
};

=item editor()->gotoPos(pos)

Set caret to a position and ensure it is visible.

See Scintilla documentation for  L<SCI_GOTOPOS|https://www.scintilla.org/ScintillaDoc.html#SCI_GOTOPOS>

=cut

$autogen{SCI_GOTOPOS} = {
    subProto => 'gotoPos(pos)',
    sciProto => 'SCI_GOTOPOS',
};

=item editor()->gotoLine(line)

Set caret to start of a line and ensure it is visible.

See Scintilla documentation for  L<SCI_GOTOLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GOTOLINE>

=cut

$autogen{SCI_GOTOLINE} = {
    subProto => 'gotoLine(line)',
    sciProto => 'SCI_GOTOLINE',
};

=item editor()->setCurrentPos(pos)

Sets the position of the caret.

See Scintilla documentation for  L<SCI_SETCURRENTPOS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCURRENTPOS>

=cut

$autogen{SCI_SETCURRENTPOS} = {
    subProto => 'setCurrentPos(pos)',
    sciProto => 'SCI_SETCURRENTPOS',
};

=item editor()->getCurrentPos() → int

Returns the position of the caret.

See Scintilla documentation for  L<SCI_GETCURRENTPOS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCURRENTPOS>

=cut

$autogen{SCI_GETCURRENTPOS} = {
    subProto => 'getCurrentPos() → int',
    sciProto => 'SCI_GETCURRENTPOS',
};

=item editor()->setAnchor(posAnchor)

Set the selection anchor to a position. The anchor is the opposite end of the selection from the caret.

See Scintilla documentation for  L<SCI_SETANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETANCHOR>

=cut

$autogen{SCI_SETANCHOR} = {
    subProto => 'setAnchor(posAnchor)',
    sciProto => 'SCI_SETANCHOR',
};

=item editor()->getAnchor() → int

Returns the position of the opposite end of the selection to the caret.

See Scintilla documentation for  L<SCI_GETANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETANCHOR>

=cut

$autogen{SCI_GETANCHOR} = {
    subProto => 'getAnchor() → int',
    sciProto => 'SCI_GETANCHOR',
};

=item editor()->setSelectionStart(pos)

Sets the position that starts the selection - this becomes the anchor.

See Scintilla documentation for  L<SCI_SETSELECTIONSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONSTART>

=cut

$autogen{SCI_SETSELECTIONSTART} = {
    subProto => 'setSelectionStart(pos)',
    sciProto => 'SCI_SETSELECTIONSTART',
};

=item editor()->getSelectionStart() → int

Returns the position at the start of the selection.

See Scintilla documentation for  L<SCI_GETSELECTIONSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONSTART>

=cut

$autogen{SCI_GETSELECTIONSTART} = {
    subProto => 'getSelectionStart() → int',
    sciProto => 'SCI_GETSELECTIONSTART',
};

=item editor()->setSelectionEnd(pos)

Sets the position that ends the selection - this becomes the currentPosition.

See Scintilla documentation for  L<SCI_SETSELECTIONEND|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONEND>

=cut

$autogen{SCI_SETSELECTIONEND} = {
    subProto => 'setSelectionEnd(pos)',
    sciProto => 'SCI_SETSELECTIONEND',
};

=item editor()->getSelectionEnd() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETSELECTIONEND|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONEND>

=cut

$autogen{SCI_GETSELECTIONEND} = {
    subProto => 'getSelectionEnd() → int',
    sciProto => 'SCI_GETSELECTIONEND',
};

=item editor()->setEmptySelection(pos)

Set caret to a position, while removing any existing selection.

See Scintilla documentation for  L<SCI_SETEMPTYSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEMPTYSELECTION>

=cut

$autogen{SCI_SETEMPTYSELECTION} = {
    subProto => 'setEmptySelection(pos)',
    sciProto => 'SCI_SETEMPTYSELECTION',
};

=item editor()->selectAll()

Select all the text in the document.

See Scintilla documentation for  L<SCI_SELECTALL|https://www.scintilla.org/ScintillaDoc.html#SCI_SELECTALL>

=cut

$autogen{SCI_SELECTALL} = {
    subProto => 'selectAll()',
    sciProto => 'SCI_SELECTALL',
};

=item editor()->lineFromPosition(pos) → int

Retrieve the line containing a position.

See Scintilla documentation for  L<SCI_LINEFROMPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEFROMPOSITION>

=cut

$autogen{SCI_LINEFROMPOSITION} = {
    subProto => 'lineFromPosition(pos) → int',
    sciProto => 'SCI_LINEFROMPOSITION',
};

=item editor()->positionFromLine(line) → int

Retrieve the position at the start of a line.

See Scintilla documentation for  L<SCI_POSITIONFROMLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONFROMLINE>

=cut

$autogen{SCI_POSITIONFROMLINE} = {
    subProto => 'positionFromLine(line) → int',
    sciProto => 'SCI_POSITIONFROMLINE',
};

=item editor()->getLineEndPosition(line) → int

Get the position after the last visible characters on a line.

See Scintilla documentation for  L<SCI_GETLINEENDPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEENDPOSITION>

=cut

$autogen{SCI_GETLINEENDPOSITION} = {
    subProto => 'getLineEndPosition(line) → int',
    sciProto => 'SCI_GETLINEENDPOSITION',
};

=item editor()->lineLength(line) → int

How many characters are on a line, including end of line characters?

See Scintilla documentation for  L<SCI_LINELENGTH|https://www.scintilla.org/ScintillaDoc.html#SCI_LINELENGTH>

=cut

$autogen{SCI_LINELENGTH} = {
    subProto => 'lineLength(line) → int',
    sciProto => 'SCI_LINELENGTH',
};

=item editor()->getColumn(pos) → int

Retrieve the column number of a position, taking tab width into account.

See Scintilla documentation for  L<SCI_GETCOLUMN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCOLUMN>

=cut

$autogen{SCI_GETCOLUMN} = {
    subProto => 'getColumn(pos) → int',
    sciProto => 'SCI_GETCOLUMN',
};

=item editor()->findColumn(line, column) → int

Find the position of a column on a line taking into account tabs and multi-byte characters. If beyond end of line, return line end position.

See Scintilla documentation for  L<SCI_FINDCOLUMN|https://www.scintilla.org/ScintillaDoc.html#SCI_FINDCOLUMN>

=cut

$autogen{SCI_FINDCOLUMN} = {
    subProto => 'findColumn(line, column) → int',
    sciProto => 'SCI_FINDCOLUMN',
};

=item editor()->positionFromPoint(x, y) → int

Find the position from a point within the window.

See Scintilla documentation for  L<SCI_POSITIONFROMPOINT|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONFROMPOINT>

=cut

$autogen{SCI_POSITIONFROMPOINT} = {
    subProto => 'positionFromPoint(x, y) → int',
    sciProto => 'SCI_POSITIONFROMPOINT',
};

=item editor()->positionFromPointClose(x, y) → int

Find the position from a point within the window but return INVALID_POSITION if not close to text.

See Scintilla documentation for  L<SCI_POSITIONFROMPOINTCLOSE|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONFROMPOINTCLOSE>

=cut

$autogen{SCI_POSITIONFROMPOINTCLOSE} = {
    subProto => 'positionFromPointClose(x, y) → int',
    sciProto => 'SCI_POSITIONFROMPOINTCLOSE',
};

=item editor()->charPositionFromPoint(x, y) → int

Find the position of a character from a point within the window.

See Scintilla documentation for  L<SCI_CHARPOSITIONFROMPOINT|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARPOSITIONFROMPOINT>

=cut

$autogen{SCI_CHARPOSITIONFROMPOINT} = {
    subProto => 'charPositionFromPoint(x, y) → int',
    sciProto => 'SCI_CHARPOSITIONFROMPOINT',
};

=item editor()->charPositionFromPointClose(x, y) → int

Find the position of a character from a point within the window. Return INVALID_POSITION if not close to text.

See Scintilla documentation for  L<SCI_CHARPOSITIONFROMPOINTCLOSE|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARPOSITIONFROMPOINTCLOSE>

=cut

$autogen{SCI_CHARPOSITIONFROMPOINTCLOSE} = {
    subProto => 'charPositionFromPointClose(x, y) → int',
    sciProto => 'SCI_CHARPOSITIONFROMPOINTCLOSE',
};

=item editor()->pointXFromPosition(pos) → int

Retrieve the x value of the point in the window where a position is displayed.

See Scintilla documentation for  L<SCI_POINTXFROMPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_POINTXFROMPOSITION>

=cut

$autogen{SCI_POINTXFROMPOSITION} = {
    subProto => 'pointXFromPosition(pos) → int',
    sciProto => 'SCI_POINTXFROMPOSITION',
};

=item editor()->pointYFromPosition(pos) → int

Retrieve the y value of the point in the window where a position is displayed.

See Scintilla documentation for  L<SCI_POINTYFROMPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_POINTYFROMPOSITION>

=cut

$autogen{SCI_POINTYFROMPOSITION} = {
    subProto => 'pointYFromPosition(pos) → int',
    sciProto => 'SCI_POINTYFROMPOSITION',
};

=item editor()->hideSelection(normal)

Draw the selection in normal style or with selection highlighted.

See Scintilla documentation for  L<SCI_HIDESELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_HIDESELECTION>

=cut

$autogen{SCI_HIDESELECTION} = {
    subProto => 'hideSelection(normal)',
    sciProto => 'SCI_HIDESELECTION',
};

=item editor()->getSelText() → str

Retrieve the selected text. Return the length of the text.

See Scintilla documentation for  L<SCI_GETSELTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELTEXT>

=cut

$autogen{SCI_GETSELTEXT} = {
    subProto => 'getSelText() → str',
    sciProto => 'SCI_GETSELTEXT',
};

=item editor()->getCurLine() → str

Retrieve the text of the line containing the caret. Returns the index of the caret on the line.

See Scintilla documentation for  L<SCI_GETCURLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCURLINE>

=cut

$autogen{SCI_GETCURLINE} = {
    subProto => 'getCurLine() → str',
    sciProto => 'SCI_GETCURLINE',
};

=item editor()->selectionIsRectangle() → bool

Is the selection rectangular? The alternative is the more common stream selection.

See Scintilla documentation for  L<SCI_SELECTIONISRECTANGLE|https://www.scintilla.org/ScintillaDoc.html#SCI_SELECTIONISRECTANGLE>

=cut

$autogen{SCI_SELECTIONISRECTANGLE} = {
    subProto => 'selectionIsRectangle() → bool',
    sciProto => 'SCI_SELECTIONISRECTANGLE',
};

=item editor()->setSelectionMode(mode)

Set the selection mode to stream (SC_SEL_STREAM) or rectangular (SC_SEL_RECTANGLE/SC_SEL_THIN) or by lines (SC_SEL_LINES).

See Scintilla documentation for  L<SCI_SETSELECTIONMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONMODE>

=cut

$autogen{SCI_SETSELECTIONMODE} = {
    subProto => 'setSelectionMode(mode)',
    sciProto => 'SCI_SETSELECTIONMODE',
};

=item editor()->getSelectionMode() → int

Get the mode of the current selection.

See Scintilla documentation for  L<SCI_GETSELECTIONMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONMODE>

=cut

$autogen{SCI_GETSELECTIONMODE} = {
    subProto => 'getSelectionMode() → int',
    sciProto => 'SCI_GETSELECTIONMODE',
};

=item editor()->SCI_GETMOVEEXTENDSSELECTION

TODO

See Scintilla documentation for  L<SCI_GETMOVEEXTENDSSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMOVEEXTENDSSELECTION>

=cut

$autogen{SCI_GETMOVEEXTENDSSELECTION} = {
    subProto => 'SCI_GETMOVEEXTENDSSELECTION',
    sciProto => 'SCI_GETMOVEEXTENDSSELECTION',
};

=item editor()->getLineSelStartPosition(line) → int

Retrieve the position of the start of the selection at the given line (INVALID_POSITION if no selection on this line).

See Scintilla documentation for  L<SCI_GETLINESELSTARTPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINESELSTARTPOSITION>

=cut

$autogen{SCI_GETLINESELSTARTPOSITION} = {
    subProto => 'getLineSelStartPosition(line) → int',
    sciProto => 'SCI_GETLINESELSTARTPOSITION',
};

=item editor()->getLineSelEndPosition(line) → int

Retrieve the position of the end of the selection at the given line (INVALID_POSITION if no selection on this line).

See Scintilla documentation for  L<SCI_GETLINESELENDPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINESELENDPOSITION>

=cut

$autogen{SCI_GETLINESELENDPOSITION} = {
    subProto => 'getLineSelEndPosition(line) → int',
    sciProto => 'SCI_GETLINESELENDPOSITION',
};

=item editor()->moveCaretInsideView()

Move the caret inside current view if it’s not there already.

See Scintilla documentation for  L<SCI_MOVECARETINSIDEVIEW|https://www.scintilla.org/ScintillaDoc.html#SCI_MOVECARETINSIDEVIEW>

=cut

$autogen{SCI_MOVECARETINSIDEVIEW} = {
    subProto => 'moveCaretInsideView()',
    sciProto => 'SCI_MOVECARETINSIDEVIEW',
};

=item editor()->positionBefore(pos) → int

Given a valid document position, return the previous position taking code page into account. Returns 0 if passed 0.

See Scintilla documentation for  L<SCI_POSITIONBEFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONBEFORE>

=cut

$autogen{SCI_POSITIONBEFORE} = {
    subProto => 'positionBefore(pos) → int',
    sciProto => 'SCI_POSITIONBEFORE',
};

=item editor()->positionAfter(pos) → int

Given a valid document position, return the next position taking code page into account. Maximum value returned is the last position in the document.

See Scintilla documentation for  L<SCI_POSITIONAFTER|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONAFTER>

=cut

$autogen{SCI_POSITIONAFTER} = {
    subProto => 'positionAfter(pos) → int',
    sciProto => 'SCI_POSITIONAFTER',
};

=item editor()->textWidth(style, text) → int

Measure the pixel width of some text in a particular style. NUL terminated text argument. Does not handle tab or control characters.

See Scintilla documentation for  L<SCI_TEXTWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_TEXTWIDTH>

=cut

$autogen{SCI_TEXTWIDTH} = {
    subProto => 'textWidth(style, text) → int',
    sciProto => 'SCI_TEXTWIDTH',
};

=item editor()->textHeight(line) → int

Retrieve the height of a particular line of text in pixels.

See Scintilla documentation for  L<SCI_TEXTHEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_TEXTHEIGHT>

=cut

$autogen{SCI_TEXTHEIGHT} = {
    subProto => 'textHeight(line) → int',
    sciProto => 'SCI_TEXTHEIGHT',
};

=item editor()->chooseCaretX()

Set the last x chosen value to be the caret x position.

See Scintilla documentation for  L<SCI_CHOOSECARETX|https://www.scintilla.org/ScintillaDoc.html#SCI_CHOOSECARETX>

=cut

$autogen{SCI_CHOOSECARETX} = {
    subProto => 'chooseCaretX()',
    sciProto => 'SCI_CHOOSECARETX',
};

=item editor()->moveSelectedLinesUp()

Move the selected lines up one line, shifting the line above after the selection

See Scintilla documentation for  L<SCI_MOVESELECTEDLINESUP|https://www.scintilla.org/ScintillaDoc.html#SCI_MOVESELECTEDLINESUP>

=cut

$autogen{SCI_MOVESELECTEDLINESUP} = {
    subProto => 'moveSelectedLinesUp()',
    sciProto => 'SCI_MOVESELECTEDLINESUP',
};

=item editor()->moveSelectedLinesDown()

Move the selected lines down one line, shifting the line below before the selection

See Scintilla documentation for  L<SCI_MOVESELECTEDLINESDOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_MOVESELECTEDLINESDOWN>

=cut

$autogen{SCI_MOVESELECTEDLINESDOWN} = {
    subProto => 'moveSelectedLinesDown()',
    sciProto => 'SCI_MOVESELECTEDLINESDOWN',
};

=item editor()->setMouseSelectionRectangularSwitch(mouseSelectionRectangularSwitch)

Set whether switching to rectangular mode while selecting with the mouse is allowed.

See Scintilla documentation for  L<SCI_SETMOUSESELECTIONRECTANGULARSWITCH|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMOUSESELECTIONRECTANGULARSWITCH>

=cut

$autogen{SCI_SETMOUSESELECTIONRECTANGULARSWITCH} = {
    subProto => 'setMouseSelectionRectangularSwitch(mouseSelectionRectangularSwitch)',
    sciProto => 'SCI_SETMOUSESELECTIONRECTANGULARSWITCH',
};

=item editor()->getMouseSelectionRectangularSwitch() → bool

Whether switching to rectangular mode while selecting with the mouse is allowed.

See Scintilla documentation for  L<SCI_GETMOUSESELECTIONRECTANGULARSWITCH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMOUSESELECTIONRECTANGULARSWITCH>

=cut

$autogen{SCI_GETMOUSESELECTIONRECTANGULARSWITCH} = {
    subProto => 'getMouseSelectionRectangularSwitch() → bool',
    sciProto => 'SCI_GETMOUSESELECTIONRECTANGULARSWITCH',
};

=back

=head2 By character or UTF-16 code unit

=begin scintilla

SCI_POSITIONRELATIVE(position pos, position relative) → position
SCI_POSITIONRELATIVECODEUNITS(position pos, position relative) → position
SCI_COUNTCHARACTERS(position start, position end) → position
SCI_COUNTCODEUNITS(position start, position end) → position
SCI_GETLINECHARACTERINDEX → int
SCI_ALLOCATELINECHARACTERINDEX(int lineCharacterIndex)
SCI_RELEASELINECHARACTERINDEX(int lineCharacterIndex)
SCI_LINEFROMINDEXPOSITION(position pos, int lineCharacterIndex) → line
SCI_INDEXPOSITIONFROMLINE(line line, int lineCharacterIndex) → position

=end scintilla

=over

=item editor()->positionRelative(pos, relative) → int

Given a valid document position, return a position that differs in a number of characters. Returned value is always between 0 and last position in document.

See Scintilla documentation for  L<SCI_POSITIONRELATIVE|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONRELATIVE>

=cut

$autogen{SCI_POSITIONRELATIVE} = {
    subProto => 'positionRelative(pos, relative) → int',
    sciProto => 'SCI_POSITIONRELATIVE',
};

=item editor()->SCI_POSITIONRELATIVECODEUNITS

TODO

See Scintilla documentation for  L<SCI_POSITIONRELATIVECODEUNITS|https://www.scintilla.org/ScintillaDoc.html#SCI_POSITIONRELATIVECODEUNITS>

=cut

$autogen{SCI_POSITIONRELATIVECODEUNITS} = {
    subProto => 'SCI_POSITIONRELATIVECODEUNITS',
    sciProto => 'SCI_POSITIONRELATIVECODEUNITS',
};

=item editor()->countCharacters(startPos, endPos) → int

Count characters between two positions.

See Scintilla documentation for  L<SCI_COUNTCHARACTERS|https://www.scintilla.org/ScintillaDoc.html#SCI_COUNTCHARACTERS>

=cut

$autogen{SCI_COUNTCHARACTERS} = {
    subProto => 'countCharacters(startPos, endPos) → int',
    sciProto => 'SCI_COUNTCHARACTERS',
};

=item editor()->SCI_COUNTCODEUNITS

TODO

See Scintilla documentation for  L<SCI_COUNTCODEUNITS|https://www.scintilla.org/ScintillaDoc.html#SCI_COUNTCODEUNITS>

=cut

$autogen{SCI_COUNTCODEUNITS} = {
    subProto => 'SCI_COUNTCODEUNITS',
    sciProto => 'SCI_COUNTCODEUNITS',
};

=item editor()->SCI_GETLINECHARACTERINDEX

TODO

See Scintilla documentation for  L<SCI_GETLINECHARACTERINDEX|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINECHARACTERINDEX>

=cut

$autogen{SCI_GETLINECHARACTERINDEX} = {
    subProto => 'SCI_GETLINECHARACTERINDEX',
    sciProto => 'SCI_GETLINECHARACTERINDEX',
};

=item editor()->SCI_ALLOCATELINECHARACTERINDEX

TODO

See Scintilla documentation for  L<SCI_ALLOCATELINECHARACTERINDEX|https://www.scintilla.org/ScintillaDoc.html#SCI_ALLOCATELINECHARACTERINDEX>

=cut

$autogen{SCI_ALLOCATELINECHARACTERINDEX} = {
    subProto => 'SCI_ALLOCATELINECHARACTERINDEX',
    sciProto => 'SCI_ALLOCATELINECHARACTERINDEX',
};

=item editor()->SCI_RELEASELINECHARACTERINDEX

TODO

See Scintilla documentation for  L<SCI_RELEASELINECHARACTERINDEX|https://www.scintilla.org/ScintillaDoc.html#SCI_RELEASELINECHARACTERINDEX>

=cut

$autogen{SCI_RELEASELINECHARACTERINDEX} = {
    subProto => 'SCI_RELEASELINECHARACTERINDEX',
    sciProto => 'SCI_RELEASELINECHARACTERINDEX',
};

=item editor()->SCI_LINEFROMINDEXPOSITION

TODO

See Scintilla documentation for  L<SCI_LINEFROMINDEXPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEFROMINDEXPOSITION>

=cut

$autogen{SCI_LINEFROMINDEXPOSITION} = {
    subProto => 'SCI_LINEFROMINDEXPOSITION',
    sciProto => 'SCI_LINEFROMINDEXPOSITION',
};

=item editor()->SCI_INDEXPOSITIONFROMLINE

TODO

See Scintilla documentation for  L<SCI_INDEXPOSITIONFROMLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDEXPOSITIONFROMLINE>

=cut

$autogen{SCI_INDEXPOSITIONFROMLINE} = {
    subProto => 'SCI_INDEXPOSITIONFROMLINE',
    sciProto => 'SCI_INDEXPOSITIONFROMLINE',
};

=back

=head2 Multiple Selection and Virtual Space

=begin scintilla

SCI_SETMULTIPLESELECTION(bool multipleSelection)
SCI_GETMULTIPLESELECTION → bool
SCI_SETADDITIONALSELECTIONTYPING(bool additionalSelectionTyping)
SCI_GETADDITIONALSELECTIONTYPING → bool
SCI_SETMULTIPASTE(int multiPaste)
SCI_GETMULTIPASTE → int
SCI_SETVIRTUALSPACEOPTIONS(int virtualSpaceOptions)
SCI_GETVIRTUALSPACEOPTIONS → int
SCI_SETRECTANGULARSELECTIONMODIFIER(int modifier)
SCI_GETRECTANGULARSELECTIONMODIFIER → int

SCI_GETSELECTIONS → int
SCI_GETSELECTIONEMPTY → bool
SCI_CLEARSELECTIONS
SCI_SETSELECTION(position caret, position anchor)
SCI_ADDSELECTION(position caret, position anchor)
SCI_DROPSELECTIONN(int selection)
SCI_SETMAINSELECTION(int selection)
SCI_GETMAINSELECTION → int

SCI_SETSELECTIONNCARET(int selection, position caret)
SCI_GETSELECTIONNCARET(int selection) → position
SCI_SETSELECTIONNCARETVIRTUALSPACE(int selection, position space)
SCI_GETSELECTIONNCARETVIRTUALSPACE(int selection) → position
SCI_SETSELECTIONNANCHOR(int selection, position anchor)
SCI_GETSELECTIONNANCHOR(int selection) → position
SCI_SETSELECTIONNANCHORVIRTUALSPACE(int selection, position space)
SCI_GETSELECTIONNANCHORVIRTUALSPACE(int selection) → position
SCI_SETSELECTIONNSTART(int selection, position anchor)
SCI_GETSELECTIONNSTART(int selection) → position
SCI_SETSELECTIONNEND(int selection, position caret)
SCI_GETSELECTIONNEND(int selection) → position

SCI_SETRECTANGULARSELECTIONCARET(position caret)
SCI_GETRECTANGULARSELECTIONCARET → position
SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE(position space)
SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE → position
SCI_SETRECTANGULARSELECTIONANCHOR(position anchor)
SCI_GETRECTANGULARSELECTIONANCHOR → position
SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE(position space)
SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE → position

SCI_SETADDITIONALSELALPHA(alpha alpha)
SCI_GETADDITIONALSELALPHA → int
SCI_SETADDITIONALSELFORE(colour fore)
SCI_SETADDITIONALSELBACK(colour back)
SCI_SETADDITIONALCARETFORE(colour fore)
SCI_GETADDITIONALCARETFORE → colour
SCI_SETADDITIONALCARETSBLINK(bool additionalCaretsBlink)
SCI_GETADDITIONALCARETSBLINK → bool
SCI_SETADDITIONALCARETSVISIBLE(bool additionalCaretsVisible)
SCI_GETADDITIONALCARETSVISIBLE → bool

SCI_SWAPMAINANCHORCARET
SCI_ROTATESELECTION
SCI_MULTIPLESELECTADDNEXT
SCI_MULTIPLESELECTADDEACH

=end scintilla

=over

=item editor()->setMultipleSelection(multipleSelection)

Set whether multiple selections can be made

See Scintilla documentation for  L<SCI_SETMULTIPLESELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMULTIPLESELECTION>

=cut

$autogen{SCI_SETMULTIPLESELECTION} = {
    subProto => 'setMultipleSelection(multipleSelection)',
    sciProto => 'SCI_SETMULTIPLESELECTION',
};

=item editor()->getMultipleSelection() → bool

Whether multiple selections can be made

See Scintilla documentation for  L<SCI_GETMULTIPLESELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMULTIPLESELECTION>

=cut

$autogen{SCI_GETMULTIPLESELECTION} = {
    subProto => 'getMultipleSelection() → bool',
    sciProto => 'SCI_GETMULTIPLESELECTION',
};

=item editor()->setAdditionalSelectionTyping(additionalSelectionTyping)

Set whether typing can be performed into multiple selections

See Scintilla documentation for  L<SCI_SETADDITIONALSELECTIONTYPING|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALSELECTIONTYPING>

=cut

$autogen{SCI_SETADDITIONALSELECTIONTYPING} = {
    subProto => 'setAdditionalSelectionTyping(additionalSelectionTyping)',
    sciProto => 'SCI_SETADDITIONALSELECTIONTYPING',
};

=item editor()->getAdditionalSelectionTyping() → bool

Whether typing can be performed into multiple selections

See Scintilla documentation for  L<SCI_GETADDITIONALSELECTIONTYPING|https://www.scintilla.org/ScintillaDoc.html#SCI_GETADDITIONALSELECTIONTYPING>

=cut

$autogen{SCI_GETADDITIONALSELECTIONTYPING} = {
    subProto => 'getAdditionalSelectionTyping() → bool',
    sciProto => 'SCI_GETADDITIONALSELECTIONTYPING',
};

=item editor()->setMultiPaste(multiPaste)

Change the effect of pasting when there are multiple selections.

See Scintilla documentation for  L<SCI_SETMULTIPASTE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMULTIPASTE>

=cut

$autogen{SCI_SETMULTIPASTE} = {
    subProto => 'setMultiPaste(multiPaste)',
    sciProto => 'SCI_SETMULTIPASTE',
};

=item editor()->getMultiPaste() → int

Retrieve the effect of pasting when there are multiple selections..

See Scintilla documentation for  L<SCI_GETMULTIPASTE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMULTIPASTE>

=cut

$autogen{SCI_GETMULTIPASTE} = {
    subProto => 'getMultiPaste() → int',
    sciProto => 'SCI_GETMULTIPASTE',
};

=item editor()->setVirtualSpaceOptions(virtualSpaceOptions)

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_SETVIRTUALSPACEOPTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETVIRTUALSPACEOPTIONS>

=cut

$autogen{SCI_SETVIRTUALSPACEOPTIONS} = {
    subProto => 'setVirtualSpaceOptions(virtualSpaceOptions)',
    sciProto => 'SCI_SETVIRTUALSPACEOPTIONS',
};

=item editor()->getVirtualSpaceOptions() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETVIRTUALSPACEOPTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETVIRTUALSPACEOPTIONS>

=cut

$autogen{SCI_GETVIRTUALSPACEOPTIONS} = {
    subProto => 'getVirtualSpaceOptions() → int',
    sciProto => 'SCI_GETVIRTUALSPACEOPTIONS',
};

=item editor()->setRectangularSelectionModifier(modifier)

On GTK+, allow selecting the modifier key to use for mouse-based rectangular selection. Often the window manager requires Alt+Mouse Drag for moving windows. Valid values are SCMOD_CTRL(default), SCMOD_ALT, or SCMOD_SUPER.

See Scintilla documentation for  L<SCI_SETRECTANGULARSELECTIONMODIFIER|https://www.scintilla.org/ScintillaDoc.html#SCI_SETRECTANGULARSELECTIONMODIFIER>

=cut

$autogen{SCI_SETRECTANGULARSELECTIONMODIFIER} = {
    subProto => 'setRectangularSelectionModifier(modifier)',
    sciProto => 'SCI_SETRECTANGULARSELECTIONMODIFIER',
};

=item editor()->getRectangularSelectionModifier() → int

Get the modifier key used for rectangular selection.

See Scintilla documentation for  L<SCI_GETRECTANGULARSELECTIONMODIFIER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRECTANGULARSELECTIONMODIFIER>

=cut

$autogen{SCI_GETRECTANGULARSELECTIONMODIFIER} = {
    subProto => 'getRectangularSelectionModifier() → int',
    sciProto => 'SCI_GETRECTANGULARSELECTIONMODIFIER',
};

=item editor()->getSelections() → int

How many selections are there?

See Scintilla documentation for  L<SCI_GETSELECTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONS>

=cut

$autogen{SCI_GETSELECTIONS} = {
    subProto => 'getSelections() → int',
    sciProto => 'SCI_GETSELECTIONS',
};

=item editor()->getSelectionEmpty() → bool

Is every selected range empty?

See Scintilla documentation for  L<SCI_GETSELECTIONEMPTY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONEMPTY>

=cut

$autogen{SCI_GETSELECTIONEMPTY} = {
    subProto => 'getSelectionEmpty() → bool',
    sciProto => 'SCI_GETSELECTIONEMPTY',
};

=item editor()->clearSelections()

Clear selections to a single empty stream selection

See Scintilla documentation for  L<SCI_CLEARSELECTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARSELECTIONS>

=cut

$autogen{SCI_CLEARSELECTIONS} = {
    subProto => 'clearSelections()',
    sciProto => 'SCI_CLEARSELECTIONS',
};

=item editor()->setSelection(caret, anchor) → int

Set a simple selection

See Scintilla documentation for  L<SCI_SETSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTION>

=cut

$autogen{SCI_SETSELECTION} = {
    subProto => 'setSelection(caret, anchor) → int',
    sciProto => 'SCI_SETSELECTION',
};

=item editor()->addSelection(caret, anchor) → int

Add a selection

See Scintilla documentation for  L<SCI_ADDSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDSELECTION>

=cut

$autogen{SCI_ADDSELECTION} = {
    subProto => 'addSelection(caret, anchor) → int',
    sciProto => 'SCI_ADDSELECTION',
};

=item editor()->dropSelectionN(selection)

Drop one selection

See Scintilla documentation for  L<SCI_DROPSELECTIONN|https://www.scintilla.org/ScintillaDoc.html#SCI_DROPSELECTIONN>

=cut

$autogen{SCI_DROPSELECTIONN} = {
    subProto => 'dropSelectionN(selection)',
    sciProto => 'SCI_DROPSELECTIONN',
};

=item editor()->setMainSelection(selection)

Set the main selection

See Scintilla documentation for  L<SCI_SETMAINSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMAINSELECTION>

=cut

$autogen{SCI_SETMAINSELECTION} = {
    subProto => 'setMainSelection(selection)',
    sciProto => 'SCI_SETMAINSELECTION',
};

=item editor()->getMainSelection() → int

Which selection is the main selection

See Scintilla documentation for  L<SCI_GETMAINSELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMAINSELECTION>

=cut

$autogen{SCI_GETMAINSELECTION} = {
    subProto => 'getMainSelection() → int',
    sciProto => 'SCI_GETMAINSELECTION',
};

=item editor()->setSelectionNCaret(selection, pos)

Which selection is the main selection

See Scintilla documentation for  L<SCI_SETSELECTIONNCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNCARET>

=cut

$autogen{SCI_SETSELECTIONNCARET} = {
    subProto => 'setSelectionNCaret(selection, pos)',
    sciProto => 'SCI_SETSELECTIONNCARET',
};

=item editor()->getSelectionNCaret(selection) → int

Which selection is the main selection

See Scintilla documentation for  L<SCI_GETSELECTIONNCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNCARET>

=cut

$autogen{SCI_GETSELECTIONNCARET} = {
    subProto => 'getSelectionNCaret(selection) → int',
    sciProto => 'SCI_GETSELECTIONNCARET',
};

=item editor()->setSelectionNCaretVirtualSpace(selection, space)

Which selection is the main selection

See Scintilla documentation for  L<SCI_SETSELECTIONNCARETVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNCARETVIRTUALSPACE>

=cut

$autogen{SCI_SETSELECTIONNCARETVIRTUALSPACE} = {
    subProto => 'setSelectionNCaretVirtualSpace(selection, space)',
    sciProto => 'SCI_SETSELECTIONNCARETVIRTUALSPACE',
};

=item editor()->getSelectionNCaretVirtualSpace(selection) → int

Which selection is the main selection

See Scintilla documentation for  L<SCI_GETSELECTIONNCARETVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNCARETVIRTUALSPACE>

=cut

$autogen{SCI_GETSELECTIONNCARETVIRTUALSPACE} = {
    subProto => 'getSelectionNCaretVirtualSpace(selection) → int',
    sciProto => 'SCI_GETSELECTIONNCARETVIRTUALSPACE',
};

=item editor()->setSelectionNAnchor(selection, posAnchor)

Which selection is the main selection

See Scintilla documentation for  L<SCI_SETSELECTIONNANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNANCHOR>

=cut

$autogen{SCI_SETSELECTIONNANCHOR} = {
    subProto => 'setSelectionNAnchor(selection, posAnchor)',
    sciProto => 'SCI_SETSELECTIONNANCHOR',
};

=item editor()->getSelectionNAnchor(selection) → int

Which selection is the main selection

See Scintilla documentation for  L<SCI_GETSELECTIONNANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNANCHOR>

=cut

$autogen{SCI_GETSELECTIONNANCHOR} = {
    subProto => 'getSelectionNAnchor(selection) → int',
    sciProto => 'SCI_GETSELECTIONNANCHOR',
};

=item editor()->setSelectionNAnchorVirtualSpace(selection, space)

Which selection is the main selection

See Scintilla documentation for  L<SCI_SETSELECTIONNANCHORVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNANCHORVIRTUALSPACE>

=cut

$autogen{SCI_SETSELECTIONNANCHORVIRTUALSPACE} = {
    subProto => 'setSelectionNAnchorVirtualSpace(selection, space)',
    sciProto => 'SCI_SETSELECTIONNANCHORVIRTUALSPACE',
};

=item editor()->getSelectionNAnchorVirtualSpace(selection) → int

Which selection is the main selection

See Scintilla documentation for  L<SCI_GETSELECTIONNANCHORVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNANCHORVIRTUALSPACE>

=cut

$autogen{SCI_GETSELECTIONNANCHORVIRTUALSPACE} = {
    subProto => 'getSelectionNAnchorVirtualSpace(selection) → int',
    sciProto => 'SCI_GETSELECTIONNANCHORVIRTUALSPACE',
};

=item editor()->setSelectionNStart(selection, pos)

Sets the position that starts the selection - this becomes the anchor.

See Scintilla documentation for  L<SCI_SETSELECTIONNSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNSTART>

=cut

$autogen{SCI_SETSELECTIONNSTART} = {
    subProto => 'setSelectionNStart(selection, pos)',
    sciProto => 'SCI_SETSELECTIONNSTART',
};

=item editor()->getSelectionNStart(selection) → int

Returns the position at the start of the selection.

See Scintilla documentation for  L<SCI_GETSELECTIONNSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNSTART>

=cut

$autogen{SCI_GETSELECTIONNSTART} = {
    subProto => 'getSelectionNStart(selection) → int',
    sciProto => 'SCI_GETSELECTIONNSTART',
};

=item editor()->setSelectionNEnd(selection, pos)

Sets the position that ends the selection - this becomes the currentPosition.

See Scintilla documentation for  L<SCI_SETSELECTIONNEND|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELECTIONNEND>

=cut

$autogen{SCI_SETSELECTIONNEND} = {
    subProto => 'setSelectionNEnd(selection, pos)',
    sciProto => 'SCI_SETSELECTIONNEND',
};

=item editor()->getSelectionNEnd(selection) → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETSELECTIONNEND|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONNEND>

=cut

$autogen{SCI_GETSELECTIONNEND} = {
    subProto => 'getSelectionNEnd(selection) → int',
    sciProto => 'SCI_GETSELECTIONNEND',
};

=item editor()->setRectangularSelectionCaret(pos)

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_SETRECTANGULARSELECTIONCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_SETRECTANGULARSELECTIONCARET>

=cut

$autogen{SCI_SETRECTANGULARSELECTIONCARET} = {
    subProto => 'setRectangularSelectionCaret(pos)',
    sciProto => 'SCI_SETRECTANGULARSELECTIONCARET',
};

=item editor()->getRectangularSelectionCaret() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETRECTANGULARSELECTIONCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRECTANGULARSELECTIONCARET>

=cut

$autogen{SCI_GETRECTANGULARSELECTIONCARET} = {
    subProto => 'getRectangularSelectionCaret() → int',
    sciProto => 'SCI_GETRECTANGULARSELECTIONCARET',
};

=item editor()->setRectangularSelectionCaretVirtualSpace(space)

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE>

=cut

$autogen{SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE} = {
    subProto => 'setRectangularSelectionCaretVirtualSpace(space)',
    sciProto => 'SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE',
};

=item editor()->getRectangularSelectionCaretVirtualSpace() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE>

=cut

$autogen{SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE} = {
    subProto => 'getRectangularSelectionCaretVirtualSpace() → int',
    sciProto => 'SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE',
};

=item editor()->setRectangularSelectionAnchor(posAnchor)

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_SETRECTANGULARSELECTIONANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETRECTANGULARSELECTIONANCHOR>

=cut

$autogen{SCI_SETRECTANGULARSELECTIONANCHOR} = {
    subProto => 'setRectangularSelectionAnchor(posAnchor)',
    sciProto => 'SCI_SETRECTANGULARSELECTIONANCHOR',
};

=item editor()->getRectangularSelectionAnchor() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETRECTANGULARSELECTIONANCHOR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRECTANGULARSELECTIONANCHOR>

=cut

$autogen{SCI_GETRECTANGULARSELECTIONANCHOR} = {
    subProto => 'getRectangularSelectionAnchor() → int',
    sciProto => 'SCI_GETRECTANGULARSELECTIONANCHOR',
};

=item editor()->setRectangularSelectionAnchorVirtualSpace(space)

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE>

=cut

$autogen{SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE} = {
    subProto => 'setRectangularSelectionAnchorVirtualSpace(space)',
    sciProto => 'SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE',
};

=item editor()->getRectangularSelectionAnchorVirtualSpace() → int

Returns the position at the end of the selection.

See Scintilla documentation for  L<SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE>

=cut

$autogen{SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE} = {
    subProto => 'getRectangularSelectionAnchorVirtualSpace() → int',
    sciProto => 'SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE',
};

=item editor()->setAdditionalSelAlpha(alpha)

Set the alpha of the selection.

See Scintilla documentation for  L<SCI_SETADDITIONALSELALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALSELALPHA>

=cut

$autogen{SCI_SETADDITIONALSELALPHA} = {
    subProto => 'setAdditionalSelAlpha(alpha)',
    sciProto => 'SCI_SETADDITIONALSELALPHA',
};

=item editor()->getAdditionalSelAlpha() → int

Get the alpha of the selection.

See Scintilla documentation for  L<SCI_GETADDITIONALSELALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_GETADDITIONALSELALPHA>

=cut

$autogen{SCI_GETADDITIONALSELALPHA} = {
    subProto => 'getAdditionalSelAlpha() → int',
    sciProto => 'SCI_GETADDITIONALSELALPHA',
};

=item editor()->setAdditionalSelFore(fore)

Set the foreground colour of additional selections. Must have previously called SetSelFore with non-zero first argument for this to have an effect.

See Scintilla documentation for  L<SCI_SETADDITIONALSELFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALSELFORE>

=cut

$autogen{SCI_SETADDITIONALSELFORE} = {
    subProto => 'setAdditionalSelFore(fore)',
    sciProto => 'SCI_SETADDITIONALSELFORE',
};

=item editor()->setAdditionalSelBack(back)

Set the background colour of additional selections. Must have previously called SetSelBack with non-zero first argument for this to have an effect.

See Scintilla documentation for  L<SCI_SETADDITIONALSELBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALSELBACK>

=cut

$autogen{SCI_SETADDITIONALSELBACK} = {
    subProto => 'setAdditionalSelBack(back)',
    sciProto => 'SCI_SETADDITIONALSELBACK',
};

=item editor()->setAdditionalCaretFore(fore)

Set the foreground colour of additional carets.

See Scintilla documentation for  L<SCI_SETADDITIONALCARETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALCARETFORE>

=cut

$autogen{SCI_SETADDITIONALCARETFORE} = {
    subProto => 'setAdditionalCaretFore(fore)',
    sciProto => 'SCI_SETADDITIONALCARETFORE',
};

=item editor()->getAdditionalCaretFore() → tuple

Get the foreground colour of additional carets.

See Scintilla documentation for  L<SCI_GETADDITIONALCARETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETADDITIONALCARETFORE>

=cut

$autogen{SCI_GETADDITIONALCARETFORE} = {
    subProto => 'getAdditionalCaretFore() → tuple',
    sciProto => 'SCI_GETADDITIONALCARETFORE',
};

=item editor()->setAdditionalCaretsBlink(additionalCaretsBlink)

Set whether additional carets will blink

See Scintilla documentation for  L<SCI_SETADDITIONALCARETSBLINK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALCARETSBLINK>

=cut

$autogen{SCI_SETADDITIONALCARETSBLINK} = {
    subProto => 'setAdditionalCaretsBlink(additionalCaretsBlink)',
    sciProto => 'SCI_SETADDITIONALCARETSBLINK',
};

=item editor()->getAdditionalCaretsBlink() → bool

Whether additional carets will blink

See Scintilla documentation for  L<SCI_GETADDITIONALCARETSBLINK|https://www.scintilla.org/ScintillaDoc.html#SCI_GETADDITIONALCARETSBLINK>

=cut

$autogen{SCI_GETADDITIONALCARETSBLINK} = {
    subProto => 'getAdditionalCaretsBlink() → bool',
    sciProto => 'SCI_GETADDITIONALCARETSBLINK',
};

=item editor()->setAdditionalCaretsVisible(additionalCaretsBlink)

Set whether additional carets are visible

See Scintilla documentation for  L<SCI_SETADDITIONALCARETSVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETADDITIONALCARETSVISIBLE>

=cut

$autogen{SCI_SETADDITIONALCARETSVISIBLE} = {
    subProto => 'setAdditionalCaretsVisible(additionalCaretsBlink)',
    sciProto => 'SCI_SETADDITIONALCARETSVISIBLE',
};

=item editor()->getAdditionalCaretsVisible() → bool

Whether additional carets are visible

See Scintilla documentation for  L<SCI_GETADDITIONALCARETSVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETADDITIONALCARETSVISIBLE>

=cut

$autogen{SCI_GETADDITIONALCARETSVISIBLE} = {
    subProto => 'getAdditionalCaretsVisible() → bool',
    sciProto => 'SCI_GETADDITIONALCARETSVISIBLE',
};

=item editor()->swapMainAnchorCaret()

Swap that caret and anchor of the main selection.

See Scintilla documentation for  L<SCI_SWAPMAINANCHORCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_SWAPMAINANCHORCARET>

=cut

$autogen{SCI_SWAPMAINANCHORCARET} = {
    subProto => 'swapMainAnchorCaret()',
    sciProto => 'SCI_SWAPMAINANCHORCARET',
};

=item editor()->rotateSelection()

Set the main selection to the next selection.

See Scintilla documentation for  L<SCI_ROTATESELECTION|https://www.scintilla.org/ScintillaDoc.html#SCI_ROTATESELECTION>

=cut

$autogen{SCI_ROTATESELECTION} = {
    subProto => 'rotateSelection()',
    sciProto => 'SCI_ROTATESELECTION',
};

=item editor()->SCI_MULTIPLESELECTADDNEXT

TODO

See Scintilla documentation for  L<SCI_MULTIPLESELECTADDNEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_MULTIPLESELECTADDNEXT>

=cut

$autogen{SCI_MULTIPLESELECTADDNEXT} = {
    subProto => 'SCI_MULTIPLESELECTADDNEXT',
    sciProto => 'SCI_MULTIPLESELECTADDNEXT',
};

=item editor()->SCI_MULTIPLESELECTADDEACH

TODO

See Scintilla documentation for  L<SCI_MULTIPLESELECTADDEACH|https://www.scintilla.org/ScintillaDoc.html#SCI_MULTIPLESELECTADDEACH>

=cut

$autogen{SCI_MULTIPLESELECTADDEACH} = {
    subProto => 'SCI_MULTIPLESELECTADDEACH',
    sciProto => 'SCI_MULTIPLESELECTADDEACH',
};

=back

=head2 Scrolling and automatic scrolling

=begin scintilla

SCI_SETFIRSTVISIBLELINE(line displayLine)
SCI_GETFIRSTVISIBLELINE → line
SCI_SETXOFFSET(int xOffset)
SCI_GETXOFFSET → int
SCI_LINESCROLL(position columns, line lines)
SCI_SCROLLCARET
SCI_SCROLLRANGE(position secondary, position primary)
SCI_SETXCARETPOLICY(int caretPolicy, int caretSlop)
SCI_SETYCARETPOLICY(int caretPolicy, int caretSlop)
SCI_SETVISIBLEPOLICY(int visiblePolicy, int visibleSlop)
SCI_SETHSCROLLBAR(bool visible)
SCI_GETHSCROLLBAR → bool
SCI_SETVSCROLLBAR(bool visible)
SCI_GETVSCROLLBAR → bool
SCI_SETSCROLLWIDTH(int pixelWidth)
SCI_GETSCROLLWIDTH → int
SCI_SETSCROLLWIDTHTRACKING(bool tracking)
SCI_GETSCROLLWIDTHTRACKING → bool
SCI_SETENDATLASTLINE(bool endAtLastLine)
SCI_GETENDATLASTLINE → bool

=end scintilla

=over

=item editor()->setFirstVisibleLine(lineDisplay)

Scroll so that a display line is at the top of the display.

See Scintilla documentation for  L<SCI_SETFIRSTVISIBLELINE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFIRSTVISIBLELINE>

=cut

$autogen{SCI_SETFIRSTVISIBLELINE} = {
    subProto => 'setFirstVisibleLine(lineDisplay)',
    sciProto => 'SCI_SETFIRSTVISIBLELINE',
};

=item editor()->getFirstVisibleLine() → int

Retrieve the display line at the top of the display.

See Scintilla documentation for  L<SCI_GETFIRSTVISIBLELINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFIRSTVISIBLELINE>

=cut

$autogen{SCI_GETFIRSTVISIBLELINE} = {
    subProto => 'getFirstVisibleLine() → int',
    sciProto => 'SCI_GETFIRSTVISIBLELINE',
};

=item editor()->setXOffset(newOffset)

Get and Set the xOffset (ie, horizontal scroll position).

See Scintilla documentation for  L<SCI_SETXOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_SETXOFFSET>

=cut

$autogen{SCI_SETXOFFSET} = {
    subProto => 'setXOffset(newOffset)',
    sciProto => 'SCI_SETXOFFSET',
};

=item editor()->getXOffset() → int

Get and Set the xOffset (ie, horizontal scroll position).

See Scintilla documentation for  L<SCI_GETXOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_GETXOFFSET>

=cut

$autogen{SCI_GETXOFFSET} = {
    subProto => 'getXOffset() → int',
    sciProto => 'SCI_GETXOFFSET',
};

=item editor()->lineScroll(columns, lines)

Scroll horizontally and vertically.

See Scintilla documentation for  L<SCI_LINESCROLL|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESCROLL>

=cut

$autogen{SCI_LINESCROLL} = {
    subProto => 'lineScroll(columns, lines)',
    sciProto => 'SCI_LINESCROLL',
};

=item editor()->scrollCaret()

Ensure the caret is visible.

See Scintilla documentation for  L<SCI_SCROLLCARET|https://www.scintilla.org/ScintillaDoc.html#SCI_SCROLLCARET>

=cut

$autogen{SCI_SCROLLCARET} = {
    subProto => 'scrollCaret()',
    sciProto => 'SCI_SCROLLCARET',
};

=item editor()->scrollRange(secondary, primary)

Scroll the argument positions and the range between them into view giving priority to the primary position then the secondary position. This may be used to make a search match visible.

See Scintilla documentation for  L<SCI_SCROLLRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_SCROLLRANGE>

=cut

$autogen{SCI_SCROLLRANGE} = {
    subProto => 'scrollRange(secondary, primary)',
    sciProto => 'SCI_SCROLLRANGE',
};

=item editor()->setXCaretPolicy(caretPolicy, caretSlop)

Set the way the caret is kept visible when going sideways. The exclusion zone is given in pixels.

See Scintilla documentation for  L<SCI_SETXCARETPOLICY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETXCARETPOLICY>

=cut

$autogen{SCI_SETXCARETPOLICY} = {
    subProto => 'setXCaretPolicy(caretPolicy, caretSlop)',
    sciProto => 'SCI_SETXCARETPOLICY',
};

=item editor()->setYCaretPolicy(caretPolicy, caretSlop)

Set the way the line the caret is on is kept visible. The exclusion zone is given in lines.

See Scintilla documentation for  L<SCI_SETYCARETPOLICY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETYCARETPOLICY>

=cut

$autogen{SCI_SETYCARETPOLICY} = {
    subProto => 'setYCaretPolicy(caretPolicy, caretSlop)',
    sciProto => 'SCI_SETYCARETPOLICY',
};

=item editor()->setVisiblePolicy(visiblePolicy, visibleSlop)

Set the way the display area is determined when a particular line is to be moved to by Find, FindNext, GotoLine, etc.

See Scintilla documentation for  L<SCI_SETVISIBLEPOLICY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETVISIBLEPOLICY>

=cut

$autogen{SCI_SETVISIBLEPOLICY} = {
    subProto => 'setVisiblePolicy(visiblePolicy, visibleSlop)',
    sciProto => 'SCI_SETVISIBLEPOLICY',
};

=item editor()->setHScrollBar(show)

Show or hide the horizontal scroll bar.

See Scintilla documentation for  L<SCI_SETHSCROLLBAR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHSCROLLBAR>

=cut

$autogen{SCI_SETHSCROLLBAR} = {
    subProto => 'setHScrollBar(show)',
    sciProto => 'SCI_SETHSCROLLBAR',
};

=item editor()->getHScrollBar() → bool

Is the horizontal scroll bar visible?

See Scintilla documentation for  L<SCI_GETHSCROLLBAR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHSCROLLBAR>

=cut

$autogen{SCI_GETHSCROLLBAR} = {
    subProto => 'getHScrollBar() → bool',
    sciProto => 'SCI_GETHSCROLLBAR',
};

=item editor()->setVScrollBar(show)

Show or hide the vertical scroll bar.

See Scintilla documentation for  L<SCI_SETVSCROLLBAR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETVSCROLLBAR>

=cut

$autogen{SCI_SETVSCROLLBAR} = {
    subProto => 'setVScrollBar(show)',
    sciProto => 'SCI_SETVSCROLLBAR',
};

=item editor()->getVScrollBar() → bool

Is the vertical scroll bar visible?

See Scintilla documentation for  L<SCI_GETVSCROLLBAR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETVSCROLLBAR>

=cut

$autogen{SCI_GETVSCROLLBAR} = {
    subProto => 'getVScrollBar() → bool',
    sciProto => 'SCI_GETVSCROLLBAR',
};

=item editor()->setScrollWidth(pixelWidth)

Sets the document width assumed for scrolling.

See Scintilla documentation for  L<SCI_SETSCROLLWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSCROLLWIDTH>

=cut

$autogen{SCI_SETSCROLLWIDTH} = {
    subProto => 'setScrollWidth(pixelWidth)',
    sciProto => 'SCI_SETSCROLLWIDTH',
};

=item editor()->getScrollWidth() → int

Retrieve the document width assumed for scrolling.

See Scintilla documentation for  L<SCI_GETSCROLLWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSCROLLWIDTH>

=cut

$autogen{SCI_GETSCROLLWIDTH} = {
    subProto => 'getScrollWidth() → int',
    sciProto => 'SCI_GETSCROLLWIDTH',
};

=item editor()->setScrollWidthTracking(tracking)

Sets whether the maximum width line displayed is used to set scroll width.

See Scintilla documentation for  L<SCI_SETSCROLLWIDTHTRACKING|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSCROLLWIDTHTRACKING>

=cut

$autogen{SCI_SETSCROLLWIDTHTRACKING} = {
    subProto => 'setScrollWidthTracking(tracking)',
    sciProto => 'SCI_SETSCROLLWIDTHTRACKING',
};

=item editor()->getScrollWidthTracking() → bool

Retrieve whether the scroll width tracks wide lines.

See Scintilla documentation for  L<SCI_GETSCROLLWIDTHTRACKING|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSCROLLWIDTHTRACKING>

=cut

$autogen{SCI_GETSCROLLWIDTHTRACKING} = {
    subProto => 'getScrollWidthTracking() → bool',
    sciProto => 'SCI_GETSCROLLWIDTHTRACKING',
};

=item editor()->setEndAtLastLine(endAtLastLine)

Sets the scroll range so that maximum scroll position has the last line at the bottom of the view (default). Setting this to false allows scrolling one page below the last line.

See Scintilla documentation for  L<SCI_SETENDATLASTLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETENDATLASTLINE>

=cut

$autogen{SCI_SETENDATLASTLINE} = {
    subProto => 'setEndAtLastLine(endAtLastLine)',
    sciProto => 'SCI_SETENDATLASTLINE',
};

=item editor()->getEndAtLastLine() → bool

Retrieve whether the maximum scroll position has the last line at the bottom of the view.

See Scintilla documentation for  L<SCI_GETENDATLASTLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETENDATLASTLINE>

=cut

$autogen{SCI_GETENDATLASTLINE} = {
    subProto => 'getEndAtLastLine() → bool',
    sciProto => 'SCI_GETENDATLASTLINE',
};

=back

=head2 White space

=begin scintilla

SCI_SETVIEWWS(int viewWS)
SCI_GETVIEWWS → int
SCI_SETWHITESPACEFORE(bool useSetting, colour fore)
SCI_SETWHITESPACEBACK(bool useSetting, colour back)
SCI_SETWHITESPACESIZE(int size)
SCI_GETWHITESPACESIZE → int
SCI_SETTABDRAWMODE(int tabDrawMode)
SCI_GETTABDRAWMODE → int
SCI_SETEXTRAASCENT(int extraAscent)
SCI_GETEXTRAASCENT → int
SCI_SETEXTRADESCENT(int extraDescent)
SCI_GETEXTRADESCENT → int

=end scintilla

=over

=item editor()->setViewWS(viewWS)

Make white space characters invisible, always visible or visible outside indentation.

See Scintilla documentation for  L<SCI_SETVIEWWS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETVIEWWS>

=cut

$autogen{SCI_SETVIEWWS} = {
    subProto => 'setViewWS(viewWS)',
    sciProto => 'SCI_SETVIEWWS',
};

=item editor()->getViewWS() → int

Are white space characters currently visible? Returns one of SCWS_* constants.

See Scintilla documentation for  L<SCI_GETVIEWWS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETVIEWWS>

=cut

$autogen{SCI_GETVIEWWS} = {
    subProto => 'getViewWS() → int',
    sciProto => 'SCI_GETVIEWWS',
};

=item editor()->setWhitespaceFore(useSetting, fore)

Set the foreground colour of all whitespace and whether to use this setting.

See Scintilla documentation for  L<SCI_SETWHITESPACEFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWHITESPACEFORE>

=cut

$autogen{SCI_SETWHITESPACEFORE} = {
    subProto => 'setWhitespaceFore(useSetting, fore)',
    sciProto => 'SCI_SETWHITESPACEFORE',
};

=item editor()->setWhitespaceBack(useSetting, back)

Set the background colour of all whitespace and whether to use this setting.

See Scintilla documentation for  L<SCI_SETWHITESPACEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWHITESPACEBACK>

=cut

$autogen{SCI_SETWHITESPACEBACK} = {
    subProto => 'setWhitespaceBack(useSetting, back)',
    sciProto => 'SCI_SETWHITESPACEBACK',
};

=item editor()->setWhitespaceSize(size)

Set the size of the dots used to mark space characters.

See Scintilla documentation for  L<SCI_SETWHITESPACESIZE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWHITESPACESIZE>

=cut

$autogen{SCI_SETWHITESPACESIZE} = {
    subProto => 'setWhitespaceSize(size)',
    sciProto => 'SCI_SETWHITESPACESIZE',
};

=item editor()->getWhitespaceSize() → int

Get the size of the dots used to mark space characters.

See Scintilla documentation for  L<SCI_GETWHITESPACESIZE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWHITESPACESIZE>

=cut

$autogen{SCI_GETWHITESPACESIZE} = {
    subProto => 'getWhitespaceSize() → int',
    sciProto => 'SCI_GETWHITESPACESIZE',
};

=item editor()->SCI_SETTABDRAWMODE

TODO

See Scintilla documentation for  L<SCI_SETTABDRAWMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTABDRAWMODE>

=cut

$autogen{SCI_SETTABDRAWMODE} = {
    subProto => 'SCI_SETTABDRAWMODE',
    sciProto => 'SCI_SETTABDRAWMODE',
};

=item editor()->SCI_GETTABDRAWMODE

TODO

See Scintilla documentation for  L<SCI_GETTABDRAWMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTABDRAWMODE>

=cut

$autogen{SCI_GETTABDRAWMODE} = {
    subProto => 'SCI_GETTABDRAWMODE',
    sciProto => 'SCI_GETTABDRAWMODE',
};

=item editor()->setExtraAscent(extraAscent)

Set extra ascent for each line

See Scintilla documentation for  L<SCI_SETEXTRAASCENT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEXTRAASCENT>

=cut

$autogen{SCI_SETEXTRAASCENT} = {
    subProto => 'setExtraAscent(extraAscent)',
    sciProto => 'SCI_SETEXTRAASCENT',
};

=item editor()->getExtraAscent() → int

Get extra ascent for each line

See Scintilla documentation for  L<SCI_GETEXTRAASCENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEXTRAASCENT>

=cut

$autogen{SCI_GETEXTRAASCENT} = {
    subProto => 'getExtraAscent() → int',
    sciProto => 'SCI_GETEXTRAASCENT',
};

=item editor()->setExtraDescent(extraDescent)

Set extra descent for each line

See Scintilla documentation for  L<SCI_SETEXTRADESCENT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEXTRADESCENT>

=cut

$autogen{SCI_SETEXTRADESCENT} = {
    subProto => 'setExtraDescent(extraDescent)',
    sciProto => 'SCI_SETEXTRADESCENT',
};

=item editor()->getExtraDescent() → int

Get extra descent for each line

See Scintilla documentation for  L<SCI_GETEXTRADESCENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEXTRADESCENT>

=cut

$autogen{SCI_GETEXTRADESCENT} = {
    subProto => 'getExtraDescent() → int',
    sciProto => 'SCI_GETEXTRADESCENT',
};

=back

=head2 Cursor

=begin scintilla

SCI_SETCURSOR(int cursorType)
SCI_GETCURSOR → int

=end scintilla

=over

=item editor()->setCursor(cursorType)

Sets the cursor to one of the SC_CURSOR* values.

See Scintilla documentation for  L<SCI_SETCURSOR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCURSOR>

=cut

$autogen{SCI_SETCURSOR} = {
    subProto => 'setCursor(cursorType)',
    sciProto => 'SCI_SETCURSOR',
};

=item editor()->getCursor() → int

Get cursor type.

See Scintilla documentation for  L<SCI_GETCURSOR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCURSOR>

=cut

$autogen{SCI_GETCURSOR} = {
    subProto => 'getCursor() → int',
    sciProto => 'SCI_GETCURSOR',
};

=back

=head2 Mouse capture

=begin scintilla

SCI_SETMOUSEDOWNCAPTURES(bool captures)
SCI_GETMOUSEDOWNCAPTURES → bool
SCI_SETMOUSEWHEELCAPTURES(bool captures)
SCI_GETMOUSEWHEELCAPTURES → bool

=end scintilla

=over

=item editor()->setMouseDownCaptures(captures)

Set whether the mouse is captured when its button is pressed.

See Scintilla documentation for  L<SCI_SETMOUSEDOWNCAPTURES|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMOUSEDOWNCAPTURES>

=cut

$autogen{SCI_SETMOUSEDOWNCAPTURES} = {
    subProto => 'setMouseDownCaptures(captures)',
    sciProto => 'SCI_SETMOUSEDOWNCAPTURES',
};

=item editor()->getMouseDownCaptures() → bool

Get whether mouse gets captured.

See Scintilla documentation for  L<SCI_GETMOUSEDOWNCAPTURES|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMOUSEDOWNCAPTURES>

=cut

$autogen{SCI_GETMOUSEDOWNCAPTURES} = {
    subProto => 'getMouseDownCaptures() → bool',
    sciProto => 'SCI_GETMOUSEDOWNCAPTURES',
};

=item editor()->SCI_SETMOUSEWHEELCAPTURES

TODO

See Scintilla documentation for  L<SCI_SETMOUSEWHEELCAPTURES|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMOUSEWHEELCAPTURES>

=cut

$autogen{SCI_SETMOUSEWHEELCAPTURES} = {
    subProto => 'SCI_SETMOUSEWHEELCAPTURES',
    sciProto => 'SCI_SETMOUSEWHEELCAPTURES',
};

=item editor()->SCI_GETMOUSEWHEELCAPTURES

TODO

See Scintilla documentation for  L<SCI_GETMOUSEWHEELCAPTURES|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMOUSEWHEELCAPTURES>

=cut

$autogen{SCI_GETMOUSEWHEELCAPTURES} = {
    subProto => 'SCI_GETMOUSEWHEELCAPTURES',
    sciProto => 'SCI_GETMOUSEWHEELCAPTURES',
};

=back

=head2 Line endings

=begin scintilla

SCI_SETEOLMODE(int eolMode)
SCI_GETEOLMODE → int
SCI_CONVERTEOLS(int eolMode)
SCI_SETVIEWEOL(bool visible)
SCI_GETVIEWEOL → bool
SCI_GETLINEENDTYPESSUPPORTED → int
SCI_SETLINEENDTYPESALLOWED(int lineEndBitSet)
SCI_GETLINEENDTYPESALLOWED → int
SCI_GETLINEENDTYPESACTIVE → int

=end scintilla

=over

=item editor()->setEOLMode(eolMode)

Set the current end of line mode.

See Scintilla documentation for  L<SCI_SETEOLMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEOLMODE>

=cut

$autogen{SCI_SETEOLMODE} = {
    subProto => 'setEOLMode(eolMode)',
    sciProto => 'SCI_SETEOLMODE',
};

=item editor()->getEOLMode() → int

Retrieve the current end of line mode - one of CRLF, CR, or LF.

See Scintilla documentation for  L<SCI_GETEOLMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEOLMODE>

=cut

$autogen{SCI_GETEOLMODE} = {
    subProto => 'getEOLMode() → int',
    sciProto => 'SCI_GETEOLMODE',
};

=item editor()->convertEOLs(eolMode)

Convert all line endings in the document to one mode.

See Scintilla documentation for  L<SCI_CONVERTEOLS|https://www.scintilla.org/ScintillaDoc.html#SCI_CONVERTEOLS>

=cut

$autogen{SCI_CONVERTEOLS} = {
    subProto => 'convertEOLs(eolMode)',
    sciProto => 'SCI_CONVERTEOLS',
};

=item editor()->setViewEOL(visible)

Make the end of line characters visible or invisible.

See Scintilla documentation for  L<SCI_SETVIEWEOL|https://www.scintilla.org/ScintillaDoc.html#SCI_SETVIEWEOL>

=cut

$autogen{SCI_SETVIEWEOL} = {
    subProto => 'setViewEOL(visible)',
    sciProto => 'SCI_SETVIEWEOL',
};

=item editor()->getViewEOL() → bool

Are the end of line characters visible?

See Scintilla documentation for  L<SCI_GETVIEWEOL|https://www.scintilla.org/ScintillaDoc.html#SCI_GETVIEWEOL>

=cut

$autogen{SCI_GETVIEWEOL} = {
    subProto => 'getViewEOL() → bool',
    sciProto => 'SCI_GETVIEWEOL',
};

=item editor()->getLineEndTypesSupported() → int

Bit set of LineEndType enumertion for which line ends beyond the standard LF, CR, and CRLF are supported by the lexer.

See Scintilla documentation for  L<SCI_GETLINEENDTYPESSUPPORTED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEENDTYPESSUPPORTED>

=cut

$autogen{SCI_GETLINEENDTYPESSUPPORTED} = {
    subProto => 'getLineEndTypesSupported() → int',
    sciProto => 'SCI_GETLINEENDTYPESSUPPORTED',
};

=item editor()->setLineEndTypesAllowed(lineEndBitSet)

Set the line end types that the application wants to use. May not be used if incompatible with lexer or encoding.

See Scintilla documentation for  L<SCI_SETLINEENDTYPESALLOWED|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLINEENDTYPESALLOWED>

=cut

$autogen{SCI_SETLINEENDTYPESALLOWED} = {
    subProto => 'setLineEndTypesAllowed(lineEndBitSet)',
    sciProto => 'SCI_SETLINEENDTYPESALLOWED',
};

=item editor()->getLineEndTypesAllowed() → int

Get the line end types currently allowed.

See Scintilla documentation for  L<SCI_GETLINEENDTYPESALLOWED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEENDTYPESALLOWED>

=cut

$autogen{SCI_GETLINEENDTYPESALLOWED} = {
    subProto => 'getLineEndTypesAllowed() → int',
    sciProto => 'SCI_GETLINEENDTYPESALLOWED',
};

=item editor()->getLineEndTypesActive() → int

Get the line end types currently recognised. May be a subset of the allowed types due to lexer limitation.

See Scintilla documentation for  L<SCI_GETLINEENDTYPESACTIVE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEENDTYPESACTIVE>

=cut

$autogen{SCI_GETLINEENDTYPESACTIVE} = {
    subProto => 'getLineEndTypesActive() → int',
    sciProto => 'SCI_GETLINEENDTYPESACTIVE',
};

=back

=head2 Words

=begin scintilla

SCI_WORDENDPOSITION(position pos, bool onlyWordCharacters) → position
SCI_WORDSTARTPOSITION(position pos, bool onlyWordCharacters) → position
SCI_ISRANGEWORD(position start, position end) → bool
SCI_SETWORDCHARS(<unused>, const char *characters)
SCI_GETWORDCHARS(<unused>, char *characters) → int
SCI_SETWHITESPACECHARS(<unused>, const char *characters)
SCI_GETWHITESPACECHARS(<unused>, char *characters) → int
SCI_SETPUNCTUATIONCHARS(<unused>, const char *characters)
SCI_GETPUNCTUATIONCHARS(<unused>, char *characters) → int
SCI_SETCHARSDEFAULT
SCI_SETCHARACTERCATEGORYOPTIMIZATION(int countCharacters)
SCI_GETCHARACTERCATEGORYOPTIMIZATION → int

=end scintilla

=over

=item editor()->wordStartPosition(pos, onlyWordCharacters) → int

Get position of start of word.

See Scintilla documentation for  L<SCI_WORDSTARTPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDSTARTPOSITION>

=cut

$autogen{SCI_WORDSTARTPOSITION} = {
    subProto => 'wordStartPosition(pos, onlyWordCharacters) → int',
    sciProto => 'SCI_WORDSTARTPOSITION',
};

=item editor()->wordEndPosition(pos, onlyWordCharacters) → int

Get position of end of word.

See Scintilla documentation for  L<SCI_WORDENDPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDENDPOSITION>

=cut

$autogen{SCI_WORDENDPOSITION} = {
    subProto => 'wordEndPosition(pos, onlyWordCharacters) → int',
    sciProto => 'SCI_WORDENDPOSITION',
};

=item editor()->SCI_ISRANGEWORD

TODO

See Scintilla documentation for  L<SCI_ISRANGEWORD|https://www.scintilla.org/ScintillaDoc.html#SCI_ISRANGEWORD>

=cut

$autogen{SCI_ISRANGEWORD} = {
    subProto => 'SCI_ISRANGEWORD',
    sciProto => 'SCI_ISRANGEWORD',
};

=item editor()->setWordChars(characters)

Set the set of characters making up words for when moving or selecting by word. First sets defaults like SetCharsDefault.

See Scintilla documentation for  L<SCI_SETWORDCHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWORDCHARS>

=cut

$autogen{SCI_SETWORDCHARS} = {
    subProto => 'setWordChars(characters)',
    sciProto => 'SCI_SETWORDCHARS',
};

=item editor()->getWordChars() → str

Get the set of characters making up words for when moving or selecting by word. Retuns the number of characters

See Scintilla documentation for  L<SCI_GETWORDCHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWORDCHARS>

=cut

$autogen{SCI_GETWORDCHARS} = {
    subProto => 'getWordChars() → str',
    sciProto => 'SCI_GETWORDCHARS',
};

=item editor()->setWhitespaceChars(characters)

Set the set of characters making up whitespace for when moving or selecting by word. Should be called after SetWordChars.

See Scintilla documentation for  L<SCI_SETWHITESPACECHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWHITESPACECHARS>

=cut

$autogen{SCI_SETWHITESPACECHARS} = {
    subProto => 'setWhitespaceChars(characters)',
    sciProto => 'SCI_SETWHITESPACECHARS',
};

=item editor()->getWhitespaceChars() → str

Get the set of characters making up whitespace for when moving or selecting by word.

See Scintilla documentation for  L<SCI_GETWHITESPACECHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWHITESPACECHARS>

=cut

$autogen{SCI_GETWHITESPACECHARS} = {
    subProto => 'getWhitespaceChars() → str',
    sciProto => 'SCI_GETWHITESPACECHARS',
};

=item editor()->setPunctuationChars(characters)

Set the set of characters making up punctuation characters Should be called after SetWordChars.

See Scintilla documentation for  L<SCI_SETPUNCTUATIONCHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPUNCTUATIONCHARS>

=cut

$autogen{SCI_SETPUNCTUATIONCHARS} = {
    subProto => 'setPunctuationChars(characters)',
    sciProto => 'SCI_SETPUNCTUATIONCHARS',
};

=item editor()->getPunctuationChars() → str

Get the set of characters making up punctuation characters

See Scintilla documentation for  L<SCI_GETPUNCTUATIONCHARS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPUNCTUATIONCHARS>

=cut

$autogen{SCI_GETPUNCTUATIONCHARS} = {
    subProto => 'getPunctuationChars() → str',
    sciProto => 'SCI_GETPUNCTUATIONCHARS',
};

=item editor()->setCharsDefault()

Reset the set of characters for whitespace and word characters to the defaults.

See Scintilla documentation for  L<SCI_SETCHARSDEFAULT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCHARSDEFAULT>

=cut

$autogen{SCI_SETCHARSDEFAULT} = {
    subProto => 'setCharsDefault()',
    sciProto => 'SCI_SETCHARSDEFAULT',
};

=item editor()->SCI_SETCHARACTERCATEGORYOPTIMIZATION

TODO

See Scintilla documentation for  L<SCI_SETCHARACTERCATEGORYOPTIMIZATION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCHARACTERCATEGORYOPTIMIZATION>

=cut

$autogen{SCI_SETCHARACTERCATEGORYOPTIMIZATION} = {
    subProto => 'SCI_SETCHARACTERCATEGORYOPTIMIZATION',
    sciProto => 'SCI_SETCHARACTERCATEGORYOPTIMIZATION',
};

=item editor()->SCI_GETCHARACTERCATEGORYOPTIMIZATION

TODO

See Scintilla documentation for  L<SCI_GETCHARACTERCATEGORYOPTIMIZATION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCHARACTERCATEGORYOPTIMIZATION>

=cut

$autogen{SCI_GETCHARACTERCATEGORYOPTIMIZATION} = {
    subProto => 'SCI_GETCHARACTERCATEGORYOPTIMIZATION',
    sciProto => 'SCI_GETCHARACTERCATEGORYOPTIMIZATION',
};

=back

=head2 Styling

=begin scintilla

SCI_GETENDSTYLED → position
SCI_STARTSTYLING(position start, int unused)
SCI_SETSTYLING(position length, int style)
SCI_SETSTYLINGEX(position length, const char *styles)
SCI_SETIDLESTYLING(int idleStyling)
SCI_GETIDLESTYLING → int
SCI_SETLINESTATE(line line, int state)
SCI_GETLINESTATE(line line) → int
SCI_GETMAXLINESTATE → int

=end scintilla

=over

=item editor()->getEndStyled() → int

Retrieve the position of the last correctly styled character.

See Scintilla documentation for  L<SCI_GETENDSTYLED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETENDSTYLED>

=cut

$autogen{SCI_GETENDSTYLED} = {
    subProto => 'getEndStyled() → int',
    sciProto => 'SCI_GETENDSTYLED',
};

=item editor()->startStyling(pos, mask)

Set the current styling position to pos and the styling mask to mask. The styling mask can be used to protect some bits in each styling byte from modification.

See Scintilla documentation for  L<SCI_STARTSTYLING|https://www.scintilla.org/ScintillaDoc.html#SCI_STARTSTYLING>

=cut

$autogen{SCI_STARTSTYLING} = {
    subProto => 'startStyling(pos, mask)',
    sciProto => 'SCI_STARTSTYLING',
};

=item editor()->setStyling(length, style)

Change style from current styling position for length characters to a style and move the current styling position to after this newly styled segment.

See Scintilla documentation for  L<SCI_SETSTYLING|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSTYLING>

=cut

$autogen{SCI_SETSTYLING} = {
    subProto => 'setStyling(length, style)',
    sciProto => 'SCI_SETSTYLING',
};

=item editor()->setStylingEx(styles) → int

Set the styles for a segment of the document.

See Scintilla documentation for  L<SCI_SETSTYLINGEX|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSTYLINGEX>

=cut

$autogen{SCI_SETSTYLINGEX} = {
    subProto => 'setStylingEx(styles) → int',
    sciProto => 'SCI_SETSTYLINGEX',
};

=item editor()->SCI_SETIDLESTYLING

TODO

See Scintilla documentation for  L<SCI_SETIDLESTYLING|https://www.scintilla.org/ScintillaDoc.html#SCI_SETIDLESTYLING>

=cut

$autogen{SCI_SETIDLESTYLING} = {
    subProto => 'SCI_SETIDLESTYLING',
    sciProto => 'SCI_SETIDLESTYLING',
};

=item editor()->SCI_GETIDLESTYLING

TODO

See Scintilla documentation for  L<SCI_GETIDLESTYLING|https://www.scintilla.org/ScintillaDoc.html#SCI_GETIDLESTYLING>

=cut

$autogen{SCI_GETIDLESTYLING} = {
    subProto => 'SCI_GETIDLESTYLING',
    sciProto => 'SCI_GETIDLESTYLING',
};

=item editor()->setLineState(line, state)

Used to hold extra styling information for each line.

See Scintilla documentation for  L<SCI_SETLINESTATE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLINESTATE>

=cut

$autogen{SCI_SETLINESTATE} = {
    subProto => 'setLineState(line, state)',
    sciProto => 'SCI_SETLINESTATE',
};

=item editor()->getLineState(line) → int

Retrieve the extra styling information for a line.

See Scintilla documentation for  L<SCI_GETLINESTATE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINESTATE>

=cut

$autogen{SCI_GETLINESTATE} = {
    subProto => 'getLineState(line) → int',
    sciProto => 'SCI_GETLINESTATE',
};

=item editor()->getMaxLineState() → int

Retrieve the last line number that has line state.

See Scintilla documentation for  L<SCI_GETMAXLINESTATE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMAXLINESTATE>

=cut

$autogen{SCI_GETMAXLINESTATE} = {
    subProto => 'getMaxLineState() → int',
    sciProto => 'SCI_GETMAXLINESTATE',
};

=back

=head2 Style definition

=begin scintilla

SCI_STYLERESETDEFAULT
SCI_STYLECLEARALL
SCI_STYLESETFONT(int style, const char *fontName)
SCI_STYLEGETFONT(int style, char *fontName) → int
SCI_STYLESETSIZE(int style, int sizePoints)
SCI_STYLEGETSIZE(int style) → int
SCI_STYLESETSIZEFRACTIONAL(int style, int sizeHundredthPoints)
SCI_STYLEGETSIZEFRACTIONAL(int style) → int
SCI_STYLESETBOLD(int style, bool bold)
SCI_STYLEGETBOLD(int style) → bool
SCI_STYLESETWEIGHT(int style, int weight)
SCI_STYLEGETWEIGHT(int style) → int
SCI_STYLESETITALIC(int style, bool italic)
SCI_STYLEGETITALIC(int style) → bool
SCI_STYLESETUNDERLINE(int style, bool underline)
SCI_STYLEGETUNDERLINE(int style) → bool
SCI_STYLESETFORE(int style, colour fore)
SCI_STYLEGETFORE(int style) → colour
SCI_STYLESETBACK(int style, colour back)
SCI_STYLEGETBACK(int style) → colour
SCI_STYLESETEOLFILLED(int style, bool eolFilled)
SCI_STYLEGETEOLFILLED(int style) → bool
SCI_STYLESETCHARACTERSET(int style, int characterSet)
SCI_STYLEGETCHARACTERSET(int style) → int
SCI_STYLESETCASE(int style, int caseVisible)
SCI_STYLEGETCASE(int style) → int
SCI_STYLESETVISIBLE(int style, bool visible)
SCI_STYLEGETVISIBLE(int style) → bool
SCI_STYLESETCHANGEABLE(int style, bool changeable)
SCI_STYLEGETCHANGEABLE(int style) → bool
SCI_STYLESETHOTSPOT(int style, bool hotspot)
SCI_STYLEGETHOTSPOT(int style) → bool

=end scintilla

=over

=item editor()->styleResetDefault()

Reset the default style to its state at startup

See Scintilla documentation for  L<SCI_STYLERESETDEFAULT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLERESETDEFAULT>

=cut

$autogen{SCI_STYLERESETDEFAULT} = {
    subProto => 'styleResetDefault()',
    sciProto => 'SCI_STYLERESETDEFAULT',
};

=item editor()->styleClearAll()

Clear all the styles and make equivalent to the global default style.

See Scintilla documentation for  L<SCI_STYLECLEARALL|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLECLEARALL>

=cut

$autogen{SCI_STYLECLEARALL} = {
    subProto => 'styleClearAll()',
    sciProto => 'SCI_STYLECLEARALL',
};

=item editor()->styleSetFont(style, fontName)

Set the font of a style.

See Scintilla documentation for  L<SCI_STYLESETFONT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETFONT>

=cut

$autogen{SCI_STYLESETFONT} = {
    subProto => 'styleSetFont(style, fontName)',
    sciProto => 'SCI_STYLESETFONT',
};

=item editor()->styleGetFont(style) → str

Get the font of a style. Returns the length of the fontName

See Scintilla documentation for  L<SCI_STYLEGETFONT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETFONT>

=cut

$autogen{SCI_STYLEGETFONT} = {
    subProto => 'styleGetFont(style) → str',
    sciProto => 'SCI_STYLEGETFONT',
};

=item editor()->styleSetSize(style, sizePoints)

Set the size of characters of a style.

See Scintilla documentation for  L<SCI_STYLESETSIZE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETSIZE>

=cut

$autogen{SCI_STYLESETSIZE} = {
    subProto => 'styleSetSize(style, sizePoints)',
    sciProto => 'SCI_STYLESETSIZE',
};

=item editor()->styleGetSize(style) → int

Get the size of characters of a style.

See Scintilla documentation for  L<SCI_STYLEGETSIZE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETSIZE>

=cut

$autogen{SCI_STYLEGETSIZE} = {
    subProto => 'styleGetSize(style) → int',
    sciProto => 'SCI_STYLEGETSIZE',
};

=item editor()->styleSetSizeFractional(style, caseForce)

Set the size of characters of a style. Size is in points multiplied by 100.

See Scintilla documentation for  L<SCI_STYLESETSIZEFRACTIONAL|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETSIZEFRACTIONAL>

=cut

$autogen{SCI_STYLESETSIZEFRACTIONAL} = {
    subProto => 'styleSetSizeFractional(style, caseForce)',
    sciProto => 'SCI_STYLESETSIZEFRACTIONAL',
};

=item editor()->styleGetSizeFractional(style) → int

Get the size of characters of a style in points multiplied by 100

See Scintilla documentation for  L<SCI_STYLEGETSIZEFRACTIONAL|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETSIZEFRACTIONAL>

=cut

$autogen{SCI_STYLEGETSIZEFRACTIONAL} = {
    subProto => 'styleGetSizeFractional(style) → int',
    sciProto => 'SCI_STYLEGETSIZEFRACTIONAL',
};

=item editor()->styleSetBold(style, bold)

Set a style to be bold or not.

See Scintilla documentation for  L<SCI_STYLESETBOLD|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETBOLD>

=cut

$autogen{SCI_STYLESETBOLD} = {
    subProto => 'styleSetBold(style, bold)',
    sciProto => 'SCI_STYLESETBOLD',
};

=item editor()->styleGetBold(style) → bool

Get is a style bold or not.

See Scintilla documentation for  L<SCI_STYLEGETBOLD|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETBOLD>

=cut

$autogen{SCI_STYLEGETBOLD} = {
    subProto => 'styleGetBold(style) → bool',
    sciProto => 'SCI_STYLEGETBOLD',
};

=item editor()->styleSetWeight(style, weight)

Set the weight of characters of a style.

See Scintilla documentation for  L<SCI_STYLESETWEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETWEIGHT>

=cut

$autogen{SCI_STYLESETWEIGHT} = {
    subProto => 'styleSetWeight(style, weight)',
    sciProto => 'SCI_STYLESETWEIGHT',
};

=item editor()->styleGetWeight(style) → int

Get the weight of characters of a style.

See Scintilla documentation for  L<SCI_STYLEGETWEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETWEIGHT>

=cut

$autogen{SCI_STYLEGETWEIGHT} = {
    subProto => 'styleGetWeight(style) → int',
    sciProto => 'SCI_STYLEGETWEIGHT',
};

=item editor()->styleSetItalic(style, italic)

Set a style to be italic or not.

See Scintilla documentation for  L<SCI_STYLESETITALIC|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETITALIC>

=cut

$autogen{SCI_STYLESETITALIC} = {
    subProto => 'styleSetItalic(style, italic)',
    sciProto => 'SCI_STYLESETITALIC',
};

=item editor()->styleGetItalic(style) → bool

Get is a style italic or not.

See Scintilla documentation for  L<SCI_STYLEGETITALIC|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETITALIC>

=cut

$autogen{SCI_STYLEGETITALIC} = {
    subProto => 'styleGetItalic(style) → bool',
    sciProto => 'SCI_STYLEGETITALIC',
};

=item editor()->styleSetUnderline(style, underline)

Set a style to be underlined or not.

See Scintilla documentation for  L<SCI_STYLESETUNDERLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETUNDERLINE>

=cut

$autogen{SCI_STYLESETUNDERLINE} = {
    subProto => 'styleSetUnderline(style, underline)',
    sciProto => 'SCI_STYLESETUNDERLINE',
};

=item editor()->styleGetUnderline(style) → bool

Get is a style underlined or not.

See Scintilla documentation for  L<SCI_STYLEGETUNDERLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETUNDERLINE>

=cut

$autogen{SCI_STYLEGETUNDERLINE} = {
    subProto => 'styleGetUnderline(style) → bool',
    sciProto => 'SCI_STYLEGETUNDERLINE',
};

=item editor()->styleSetFore(style, fore)

Set the foreground colour of a style.

See Scintilla documentation for  L<SCI_STYLESETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETFORE>

=cut

$autogen{SCI_STYLESETFORE} = {
    subProto => 'styleSetFore(style, fore)',
    sciProto => 'SCI_STYLESETFORE',
};

=item editor()->styleGetFore(style) → tuple

Get the foreground colour of a style.

See Scintilla documentation for  L<SCI_STYLEGETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETFORE>

=cut

$autogen{SCI_STYLEGETFORE} = {
    subProto => 'styleGetFore(style) → tuple',
    sciProto => 'SCI_STYLEGETFORE',
};

=item editor()->styleSetBack(style, back)

Set the background colour of a style.

See Scintilla documentation for  L<SCI_STYLESETBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETBACK>

=cut

$autogen{SCI_STYLESETBACK} = {
    subProto => 'styleSetBack(style, back)',
    sciProto => 'SCI_STYLESETBACK',
};

=item editor()->styleGetBack(style) → tuple

Get the background colour of a style.

See Scintilla documentation for  L<SCI_STYLEGETBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETBACK>

=cut

$autogen{SCI_STYLEGETBACK} = {
    subProto => 'styleGetBack(style) → tuple',
    sciProto => 'SCI_STYLEGETBACK',
};

=item editor()->styleSetEOLFilled(style, filled)

Set a style to have its end of line filled or not.

See Scintilla documentation for  L<SCI_STYLESETEOLFILLED|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETEOLFILLED>

=cut

$autogen{SCI_STYLESETEOLFILLED} = {
    subProto => 'styleSetEOLFilled(style, filled)',
    sciProto => 'SCI_STYLESETEOLFILLED',
};

=item editor()->styleGetEOLFilled(style) → bool

Get is a style to have its end of line filled or not.

See Scintilla documentation for  L<SCI_STYLEGETEOLFILLED|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETEOLFILLED>

=cut

$autogen{SCI_STYLEGETEOLFILLED} = {
    subProto => 'styleGetEOLFilled(style) → bool',
    sciProto => 'SCI_STYLEGETEOLFILLED',
};

=item editor()->SCI_STYLESETCHARACTERSET

TODO

See Scintilla documentation for  L<SCI_STYLESETCHARACTERSET|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETCHARACTERSET>

=cut

$autogen{SCI_STYLESETCHARACTERSET} = {
    subProto => 'SCI_STYLESETCHARACTERSET',
    sciProto => 'SCI_STYLESETCHARACTERSET',
};

=item editor()->SCI_STYLEGETCHARACTERSET

TODO

See Scintilla documentation for  L<SCI_STYLEGETCHARACTERSET|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETCHARACTERSET>

=cut

$autogen{SCI_STYLEGETCHARACTERSET} = {
    subProto => 'SCI_STYLEGETCHARACTERSET',
    sciProto => 'SCI_STYLEGETCHARACTERSET',
};

=item editor()->styleSetCase(style, caseForce)

Set a style to be mixed case, or to force upper or lower case.

See Scintilla documentation for  L<SCI_STYLESETCASE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETCASE>

=cut

$autogen{SCI_STYLESETCASE} = {
    subProto => 'styleSetCase(style, caseForce)',
    sciProto => 'SCI_STYLESETCASE',
};

=item editor()->styleGetCase(style) → int

Get is a style mixed case, or to force upper or lower case.

See Scintilla documentation for  L<SCI_STYLEGETCASE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETCASE>

=cut

$autogen{SCI_STYLEGETCASE} = {
    subProto => 'styleGetCase(style) → int',
    sciProto => 'SCI_STYLEGETCASE',
};

=item editor()->styleSetVisible(style, visible)

Set a style to be visible or not.

See Scintilla documentation for  L<SCI_STYLESETVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETVISIBLE>

=cut

$autogen{SCI_STYLESETVISIBLE} = {
    subProto => 'styleSetVisible(style, visible)',
    sciProto => 'SCI_STYLESETVISIBLE',
};

=item editor()->styleGetVisible(style) → bool

Get is a style visible or not.

See Scintilla documentation for  L<SCI_STYLEGETVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETVISIBLE>

=cut

$autogen{SCI_STYLEGETVISIBLE} = {
    subProto => 'styleGetVisible(style) → bool',
    sciProto => 'SCI_STYLEGETVISIBLE',
};

=item editor()->styleSetChangeable(style, changeable)

Set a style to be changeable or not (read only). Experimental feature, currently buggy.

See Scintilla documentation for  L<SCI_STYLESETCHANGEABLE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETCHANGEABLE>

=cut

$autogen{SCI_STYLESETCHANGEABLE} = {
    subProto => 'styleSetChangeable(style, changeable)',
    sciProto => 'SCI_STYLESETCHANGEABLE',
};

=item editor()->styleGetChangeable(style) → bool

Get is a style changeable or not (read only). Experimental feature, currently buggy.

See Scintilla documentation for  L<SCI_STYLEGETCHANGEABLE|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETCHANGEABLE>

=cut

$autogen{SCI_STYLEGETCHANGEABLE} = {
    subProto => 'styleGetChangeable(style) → bool',
    sciProto => 'SCI_STYLEGETCHANGEABLE',
};

=item editor()->styleSetHotSpot(style, hotspot)

Set a style to be a hotspot or not.

See Scintilla documentation for  L<SCI_STYLESETHOTSPOT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLESETHOTSPOT>

=cut

$autogen{SCI_STYLESETHOTSPOT} = {
    subProto => 'styleSetHotSpot(style, hotspot)',
    sciProto => 'SCI_STYLESETHOTSPOT',
};

=item editor()->styleGetHotSpot(style) → bool

Get is a style a hotspot or not.

See Scintilla documentation for  L<SCI_STYLEGETHOTSPOT|https://www.scintilla.org/ScintillaDoc.html#SCI_STYLEGETHOTSPOT>

=cut

$autogen{SCI_STYLEGETHOTSPOT} = {
    subProto => 'styleGetHotSpot(style) → bool',
    sciProto => 'SCI_STYLEGETHOTSPOT',
};

=back

=head2 Caret, selection, and hotspot styles

=begin scintilla

SCI_SETSELFORE(bool useSetting, colour fore)
SCI_SETSELBACK(bool useSetting, colour back)
SCI_SETSELALPHA(alpha alpha)
SCI_GETSELALPHA → int
SCI_SETSELEOLFILLED(bool filled)
SCI_GETSELEOLFILLED → bool
SCI_SETCARETFORE(colour fore)
SCI_GETCARETFORE → colour
SCI_SETCARETLINEVISIBLE(bool show)
SCI_GETCARETLINEVISIBLE → bool
SCI_SETCARETLINEBACK(colour back)
SCI_GETCARETLINEBACK → colour
SCI_SETCARETLINEBACKALPHA(alpha alpha)
SCI_GETCARETLINEBACKALPHA → int
SCI_SETCARETLINEFRAME(int width)
SCI_GETCARETLINEFRAME → int
SCI_SETCARETLINEVISIBLEALWAYS(bool alwaysVisible)
SCI_GETCARETLINEVISIBLEALWAYS → bool
SCI_SETCARETPERIOD(int periodMilliseconds)
SCI_GETCARETPERIOD → int
SCI_SETCARETSTYLE(int caretStyle)
SCI_GETCARETSTYLE → int
SCI_SETCARETWIDTH(int pixelWidth)
SCI_GETCARETWIDTH → int
SCI_SETHOTSPOTACTIVEFORE(bool useSetting, colour fore)
SCI_GETHOTSPOTACTIVEFORE → colour
SCI_SETHOTSPOTACTIVEBACK(bool useSetting, colour back)
SCI_GETHOTSPOTACTIVEBACK → colour
SCI_SETHOTSPOTACTIVEUNDERLINE(bool underline)
SCI_GETHOTSPOTACTIVEUNDERLINE → bool
SCI_SETHOTSPOTSINGLELINE(bool singleLine)
SCI_GETHOTSPOTSINGLELINE → bool
SCI_SETCARETSTICKY(int useCaretStickyBehaviour)
SCI_GETCARETSTICKY → int
SCI_TOGGLECARETSTICKY

=end scintilla

=over

=item editor()->setSelFore(useSetting, fore)

Set the foreground colour of the main and additional selections and whether to use this setting.

See Scintilla documentation for  L<SCI_SETSELFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELFORE>

=cut

$autogen{SCI_SETSELFORE} = {
    subProto => 'setSelFore(useSetting, fore)',
    sciProto => 'SCI_SETSELFORE',
};

=item editor()->setSelBack(useSetting, back)

Set the background colour of the main and additional selections and whether to use this setting.

See Scintilla documentation for  L<SCI_SETSELBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELBACK>

=cut

$autogen{SCI_SETSELBACK} = {
    subProto => 'setSelBack(useSetting, back)',
    sciProto => 'SCI_SETSELBACK',
};

=item editor()->getSelAlpha() → int

Get the alpha of the selection.

See Scintilla documentation for  L<SCI_GETSELALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELALPHA>

=cut

$autogen{SCI_GETSELALPHA} = {
    subProto => 'getSelAlpha() → int',
    sciProto => 'SCI_GETSELALPHA',
};

=item editor()->setSelAlpha(alpha)

Set the alpha of the selection.

See Scintilla documentation for  L<SCI_SETSELALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELALPHA>

=cut

$autogen{SCI_SETSELALPHA} = {
    subProto => 'setSelAlpha(alpha)',
    sciProto => 'SCI_SETSELALPHA',
};

=item editor()->getSelEOLFilled() → bool

Is the selection end of line filled?

See Scintilla documentation for  L<SCI_GETSELEOLFILLED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELEOLFILLED>

=cut

$autogen{SCI_GETSELEOLFILLED} = {
    subProto => 'getSelEOLFilled() → bool',
    sciProto => 'SCI_GETSELEOLFILLED',
};

=item editor()->setSelEOLFilled(filled)

Set the selection to have its end of line filled or not.

See Scintilla documentation for  L<SCI_SETSELEOLFILLED|https://www.scintilla.org/ScintillaDoc.html#SCI_SETSELEOLFILLED>

=cut

$autogen{SCI_SETSELEOLFILLED} = {
    subProto => 'setSelEOLFilled(filled)',
    sciProto => 'SCI_SETSELEOLFILLED',
};

=item editor()->setCaretFore(fore)

Set the foreground colour of the caret.

See Scintilla documentation for  L<SCI_SETCARETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETFORE>

=cut

$autogen{SCI_SETCARETFORE} = {
    subProto => 'setCaretFore(fore)',
    sciProto => 'SCI_SETCARETFORE',
};

=item editor()->getCaretFore() → tuple

Get the foreground colour of the caret.

See Scintilla documentation for  L<SCI_GETCARETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETFORE>

=cut

$autogen{SCI_GETCARETFORE} = {
    subProto => 'getCaretFore() → tuple',
    sciProto => 'SCI_GETCARETFORE',
};

=item editor()->getCaretLineVisible() → bool

Is the background of the line containing the caret in a different colour?

See Scintilla documentation for  L<SCI_GETCARETLINEVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETLINEVISIBLE>

=cut

$autogen{SCI_GETCARETLINEVISIBLE} = {
    subProto => 'getCaretLineVisible() → bool',
    sciProto => 'SCI_GETCARETLINEVISIBLE',
};

=item editor()->setCaretLineVisible(show)

Display the background of the line containing the caret in a different colour.

See Scintilla documentation for  L<SCI_SETCARETLINEVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETLINEVISIBLE>

=cut

$autogen{SCI_SETCARETLINEVISIBLE} = {
    subProto => 'setCaretLineVisible(show)',
    sciProto => 'SCI_SETCARETLINEVISIBLE',
};

=item editor()->getCaretLineBack() → tuple

Get the colour of the background of the line containing the caret.

See Scintilla documentation for  L<SCI_GETCARETLINEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETLINEBACK>

=cut

$autogen{SCI_GETCARETLINEBACK} = {
    subProto => 'getCaretLineBack() → tuple',
    sciProto => 'SCI_GETCARETLINEBACK',
};

=item editor()->setCaretLineBack(back)

Set the colour of the background of the line containing the caret.

See Scintilla documentation for  L<SCI_SETCARETLINEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETLINEBACK>

=cut

$autogen{SCI_SETCARETLINEBACK} = {
    subProto => 'setCaretLineBack(back)',
    sciProto => 'SCI_SETCARETLINEBACK',
};

=item editor()->setCaretLineBackAlpha(alpha)

Set background alpha of the caret line.

See Scintilla documentation for  L<SCI_SETCARETLINEBACKALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETLINEBACKALPHA>

=cut

$autogen{SCI_SETCARETLINEBACKALPHA} = {
    subProto => 'setCaretLineBackAlpha(alpha)',
    sciProto => 'SCI_SETCARETLINEBACKALPHA',
};

=item editor()->getCaretLineBackAlpha() → int

Get the background alpha of the caret line.

See Scintilla documentation for  L<SCI_GETCARETLINEBACKALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETLINEBACKALPHA>

=cut

$autogen{SCI_GETCARETLINEBACKALPHA} = {
    subProto => 'getCaretLineBackAlpha() → int',
    sciProto => 'SCI_GETCARETLINEBACKALPHA',
};

=item editor()->SCI_SETCARETLINEFRAME

TODO

See Scintilla documentation for  L<SCI_SETCARETLINEFRAME|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETLINEFRAME>

=cut

$autogen{SCI_SETCARETLINEFRAME} = {
    subProto => 'SCI_SETCARETLINEFRAME',
    sciProto => 'SCI_SETCARETLINEFRAME',
};

=item editor()->SCI_GETCARETLINEFRAME

TODO

See Scintilla documentation for  L<SCI_GETCARETLINEFRAME|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETLINEFRAME>

=cut

$autogen{SCI_GETCARETLINEFRAME} = {
    subProto => 'SCI_GETCARETLINEFRAME',
    sciProto => 'SCI_GETCARETLINEFRAME',
};

=item editor()->getCaretLineVisibleAlways() → bool

Is the caret line always visible?

See Scintilla documentation for  L<SCI_GETCARETLINEVISIBLEALWAYS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETLINEVISIBLEALWAYS>

=cut

$autogen{SCI_GETCARETLINEVISIBLEALWAYS} = {
    subProto => 'getCaretLineVisibleAlways() → bool',
    sciProto => 'SCI_GETCARETLINEVISIBLEALWAYS',
};

=item editor()->setCaretLineVisibleAlways(alwaysVisible)

Sets the caret line to always visible.

See Scintilla documentation for  L<SCI_SETCARETLINEVISIBLEALWAYS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETLINEVISIBLEALWAYS>

=cut

$autogen{SCI_SETCARETLINEVISIBLEALWAYS} = {
    subProto => 'setCaretLineVisibleAlways(alwaysVisible)',
    sciProto => 'SCI_SETCARETLINEVISIBLEALWAYS',
};

=item editor()->getCaretPeriod() → int

Get the time in milliseconds that the caret is on and off.

See Scintilla documentation for  L<SCI_GETCARETPERIOD|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETPERIOD>

=cut

$autogen{SCI_GETCARETPERIOD} = {
    subProto => 'getCaretPeriod() → int',
    sciProto => 'SCI_GETCARETPERIOD',
};

=item editor()->setCaretPeriod(periodMilliseconds)

Get the time in milliseconds that the caret is on and off. 0 = steady on.

See Scintilla documentation for  L<SCI_SETCARETPERIOD|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETPERIOD>

=cut

$autogen{SCI_SETCARETPERIOD} = {
    subProto => 'setCaretPeriod(periodMilliseconds)',
    sciProto => 'SCI_SETCARETPERIOD',
};

=item editor()->setCaretStyle(caretStyle)

Set the style of the caret to be drawn.

See Scintilla documentation for  L<SCI_SETCARETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETSTYLE>

=cut

$autogen{SCI_SETCARETSTYLE} = {
    subProto => 'setCaretStyle(caretStyle)',
    sciProto => 'SCI_SETCARETSTYLE',
};

=item editor()->getCaretStyle() → int

Returns the current style of the caret.

See Scintilla documentation for  L<SCI_GETCARETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETSTYLE>

=cut

$autogen{SCI_GETCARETSTYLE} = {
    subProto => 'getCaretStyle() → int',
    sciProto => 'SCI_GETCARETSTYLE',
};

=item editor()->setCaretWidth(pixelWidth)

Set the width of the insert mode caret.

See Scintilla documentation for  L<SCI_SETCARETWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETWIDTH>

=cut

$autogen{SCI_SETCARETWIDTH} = {
    subProto => 'setCaretWidth(pixelWidth)',
    sciProto => 'SCI_SETCARETWIDTH',
};

=item editor()->getCaretWidth() → int

Returns the width of the insert mode caret.

See Scintilla documentation for  L<SCI_GETCARETWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETWIDTH>

=cut

$autogen{SCI_GETCARETWIDTH} = {
    subProto => 'getCaretWidth() → int',
    sciProto => 'SCI_GETCARETWIDTH',
};

=item editor()->setHotspotActiveFore(useSetting, fore)

Set a fore colour for active hotspots.

See Scintilla documentation for  L<SCI_SETHOTSPOTACTIVEFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHOTSPOTACTIVEFORE>

=cut

$autogen{SCI_SETHOTSPOTACTIVEFORE} = {
    subProto => 'setHotspotActiveFore(useSetting, fore)',
    sciProto => 'SCI_SETHOTSPOTACTIVEFORE',
};

=item editor()->getHotspotActiveFore() → tuple

Get the fore colour for active hotspots.

See Scintilla documentation for  L<SCI_GETHOTSPOTACTIVEFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHOTSPOTACTIVEFORE>

=cut

$autogen{SCI_GETHOTSPOTACTIVEFORE} = {
    subProto => 'getHotspotActiveFore() → tuple',
    sciProto => 'SCI_GETHOTSPOTACTIVEFORE',
};

=item editor()->setHotspotActiveBack(useSetting, back)

Set a back colour for active hotspots.

See Scintilla documentation for  L<SCI_SETHOTSPOTACTIVEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHOTSPOTACTIVEBACK>

=cut

$autogen{SCI_SETHOTSPOTACTIVEBACK} = {
    subProto => 'setHotspotActiveBack(useSetting, back)',
    sciProto => 'SCI_SETHOTSPOTACTIVEBACK',
};

=item editor()->getHotspotActiveBack() → tuple

Get the back colour for active hotspots.

See Scintilla documentation for  L<SCI_GETHOTSPOTACTIVEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHOTSPOTACTIVEBACK>

=cut

$autogen{SCI_GETHOTSPOTACTIVEBACK} = {
    subProto => 'getHotspotActiveBack() → tuple',
    sciProto => 'SCI_GETHOTSPOTACTIVEBACK',
};

=item editor()->setHotspotActiveUnderline(underline)

Enable / Disable underlining active hotspots.

See Scintilla documentation for  L<SCI_SETHOTSPOTACTIVEUNDERLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHOTSPOTACTIVEUNDERLINE>

=cut

$autogen{SCI_SETHOTSPOTACTIVEUNDERLINE} = {
    subProto => 'setHotspotActiveUnderline(underline)',
    sciProto => 'SCI_SETHOTSPOTACTIVEUNDERLINE',
};

=item editor()->getHotspotActiveUnderline() → bool

Get whether underlining for active hotspots.

See Scintilla documentation for  L<SCI_GETHOTSPOTACTIVEUNDERLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHOTSPOTACTIVEUNDERLINE>

=cut

$autogen{SCI_GETHOTSPOTACTIVEUNDERLINE} = {
    subProto => 'getHotspotActiveUnderline() → bool',
    sciProto => 'SCI_GETHOTSPOTACTIVEUNDERLINE',
};

=item editor()->setHotspotSingleLine(singleLine)

Limit hotspots to single line so hotspots on two lines don’t merge.

See Scintilla documentation for  L<SCI_SETHOTSPOTSINGLELINE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHOTSPOTSINGLELINE>

=cut

$autogen{SCI_SETHOTSPOTSINGLELINE} = {
    subProto => 'setHotspotSingleLine(singleLine)',
    sciProto => 'SCI_SETHOTSPOTSINGLELINE',
};

=item editor()->getHotspotSingleLine() → bool

Get the HotspotSingleLine property

See Scintilla documentation for  L<SCI_GETHOTSPOTSINGLELINE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHOTSPOTSINGLELINE>

=cut

$autogen{SCI_GETHOTSPOTSINGLELINE} = {
    subProto => 'getHotspotSingleLine() → bool',
    sciProto => 'SCI_GETHOTSPOTSINGLELINE',
};

=item editor()->getCaretSticky() → int

Can the caret preferred x position only be changed by explicit movement commands?

See Scintilla documentation for  L<SCI_GETCARETSTICKY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCARETSTICKY>

=cut

$autogen{SCI_GETCARETSTICKY} = {
    subProto => 'getCaretSticky() → int',
    sciProto => 'SCI_GETCARETSTICKY',
};

=item editor()->setCaretSticky(useCaretStickyBehaviour)

Stop the caret preferred x position changing when the user types.

See Scintilla documentation for  L<SCI_SETCARETSTICKY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCARETSTICKY>

=cut

$autogen{SCI_SETCARETSTICKY} = {
    subProto => 'setCaretSticky(useCaretStickyBehaviour)',
    sciProto => 'SCI_SETCARETSTICKY',
};

=item editor()->toggleCaretSticky()

Switch between sticky and non-sticky: meant to be bound to a key.

See Scintilla documentation for  L<SCI_TOGGLECARETSTICKY|https://www.scintilla.org/ScintillaDoc.html#SCI_TOGGLECARETSTICKY>

=cut

$autogen{SCI_TOGGLECARETSTICKY} = {
    subProto => 'toggleCaretSticky()',
    sciProto => 'SCI_TOGGLECARETSTICKY',
};

=back

=head2 Character representations

=begin scintilla

SCI_SETREPRESENTATION(const char *encodedCharacter, const char *representation)
SCI_GETREPRESENTATION(const char *encodedCharacter, char *representation) → int
SCI_CLEARREPRESENTATION(const char *encodedCharacter)
SCI_SETCONTROLCHARSYMBOL(int symbol)
SCI_GETCONTROLCHARSYMBOL → int

=end scintilla

=over

=item editor()->setRepresentation(encodedCharacter, representation)

Set the way a character is drawn.

See Scintilla documentation for  L<SCI_SETREPRESENTATION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETREPRESENTATION>

=cut

$autogen{SCI_SETREPRESENTATION} = {
    subProto => 'setRepresentation(encodedCharacter, representation)',
    sciProto => 'SCI_SETREPRESENTATION',
};

=item editor()->getRepresentation() → str

Set the way a character is drawn.

See Scintilla documentation for  L<SCI_GETREPRESENTATION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETREPRESENTATION>

=cut

$autogen{SCI_GETREPRESENTATION} = {
    subProto => 'getRepresentation() → str',
    sciProto => 'SCI_GETREPRESENTATION',
};

=item editor()->clearRepresentation(encodedCharacter)

Remove a character representation.

See Scintilla documentation for  L<SCI_CLEARREPRESENTATION|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARREPRESENTATION>

=cut

$autogen{SCI_CLEARREPRESENTATION} = {
    subProto => 'clearRepresentation(encodedCharacter)',
    sciProto => 'SCI_CLEARREPRESENTATION',
};

=item editor()->setControlCharSymbol(symbol)

Change the way control characters are displayed: If symbol is < 32, keep the drawn way, else, use the given character.

See Scintilla documentation for  L<SCI_SETCONTROLCHARSYMBOL|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCONTROLCHARSYMBOL>

=cut

$autogen{SCI_SETCONTROLCHARSYMBOL} = {
    subProto => 'setControlCharSymbol(symbol)',
    sciProto => 'SCI_SETCONTROLCHARSYMBOL',
};

=item editor()->getControlCharSymbol() → int

Get the way control characters are displayed.

See Scintilla documentation for  L<SCI_GETCONTROLCHARSYMBOL|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCONTROLCHARSYMBOL>

=cut

$autogen{SCI_GETCONTROLCHARSYMBOL} = {
    subProto => 'getControlCharSymbol() → int',
    sciProto => 'SCI_GETCONTROLCHARSYMBOL',
};

=back

=head2 Margins

=begin scintilla

SCI_SETMARGINS(int margins)
SCI_GETMARGINS → int
SCI_SETMARGINTYPEN(int margin, int marginType)
SCI_GETMARGINTYPEN(int margin) → int
SCI_SETMARGINWIDTHN(int margin, int pixelWidth)
SCI_GETMARGINWIDTHN(int margin) → int
SCI_SETMARGINMASKN(int margin, int mask)
SCI_GETMARGINMASKN(int margin) → int
SCI_SETMARGINSENSITIVEN(int margin, bool sensitive)
SCI_GETMARGINSENSITIVEN(int margin) → bool
SCI_SETMARGINCURSORN(int margin, int cursor)
SCI_GETMARGINCURSORN(int margin) → int
SCI_SETMARGINBACKN(int margin, colour back)
SCI_GETMARGINBACKN(int margin) → colour
SCI_SETMARGINLEFT(<unused>, int pixelWidth)
SCI_GETMARGINLEFT → int
SCI_SETMARGINRIGHT(<unused>, int pixelWidth)
SCI_GETMARGINRIGHT → int
SCI_SETFOLDMARGINCOLOUR(bool useSetting, colour back)
SCI_SETFOLDMARGINHICOLOUR(bool useSetting, colour fore)
SCI_MARGINSETTEXT(line line, const char *text)
SCI_MARGINGETTEXT(line line, char *text) → int
SCI_MARGINSETSTYLE(line line, int style)
SCI_MARGINGETSTYLE(line line) → int
SCI_MARGINSETSTYLES(line line, const char *styles)
SCI_MARGINGETSTYLES(line line, char *styles) → int
SCI_MARGINTEXTCLEARALL
SCI_MARGINSETSTYLEOFFSET(int style)
SCI_MARGINGETSTYLEOFFSET → int
SCI_SETMARGINOPTIONS(int marginOptions)
SCI_GETMARGINOPTIONS → int

=end scintilla

=over

=item editor()->SCI_SETMARGINS

TODO

See Scintilla documentation for  L<SCI_SETMARGINS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINS>

=cut

$autogen{SCI_SETMARGINS} = {
    subProto => 'SCI_SETMARGINS',
    sciProto => 'SCI_SETMARGINS',
};

=item editor()->SCI_GETMARGINS

TODO

See Scintilla documentation for  L<SCI_GETMARGINS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINS>

=cut

$autogen{SCI_GETMARGINS} = {
    subProto => 'SCI_GETMARGINS',
    sciProto => 'SCI_GETMARGINS',
};

=item editor()->setMarginTypeN(margin, marginType)

Set a margin to be either numeric or symbolic.

See Scintilla documentation for  L<SCI_SETMARGINTYPEN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINTYPEN>

=cut

$autogen{SCI_SETMARGINTYPEN} = {
    subProto => 'setMarginTypeN(margin, marginType)',
    sciProto => 'SCI_SETMARGINTYPEN',
};

=item editor()->getMarginTypeN(margin) → int

Retrieve the type of a margin.

See Scintilla documentation for  L<SCI_GETMARGINTYPEN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINTYPEN>

=cut

$autogen{SCI_GETMARGINTYPEN} = {
    subProto => 'getMarginTypeN(margin) → int',
    sciProto => 'SCI_GETMARGINTYPEN',
};

=item editor()->setMarginWidthN(margin, pixelWidth)

Set the width of a margin to a width expressed in pixels.

See Scintilla documentation for  L<SCI_SETMARGINWIDTHN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINWIDTHN>

=cut

$autogen{SCI_SETMARGINWIDTHN} = {
    subProto => 'setMarginWidthN(margin, pixelWidth)',
    sciProto => 'SCI_SETMARGINWIDTHN',
};

=item editor()->getMarginWidthN(margin) → int

Retrieve the width of a margin in pixels.

See Scintilla documentation for  L<SCI_GETMARGINWIDTHN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINWIDTHN>

=cut

$autogen{SCI_GETMARGINWIDTHN} = {
    subProto => 'getMarginWidthN(margin) → int',
    sciProto => 'SCI_GETMARGINWIDTHN',
};

=item editor()->setMarginMaskN(margin, mask)

Set a mask that determines which markers are displayed in a margin.

See Scintilla documentation for  L<SCI_SETMARGINMASKN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINMASKN>

=cut

$autogen{SCI_SETMARGINMASKN} = {
    subProto => 'setMarginMaskN(margin, mask)',
    sciProto => 'SCI_SETMARGINMASKN',
};

=item editor()->getMarginMaskN(margin) → int

Retrieve the marker mask of a margin.

See Scintilla documentation for  L<SCI_GETMARGINMASKN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINMASKN>

=cut

$autogen{SCI_GETMARGINMASKN} = {
    subProto => 'getMarginMaskN(margin) → int',
    sciProto => 'SCI_GETMARGINMASKN',
};

=item editor()->setMarginSensitiveN(margin, sensitive)

Make a margin sensitive or insensitive to mouse clicks.

See Scintilla documentation for  L<SCI_SETMARGINSENSITIVEN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINSENSITIVEN>

=cut

$autogen{SCI_SETMARGINSENSITIVEN} = {
    subProto => 'setMarginSensitiveN(margin, sensitive)',
    sciProto => 'SCI_SETMARGINSENSITIVEN',
};

=item editor()->getMarginSensitiveN(margin) → bool

Retrieve the mouse click sensitivity of a margin.

See Scintilla documentation for  L<SCI_GETMARGINSENSITIVEN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINSENSITIVEN>

=cut

$autogen{SCI_GETMARGINSENSITIVEN} = {
    subProto => 'getMarginSensitiveN(margin) → bool',
    sciProto => 'SCI_GETMARGINSENSITIVEN',
};

=item editor()->setMarginCursorN(margin, cursor)

Set the cursor shown when the mouse is inside a margin.

See Scintilla documentation for  L<SCI_SETMARGINCURSORN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINCURSORN>

=cut

$autogen{SCI_SETMARGINCURSORN} = {
    subProto => 'setMarginCursorN(margin, cursor)',
    sciProto => 'SCI_SETMARGINCURSORN',
};

=item editor()->getMarginCursorN(margin) → int

Retrieve the cursor shown in a margin.

See Scintilla documentation for  L<SCI_GETMARGINCURSORN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINCURSORN>

=cut

$autogen{SCI_GETMARGINCURSORN} = {
    subProto => 'getMarginCursorN(margin) → int',
    sciProto => 'SCI_GETMARGINCURSORN',
};

=item editor()->styleGetCharacterSet(style) → int

Get the character get of the font in a style.

=item editor()->SCI_SETMARGINBACKN

TODO

See Scintilla documentation for  L<SCI_SETMARGINBACKN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINBACKN>

=cut

$autogen{SCI_SETMARGINBACKN} = {
    subProto => 'styleGetCharacterSet(style) → int',
    sciProto => 'SCI_SETMARGINBACKN',
};

=item editor()->SCI_GETMARGINBACKN

TODO

See Scintilla documentation for  L<SCI_GETMARGINBACKN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINBACKN>

=cut

$autogen{SCI_GETMARGINBACKN} = {
    subProto => 'SCI_GETMARGINBACKN',
    sciProto => 'SCI_GETMARGINBACKN',
};

=item editor()->setMarginLeft(pixelWidth)

Sets the size in pixels of the left margin.

See Scintilla documentation for  L<SCI_SETMARGINLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINLEFT>

=cut

$autogen{SCI_SETMARGINLEFT} = {
    subProto => 'setMarginLeft(pixelWidth)',
    sciProto => 'SCI_SETMARGINLEFT',
};

=item editor()->getMarginLeft() → int

Returns the size in pixels of the left margin.

See Scintilla documentation for  L<SCI_GETMARGINLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINLEFT>

=cut

$autogen{SCI_GETMARGINLEFT} = {
    subProto => 'getMarginLeft() → int',
    sciProto => 'SCI_GETMARGINLEFT',
};

=item editor()->setMarginRight(pixelWidth)

Sets the size in pixels of the right margin.

See Scintilla documentation for  L<SCI_SETMARGINRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINRIGHT>

=cut

$autogen{SCI_SETMARGINRIGHT} = {
    subProto => 'setMarginRight(pixelWidth)',
    sciProto => 'SCI_SETMARGINRIGHT',
};

=item editor()->getMarginRight() → int

Returns the size in pixels of the right margin.

See Scintilla documentation for  L<SCI_GETMARGINRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINRIGHT>

=cut

$autogen{SCI_GETMARGINRIGHT} = {
    subProto => 'getMarginRight() → int',
    sciProto => 'SCI_GETMARGINRIGHT',
};

=item editor()->setFoldMarginColour(useSetting, back)

Set the colours used as a chequerboard pattern in the fold margin

See Scintilla documentation for  L<SCI_SETFOLDMARGINCOLOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOLDMARGINCOLOUR>

=cut

$autogen{SCI_SETFOLDMARGINCOLOUR} = {
    subProto => 'setFoldMarginColour(useSetting, back)',
    sciProto => 'SCI_SETFOLDMARGINCOLOUR',
};

=item editor()->setFoldMarginHiColour(useSetting, fore)

Set the colours used as a chequerboard pattern in the fold margin

See Scintilla documentation for  L<SCI_SETFOLDMARGINHICOLOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOLDMARGINHICOLOUR>

=cut

$autogen{SCI_SETFOLDMARGINHICOLOUR} = {
    subProto => 'setFoldMarginHiColour(useSetting, fore)',
    sciProto => 'SCI_SETFOLDMARGINHICOLOUR',
};

=item editor()->marginSetText(line, text)

Set the text in the text margin for a line

See Scintilla documentation for  L<SCI_MARGINSETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINSETTEXT>

=cut

$autogen{SCI_MARGINSETTEXT} = {
    subProto => 'marginSetText(line, text)',
    sciProto => 'SCI_MARGINSETTEXT',
};

=item editor()->marginGetText(line) → str

Get the text in the text margin for a line

See Scintilla documentation for  L<SCI_MARGINGETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINGETTEXT>

=cut

$autogen{SCI_MARGINGETTEXT} = {
    subProto => 'marginGetText(line) → str',
    sciProto => 'SCI_MARGINGETTEXT',
};

=item editor()->marginSetStyle(line, style)

Set the style number for the text margin for a line

See Scintilla documentation for  L<SCI_MARGINSETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINSETSTYLE>

=cut

$autogen{SCI_MARGINSETSTYLE} = {
    subProto => 'marginSetStyle(line, style)',
    sciProto => 'SCI_MARGINSETSTYLE',
};

=item editor()->marginGetStyle(line) → int

Get the style number for the text margin for a line

See Scintilla documentation for  L<SCI_MARGINGETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINGETSTYLE>

=cut

$autogen{SCI_MARGINGETSTYLE} = {
    subProto => 'marginGetStyle(line) → int',
    sciProto => 'SCI_MARGINGETSTYLE',
};

=item editor()->marginSetStyles(line, styles)

Set the style in the text margin for a line

See Scintilla documentation for  L<SCI_MARGINSETSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINSETSTYLES>

=cut

$autogen{SCI_MARGINSETSTYLES} = {
    subProto => 'marginSetStyles(line, styles)',
    sciProto => 'SCI_MARGINSETSTYLES',
};

=item editor()->marginGetStyles(line) → str

Get the styles in the text margin for a line

See Scintilla documentation for  L<SCI_MARGINGETSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINGETSTYLES>

=cut

$autogen{SCI_MARGINGETSTYLES} = {
    subProto => 'marginGetStyles(line) → str',
    sciProto => 'SCI_MARGINGETSTYLES',
};

=item editor()->marginTextClearAll()

Clear the margin text on all lines

See Scintilla documentation for  L<SCI_MARGINTEXTCLEARALL|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINTEXTCLEARALL>

=cut

$autogen{SCI_MARGINTEXTCLEARALL} = {
    subProto => 'marginTextClearAll()',
    sciProto => 'SCI_MARGINTEXTCLEARALL',
};

=item editor()->marginSetStyleOffset(style)

Get the start of the range of style numbers used for margin text

See Scintilla documentation for  L<SCI_MARGINSETSTYLEOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINSETSTYLEOFFSET>

=cut

$autogen{SCI_MARGINSETSTYLEOFFSET} = {
    subProto => 'marginSetStyleOffset(style)',
    sciProto => 'SCI_MARGINSETSTYLEOFFSET',
};

=item editor()->marginGetStyleOffset() → int

Get the start of the range of style numbers used for margin text

See Scintilla documentation for  L<SCI_MARGINGETSTYLEOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_MARGINGETSTYLEOFFSET>

=cut

$autogen{SCI_MARGINGETSTYLEOFFSET} = {
    subProto => 'marginGetStyleOffset() → int',
    sciProto => 'SCI_MARGINGETSTYLEOFFSET',
};

=item editor()->setMarginOptions(marginOptions)

Set the margin options.

See Scintilla documentation for  L<SCI_SETMARGINOPTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMARGINOPTIONS>

=cut

$autogen{SCI_SETMARGINOPTIONS} = {
    subProto => 'setMarginOptions(marginOptions)',
    sciProto => 'SCI_SETMARGINOPTIONS',
};

=item editor()->getMarginOptions() → int

Get the margin options.

See Scintilla documentation for  L<SCI_GETMARGINOPTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMARGINOPTIONS>

=cut

$autogen{SCI_GETMARGINOPTIONS} = {
    subProto => 'getMarginOptions() → int',
    sciProto => 'SCI_GETMARGINOPTIONS',
};

=back

=head2 Annotations

=begin scintilla

SCI_ANNOTATIONSETTEXT(line line, const char *text)
SCI_ANNOTATIONGETTEXT(line line, char *text) → int
SCI_ANNOTATIONSETSTYLE(line line, int style)
SCI_ANNOTATIONGETSTYLE(line line) → int
SCI_ANNOTATIONSETSTYLES(line line, const char *styles)
SCI_ANNOTATIONGETSTYLES(line line, char *styles) → int
SCI_ANNOTATIONGETLINES(line line) → int
SCI_ANNOTATIONCLEARALL
SCI_ANNOTATIONSETVISIBLE(int visible)
SCI_ANNOTATIONGETVISIBLE → int
SCI_ANNOTATIONSETSTYLEOFFSET(int style)
SCI_ANNOTATIONGETSTYLEOFFSET → int

=end scintilla

=over

=item editor()->annotationSetText(line, text)

Set the annotation text for a line

See Scintilla documentation for  L<SCI_ANNOTATIONSETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONSETTEXT>

=cut

$autogen{SCI_ANNOTATIONSETTEXT} = {
    subProto => 'annotationSetText(line, text)',
    sciProto => 'SCI_ANNOTATIONSETTEXT',
};

=item editor()->annotationGetText(line) → str

Get the annotation text for a line

See Scintilla documentation for  L<SCI_ANNOTATIONGETTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETTEXT>

=cut

$autogen{SCI_ANNOTATIONGETTEXT} = {
    subProto => 'annotationGetText(line) → str',
    sciProto => 'SCI_ANNOTATIONGETTEXT',
};

=item editor()->annotationSetStyle(line, style)

Set the style number for the annotations for a line

See Scintilla documentation for  L<SCI_ANNOTATIONSETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONSETSTYLE>

=cut

$autogen{SCI_ANNOTATIONSETSTYLE} = {
    subProto => 'annotationSetStyle(line, style)',
    sciProto => 'SCI_ANNOTATIONSETSTYLE',
};

=item editor()->annotationGetStyle(line) → int

Get the style number for the annotations for a line

See Scintilla documentation for  L<SCI_ANNOTATIONGETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETSTYLE>

=cut

$autogen{SCI_ANNOTATIONGETSTYLE} = {
    subProto => 'annotationGetStyle(line) → int',
    sciProto => 'SCI_ANNOTATIONGETSTYLE',
};

=item editor()->annotationSetStyles(line, styles)

Set the annotation styles for a line

See Scintilla documentation for  L<SCI_ANNOTATIONSETSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONSETSTYLES>

=cut

$autogen{SCI_ANNOTATIONSETSTYLES} = {
    subProto => 'annotationSetStyles(line, styles)',
    sciProto => 'SCI_ANNOTATIONSETSTYLES',
};

=item editor()->annotationGetStyles(line) → str

Get the annotation styles for a line

See Scintilla documentation for  L<SCI_ANNOTATIONGETSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETSTYLES>

=cut

$autogen{SCI_ANNOTATIONGETSTYLES} = {
    subProto => 'annotationGetStyles(line) → str',
    sciProto => 'SCI_ANNOTATIONGETSTYLES',
};

=item editor()->annotationGetLines(line) → int

Get the number of annotation lines for a line

See Scintilla documentation for  L<SCI_ANNOTATIONGETLINES|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETLINES>

=cut

$autogen{SCI_ANNOTATIONGETLINES} = {
    subProto => 'annotationGetLines(line) → int',
    sciProto => 'SCI_ANNOTATIONGETLINES',
};

=item editor()->annotationClearAll()

Clear the annotations from all lines

See Scintilla documentation for  L<SCI_ANNOTATIONCLEARALL|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONCLEARALL>

=cut

$autogen{SCI_ANNOTATIONCLEARALL} = {
    subProto => 'annotationClearAll()',
    sciProto => 'SCI_ANNOTATIONCLEARALL',
};

=item editor()->annotationSetVisible(visible)

Set the visibility for the annotations for a view

See Scintilla documentation for  L<SCI_ANNOTATIONSETVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONSETVISIBLE>

=cut

$autogen{SCI_ANNOTATIONSETVISIBLE} = {
    subProto => 'annotationSetVisible(visible)',
    sciProto => 'SCI_ANNOTATIONSETVISIBLE',
};

=item editor()->annotationGetVisible() → int

Get the visibility for the annotations for a view

See Scintilla documentation for  L<SCI_ANNOTATIONGETVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETVISIBLE>

=cut

$autogen{SCI_ANNOTATIONGETVISIBLE} = {
    subProto => 'annotationGetVisible() → int',
    sciProto => 'SCI_ANNOTATIONGETVISIBLE',
};

=item editor()->annotationSetStyleOffset(style)

Get the start of the range of style numbers used for annotations

See Scintilla documentation for  L<SCI_ANNOTATIONSETSTYLEOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONSETSTYLEOFFSET>

=cut

$autogen{SCI_ANNOTATIONSETSTYLEOFFSET} = {
    subProto => 'annotationSetStyleOffset(style)',
    sciProto => 'SCI_ANNOTATIONSETSTYLEOFFSET',
};

=item editor()->annotationGetStyleOffset() → int

Get the start of the range of style numbers used for annotations

See Scintilla documentation for  L<SCI_ANNOTATIONGETSTYLEOFFSET|https://www.scintilla.org/ScintillaDoc.html#SCI_ANNOTATIONGETSTYLEOFFSET>

=cut

$autogen{SCI_ANNOTATIONGETSTYLEOFFSET} = {
    subProto => 'annotationGetStyleOffset() → int',
    sciProto => 'SCI_ANNOTATIONGETSTYLEOFFSET',
};

=back

=head2 Other settings

=begin scintilla

SCI_SETBUFFEREDDRAW(bool buffered)
SCI_GETBUFFEREDDRAW → bool
SCI_SETPHASESDRAW(int phases)
SCI_GETPHASESDRAW → int
SCI_SETTECHNOLOGY(int technology)
SCI_GETTECHNOLOGY → int
SCI_SETFONTQUALITY(int fontQuality)
SCI_GETFONTQUALITY → int
SCI_SETCODEPAGE(int codePage)
SCI_GETCODEPAGE → int
SCI_SETIMEINTERACTION(int imeInteraction)
SCI_GETIMEINTERACTION → int
SCI_SETBIDIRECTIONAL(int bidirectional)
SCI_GETBIDIRECTIONAL → int
SCI_GRABFOCUS
SCI_SETFOCUS(bool focus)
SCI_GETFOCUS → bool

=end scintilla

=over

=item editor()->getBufferedDraw() → bool

Is drawing done first into a buffer or direct to the screen?

See Scintilla documentation for  L<SCI_GETBUFFEREDDRAW|https://www.scintilla.org/ScintillaDoc.html#SCI_GETBUFFEREDDRAW>

=cut

$autogen{SCI_GETBUFFEREDDRAW} = {
    subProto => 'getBufferedDraw() → bool',
    sciProto => 'SCI_GETBUFFEREDDRAW',
};

=item editor()->setBufferedDraw(buffered)

If drawing is buffered then each line of text is drawn into a bitmap buffer before drawing it to the screen to avoid flicker.

See Scintilla documentation for  L<SCI_SETBUFFEREDDRAW|https://www.scintilla.org/ScintillaDoc.html#SCI_SETBUFFEREDDRAW>

=cut

$autogen{SCI_SETBUFFEREDDRAW} = {
    subProto => 'setBufferedDraw(buffered)',
    sciProto => 'SCI_SETBUFFEREDDRAW',
};

=item editor()->SCI_SETPHASESDRAW

TODO

See Scintilla documentation for  L<SCI_SETPHASESDRAW|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPHASESDRAW>

=cut

$autogen{SCI_SETPHASESDRAW} = {
    subProto => 'SCI_SETPHASESDRAW',
    sciProto => 'SCI_SETPHASESDRAW',
};

=item editor()->SCI_GETPHASESDRAW

TODO

See Scintilla documentation for  L<SCI_GETPHASESDRAW|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPHASESDRAW>

=cut

$autogen{SCI_GETPHASESDRAW} = {
    subProto => 'SCI_GETPHASESDRAW',
    sciProto => 'SCI_GETPHASESDRAW',
};

=item editor()->setTechnology(technology)

Set the technology used.

See Scintilla documentation for  L<SCI_SETTECHNOLOGY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTECHNOLOGY>

=cut

$autogen{SCI_SETTECHNOLOGY} = {
    subProto => 'setTechnology(technology)',
    sciProto => 'SCI_SETTECHNOLOGY',
};

=item editor()->getTechnology() → int

Get the tech.

See Scintilla documentation for  L<SCI_GETTECHNOLOGY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTECHNOLOGY>

=cut

$autogen{SCI_GETTECHNOLOGY} = {
    subProto => 'getTechnology() → int',
    sciProto => 'SCI_GETTECHNOLOGY',
};

=item editor()->setFontQuality(fontQuality)

Choose the quality level for text from the FontQuality enumeration.

See Scintilla documentation for  L<SCI_SETFONTQUALITY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFONTQUALITY>

=cut

$autogen{SCI_SETFONTQUALITY} = {
    subProto => 'setFontQuality(fontQuality)',
    sciProto => 'SCI_SETFONTQUALITY',
};

=item editor()->getFontQuality() → int

Retrieve the quality level for text.

See Scintilla documentation for  L<SCI_GETFONTQUALITY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFONTQUALITY>

=cut

$autogen{SCI_GETFONTQUALITY} = {
    subProto => 'getFontQuality() → int',
    sciProto => 'SCI_GETFONTQUALITY',
};

=item editor()->setCodePage(codePage)

Set the code page used to interpret the bytes of the document as characters. The SC_CP_UTF8 value can be used to enter Unicode mode.

See Scintilla documentation for  L<SCI_SETCODEPAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCODEPAGE>

=cut

$autogen{SCI_SETCODEPAGE} = {
    subProto => 'setCodePage(codePage)',
    sciProto => 'SCI_SETCODEPAGE',
};

=item editor()->getCodePage() → int

Get the code page used to interpret the bytes of the document as characters.

See Scintilla documentation for  L<SCI_GETCODEPAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCODEPAGE>

=cut

$autogen{SCI_GETCODEPAGE} = {
    subProto => 'getCodePage() → int',
    sciProto => 'SCI_GETCODEPAGE',
};

=item editor()->SCI_SETIMEINTERACTION

TODO

See Scintilla documentation for  L<SCI_SETIMEINTERACTION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETIMEINTERACTION>

=cut

$autogen{SCI_SETIMEINTERACTION} = {
    subProto => 'SCI_SETIMEINTERACTION',
    sciProto => 'SCI_SETIMEINTERACTION',
};

=item editor()->SCI_GETIMEINTERACTION

TODO

See Scintilla documentation for  L<SCI_GETIMEINTERACTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETIMEINTERACTION>

=cut

$autogen{SCI_GETIMEINTERACTION} = {
    subProto => 'SCI_GETIMEINTERACTION',
    sciProto => 'SCI_GETIMEINTERACTION',
};

=item editor()->SCI_SETBIDIRECTIONAL

TODO

See Scintilla documentation for  L<SCI_SETBIDIRECTIONAL|https://www.scintilla.org/ScintillaDoc.html#SCI_SETBIDIRECTIONAL>

=cut

$autogen{SCI_SETBIDIRECTIONAL} = {
    subProto => 'SCI_SETMARGINBACKN',
    sciProto => 'SCI_SETBIDIRECTIONAL',
};

=item editor()->SCI_GETBIDIRECTIONAL

TODO

See Scintilla documentation for  L<SCI_GETBIDIRECTIONAL|https://www.scintilla.org/ScintillaDoc.html#SCI_GETBIDIRECTIONAL>

=cut

$autogen{SCI_GETBIDIRECTIONAL} = {
    subProto => 'SCI_GETBIDIRECTIONAL',
    sciProto => 'SCI_GETBIDIRECTIONAL',
};

=item editor()->grabFocus()

Set the focus to this Scintilla widget.

See Scintilla documentation for  L<SCI_GRABFOCUS|https://www.scintilla.org/ScintillaDoc.html#SCI_GRABFOCUS>

=cut

$autogen{SCI_GRABFOCUS} = {
    subProto => 'grabFocus()',
    sciProto => 'SCI_GRABFOCUS',
};

=item editor()->setFocus(focus)

Change internal focus flag.

See Scintilla documentation for  L<SCI_SETFOCUS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOCUS>

=cut

$autogen{SCI_SETFOCUS} = {
    subProto => 'setFocus(focus)',
    sciProto => 'SCI_SETFOCUS',
};

=item editor()->getFocus() → bool

Get internal focus flag.

See Scintilla documentation for  L<SCI_GETFOCUS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFOCUS>

=cut

$autogen{SCI_GETFOCUS} = {
    subProto => 'getFocus() → bool',
    sciProto => 'SCI_GETFOCUS',
};

=back

=head2 Brace highlighting

=begin scintilla

SCI_BRACEHIGHLIGHT(position posA, position posB)
SCI_BRACEBADLIGHT(position pos)
SCI_BRACEHIGHLIGHTINDICATOR(bool useSetting, int indicator)
SCI_BRACEBADLIGHTINDICATOR(bool useSetting, int indicator)
SCI_BRACEMATCH(position pos, int maxReStyle) → position

=end scintilla

=over

=item editor()->braceHighlight(pos1, pos2)

Highlight the characters at two positions.

See Scintilla documentation for  L<SCI_BRACEHIGHLIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_BRACEHIGHLIGHT>

=cut

$autogen{SCI_BRACEHIGHLIGHT} = {
    subProto => 'braceHighlight(pos1, pos2)',
    sciProto => 'SCI_BRACEHIGHLIGHT',
};

=item editor()->braceBadLight(pos)

Highlight the character at a position indicating there is no matching brace.

See Scintilla documentation for  L<SCI_BRACEBADLIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_BRACEBADLIGHT>

=cut

$autogen{SCI_BRACEBADLIGHT} = {
    subProto => 'braceBadLight(pos)',
    sciProto => 'SCI_BRACEBADLIGHT',
};

=item editor()->braceHighlightIndicator(useBraceHighlightIndicator, indicator)

Use specified indicator to highlight matching braces instead of changing their style.

See Scintilla documentation for  L<SCI_BRACEHIGHLIGHTINDICATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_BRACEHIGHLIGHTINDICATOR>

=cut

$autogen{SCI_BRACEHIGHLIGHTINDICATOR} = {
    subProto => 'braceHighlightIndicator(useBraceHighlightIndicator, indicator)',
    sciProto => 'SCI_BRACEHIGHLIGHTINDICATOR',
};

=item editor()->braceBadLightIndicator(useBraceBadLightIndicator, indicator)

Use specified indicator to highlight non matching brace instead of changing its style.

See Scintilla documentation for  L<SCI_BRACEBADLIGHTINDICATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_BRACEBADLIGHTINDICATOR>

=cut

$autogen{SCI_BRACEBADLIGHTINDICATOR} = {
    subProto => 'braceBadLightIndicator(useBraceBadLightIndicator, indicator)',
    sciProto => 'SCI_BRACEBADLIGHTINDICATOR',
};

=item editor()->braceMatch(pos) → int

Find the position of a matching brace or INVALID_POSITION if no match.

See Scintilla documentation for  L<SCI_BRACEMATCH|https://www.scintilla.org/ScintillaDoc.html#SCI_BRACEMATCH>

=cut

$autogen{SCI_BRACEMATCH} = {
    subProto => 'braceMatch(pos) → int',
    sciProto => 'SCI_BRACEMATCH',
};

=back

=head2 Tabs and Indentation Guides

=begin scintilla

SCI_SETTABWIDTH(int tabWidth)
SCI_GETTABWIDTH → int
SCI_CLEARTABSTOPS(line line)
SCI_ADDTABSTOP(line line, int x)
SCI_GETNEXTTABSTOP(line line, int x) → int
SCI_SETUSETABS(bool useTabs)
SCI_GETUSETABS → bool
SCI_SETINDENT(int indentSize)
SCI_GETINDENT → int
SCI_SETTABINDENTS(bool tabIndents)
SCI_GETTABINDENTS → bool
SCI_SETBACKSPACEUNINDENTS(bool bsUnIndents)
SCI_GETBACKSPACEUNINDENTS → bool
SCI_SETLINEINDENTATION(line line, int indentation)
SCI_GETLINEINDENTATION(line line) → int
SCI_GETLINEINDENTPOSITION(line line) → position
SCI_SETINDENTATIONGUIDES(int indentView)
SCI_GETINDENTATIONGUIDES → int
SCI_SETHIGHLIGHTGUIDE(position column)
SCI_GETHIGHLIGHTGUIDE → position

=end scintilla

=over

=item editor()->setTabWidth(tabWidth)

Change the visible size of a tab to be a multiple of the width of a space character.

See Scintilla documentation for  L<SCI_SETTABWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTABWIDTH>

=cut

$autogen{SCI_SETTABWIDTH} = {
    subProto => 'setTabWidth(tabWidth)',
    sciProto => 'SCI_SETTABWIDTH',
};

=item editor()->getTabWidth() → int

Retrieve the visible size of a tab.

See Scintilla documentation for  L<SCI_GETTABWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTABWIDTH>

=cut

$autogen{SCI_GETTABWIDTH} = {
    subProto => 'getTabWidth() → int',
    sciProto => 'SCI_GETTABWIDTH',
};

=item editor()->SCI_CLEARTABSTOPS

TODO

See Scintilla documentation for  L<SCI_CLEARTABSTOPS|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARTABSTOPS>

=cut

$autogen{SCI_CLEARTABSTOPS} = {
    subProto => 'SCI_CLEARTABSTOPS',
    sciProto => 'SCI_CLEARTABSTOPS',
};

=item editor()->SCI_ADDTABSTOP

TODO

See Scintilla documentation for  L<SCI_ADDTABSTOP|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDTABSTOP>

=cut

$autogen{SCI_ADDTABSTOP} = {
    subProto => 'SCI_ADDTABSTOP',
    sciProto => 'SCI_ADDTABSTOP',
};

=item editor()->SCI_GETNEXTTABSTOP

TODO

See Scintilla documentation for  L<SCI_GETNEXTTABSTOP|https://www.scintilla.org/ScintillaDoc.html#SCI_GETNEXTTABSTOP>

=cut

$autogen{SCI_GETNEXTTABSTOP} = {
    subProto => 'SCI_GETNEXTTABSTOP',
    sciProto => 'SCI_GETNEXTTABSTOP',
};

=item editor()->setUseTabs(useTabs)

Indentation will only use space characters if useTabs is false, otherwise it will use a combination of tabs and spaces.

See Scintilla documentation for  L<SCI_SETUSETABS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETUSETABS>

=cut

$autogen{SCI_SETUSETABS} = {
    subProto => 'setUseTabs(useTabs)',
    sciProto => 'SCI_SETUSETABS',
};

=item editor()->getUseTabs() → bool

Retrieve whether tabs will be used in indentation.

See Scintilla documentation for  L<SCI_GETUSETABS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETUSETABS>

=cut

$autogen{SCI_GETUSETABS} = {
    subProto => 'getUseTabs() → bool',
    sciProto => 'SCI_GETUSETABS',
};

=item editor()->setIndent(indentSize)

Set the number of spaces used for one level of indentation.

See Scintilla documentation for  L<SCI_SETINDENT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETINDENT>

=cut

$autogen{SCI_SETINDENT} = {
    subProto => 'setIndent(indentSize)',
    sciProto => 'SCI_SETINDENT',
};

=item editor()->getIndent() → int

Retrieve indentation size.

See Scintilla documentation for  L<SCI_GETINDENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETINDENT>

=cut

$autogen{SCI_GETINDENT} = {
    subProto => 'getIndent() → int',
    sciProto => 'SCI_GETINDENT',
};

=item editor()->setTabIndents(tabIndents)

Sets whether a tab pressed when caret is within indentation indents.

See Scintilla documentation for  L<SCI_SETTABINDENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETTABINDENTS>

=cut

$autogen{SCI_SETTABINDENTS} = {
    subProto => 'setTabIndents(tabIndents)',
    sciProto => 'SCI_SETTABINDENTS',
};

=item editor()->getTabIndents() → bool

Does a tab pressed when caret is within indentation indent?

See Scintilla documentation for  L<SCI_GETTABINDENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETTABINDENTS>

=cut

$autogen{SCI_GETTABINDENTS} = {
    subProto => 'getTabIndents() → bool',
    sciProto => 'SCI_GETTABINDENTS',
};

=item editor()->setBackSpaceUnIndents(bsUnIndents)

Sets whether a backspace pressed when caret is within indentation unindents.

See Scintilla documentation for  L<SCI_SETBACKSPACEUNINDENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETBACKSPACEUNINDENTS>

=cut

$autogen{SCI_SETBACKSPACEUNINDENTS} = {
    subProto => 'setBackSpaceUnIndents(bsUnIndents)',
    sciProto => 'SCI_SETBACKSPACEUNINDENTS',
};

=item editor()->getBackSpaceUnIndents() → bool

Does a backspace pressed when caret is within indentation unindent?

See Scintilla documentation for  L<SCI_GETBACKSPACEUNINDENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETBACKSPACEUNINDENTS>

=cut

$autogen{SCI_GETBACKSPACEUNINDENTS} = {
    subProto => 'getBackSpaceUnIndents() → bool',
    sciProto => 'SCI_GETBACKSPACEUNINDENTS',
};

=item editor()->setLineIndentation(line, indentSize)

Change the indentation of a line to a number of columns.

See Scintilla documentation for  L<SCI_SETLINEINDENTATION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLINEINDENTATION>

=cut

$autogen{SCI_SETLINEINDENTATION} = {
    subProto => 'setLineIndentation(line, indentSize)',
    sciProto => 'SCI_SETLINEINDENTATION',
};

=item editor()->getLineIndentation(line) → int

Retrieve the number of columns that a line is indented.

See Scintilla documentation for  L<SCI_GETLINEINDENTATION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEINDENTATION>

=cut

$autogen{SCI_GETLINEINDENTATION} = {
    subProto => 'getLineIndentation(line) → int',
    sciProto => 'SCI_GETLINEINDENTATION',
};

=item editor()->getLineIndentPosition(line) → int

Retrieve the position before the first non indentation character on a line.

See Scintilla documentation for  L<SCI_GETLINEINDENTPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEINDENTPOSITION>

=cut

$autogen{SCI_GETLINEINDENTPOSITION} = {
    subProto => 'getLineIndentPosition(line) → int',
    sciProto => 'SCI_GETLINEINDENTPOSITION',
};

=item editor()->setIndentationGuides(indentView)

Show or hide indentation guides.

See Scintilla documentation for  L<SCI_SETINDENTATIONGUIDES|https://www.scintilla.org/ScintillaDoc.html#SCI_SETINDENTATIONGUIDES>

=cut

$autogen{SCI_SETINDENTATIONGUIDES} = {
    subProto => 'setIndentationGuides(indentView)',
    sciProto => 'SCI_SETINDENTATIONGUIDES',
};

=item editor()->getIndentationGuides() → int

Are the indentation guides visible?

See Scintilla documentation for  L<SCI_GETINDENTATIONGUIDES|https://www.scintilla.org/ScintillaDoc.html#SCI_GETINDENTATIONGUIDES>

=cut

$autogen{SCI_GETINDENTATIONGUIDES} = {
    subProto => 'getIndentationGuides() → int',
    sciProto => 'SCI_GETINDENTATIONGUIDES',
};

=item editor()->setHighlightGuide(column)

Set the highlighted indentation guide column. 0 = no highlighted guide.

See Scintilla documentation for  L<SCI_SETHIGHLIGHTGUIDE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETHIGHLIGHTGUIDE>

=cut

$autogen{SCI_SETHIGHLIGHTGUIDE} = {
    subProto => 'setHighlightGuide(column)',
    sciProto => 'SCI_SETHIGHLIGHTGUIDE',
};

=item editor()->getHighlightGuide() → int

Get the highlighted indentation guide column.

See Scintilla documentation for  L<SCI_GETHIGHLIGHTGUIDE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETHIGHLIGHTGUIDE>

=cut

$autogen{SCI_GETHIGHLIGHTGUIDE} = {
    subProto => 'getHighlightGuide() → int',
    sciProto => 'SCI_GETHIGHLIGHTGUIDE',
};

=back

=head2 Markers

=begin scintilla

SCI_MARKERDEFINE(int markerNumber, int markerSymbol)
SCI_MARKERDEFINEPIXMAP(int markerNumber, const char *pixmap)
SCI_RGBAIMAGESETWIDTH(int width)
SCI_RGBAIMAGESETHEIGHT(int height)
SCI_RGBAIMAGESETSCALE(int scalePercent)
SCI_MARKERDEFINERGBAIMAGE(int markerNumber, const char *pixels)
SCI_MARKERSYMBOLDEFINED(int markerNumber) → int
SCI_MARKERSETFORE(int markerNumber, colour fore)
SCI_MARKERSETBACK(int markerNumber, colour back)
SCI_MARKERSETBACKSELECTED(int markerNumber, colour back)
SCI_MARKERENABLEHIGHLIGHT(bool enabled)
SCI_MARKERSETALPHA(int markerNumber, alpha alpha)
SCI_MARKERADD(line line, int markerNumber) → int
SCI_MARKERADDSET(line line, int markerSet)
SCI_MARKERDELETE(line line, int markerNumber)
SCI_MARKERDELETEALL(int markerNumber)
SCI_MARKERGET(line line) → int
SCI_MARKERNEXT(line lineStart, int markerMask) → line
SCI_MARKERPREVIOUS(line lineStart, int markerMask) → line
SCI_MARKERLINEFROMHANDLE(int markerHandle) → int
SCI_MARKERDELETEHANDLE(int markerHandle)

=end scintilla

=over

=item editor()->markerDefine(markerNumber, markerSymbol)

Set the symbol used for a particular marker number.

See Scintilla documentation for  L<SCI_MARKERDEFINE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDEFINE>

=cut

$autogen{SCI_MARKERDEFINE} = {
    subProto => 'markerDefine(markerNumber, markerSymbol)',
    sciProto => 'SCI_MARKERDEFINE',
};

=item editor()->markerDefinePixmap(markerNumber, pixmap)

Define a marker from a pixmap.

See Scintilla documentation for  L<SCI_MARKERDEFINEPIXMAP|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDEFINEPIXMAP>

=cut

$autogen{SCI_MARKERDEFINEPIXMAP} = {
    subProto => 'markerDefinePixmap(markerNumber, pixmap)',
    sciProto => 'SCI_MARKERDEFINEPIXMAP',
};

=item editor()->rGBAImageSetWidth(width)

Set the width for future RGBA image data.

See Scintilla documentation for  L<SCI_RGBAIMAGESETWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_RGBAIMAGESETWIDTH>

=cut

$autogen{SCI_RGBAIMAGESETWIDTH} = {
    subProto => 'rGBAImageSetWidth(width)',
    sciProto => 'SCI_RGBAIMAGESETWIDTH',
};

=item editor()->rGBAImageSetHeight(height)

Set the height for future RGBA image data.

See Scintilla documentation for  L<SCI_RGBAIMAGESETHEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_RGBAIMAGESETHEIGHT>

=cut

$autogen{SCI_RGBAIMAGESETHEIGHT} = {
    subProto => 'rGBAImageSetHeight(height)',
    sciProto => 'SCI_RGBAIMAGESETHEIGHT',
};

=item editor()->rGBAImageSetScale(scalePercent)

Set the scale factor in percent for future RGBA image data.

See Scintilla documentation for  L<SCI_RGBAIMAGESETSCALE|https://www.scintilla.org/ScintillaDoc.html#SCI_RGBAIMAGESETSCALE>

=cut

$autogen{SCI_RGBAIMAGESETSCALE} = {
    subProto => 'rGBAImageSetScale(scalePercent)',
    sciProto => 'SCI_RGBAIMAGESETSCALE',
};

=item editor()->markerDefineRGBAImage(markerNumber, pixels)

Define a marker from RGBA data. It has the width and height from RGBAImageSetWidth/Height

See Scintilla documentation for  L<SCI_MARKERDEFINERGBAIMAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDEFINERGBAIMAGE>

=cut

$autogen{SCI_MARKERDEFINERGBAIMAGE} = {
    subProto => 'markerDefineRGBAImage(markerNumber, pixels)',
    sciProto => 'SCI_MARKERDEFINERGBAIMAGE',
};

=item editor()->markerSymbolDefined(markerNumber) → int

Which symbol was defined for markerNumber with MarkerDefine

See Scintilla documentation for  L<SCI_MARKERSYMBOLDEFINED|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERSYMBOLDEFINED>

=cut

$autogen{SCI_MARKERSYMBOLDEFINED} = {
    subProto => 'markerSymbolDefined(markerNumber) → int',
    sciProto => 'SCI_MARKERSYMBOLDEFINED',
};

=item editor()->markerSetFore(markerNumber, fore)

Set the foreground colour used for a particular marker number.

See Scintilla documentation for  L<SCI_MARKERSETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERSETFORE>

=cut

$autogen{SCI_MARKERSETFORE} = {
    subProto => 'markerSetFore(markerNumber, fore)',
    sciProto => 'SCI_MARKERSETFORE',
};

=item editor()->markerSetBack(markerNumber, back)

Set the background colour used for a particular marker number.

See Scintilla documentation for  L<SCI_MARKERSETBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERSETBACK>

=cut

$autogen{SCI_MARKERSETBACK} = {
    subProto => 'markerSetBack(markerNumber, back)',
    sciProto => 'SCI_MARKERSETBACK',
};

=item editor()->markerSetBackSelected(markerNumber, back)

Set the background colour used for a particular marker number when its folding block is selected.

See Scintilla documentation for  L<SCI_MARKERSETBACKSELECTED|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERSETBACKSELECTED>

=cut

$autogen{SCI_MARKERSETBACKSELECTED} = {
    subProto => 'markerSetBackSelected(markerNumber, back)',
    sciProto => 'SCI_MARKERSETBACKSELECTED',
};

=item editor()->markerEnableHighlight(enabled)

Enable/disable highlight for current folding bloc (smallest one that contains the caret)

See Scintilla documentation for  L<SCI_MARKERENABLEHIGHLIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERENABLEHIGHLIGHT>

=cut

$autogen{SCI_MARKERENABLEHIGHLIGHT} = {
    subProto => 'markerEnableHighlight(enabled)',
    sciProto => 'SCI_MARKERENABLEHIGHLIGHT',
};

=item editor()->markerSetAlpha(markerNumber, alpha)

Set the alpha used for a marker that is drawn in the text area, not the margin.

See Scintilla documentation for  L<SCI_MARKERSETALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERSETALPHA>

=cut

$autogen{SCI_MARKERSETALPHA} = {
    subProto => 'markerSetAlpha(markerNumber, alpha)',
    sciProto => 'SCI_MARKERSETALPHA',
};

=item editor()->markerAdd(line, markerNumber) → int

Add a marker to a line, returning an ID which can be used to find or delete the marker.

See Scintilla documentation for  L<SCI_MARKERADD|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERADD>

=cut

$autogen{SCI_MARKERADD} = {
    subProto => 'markerAdd(line, markerNumber) → int',
    sciProto => 'SCI_MARKERADD',
};

=item editor()->markerAddSet(line, set)

Add a set of markers to a line.

See Scintilla documentation for  L<SCI_MARKERADDSET|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERADDSET>

=cut

$autogen{SCI_MARKERADDSET} = {
    subProto => 'markerAddSet(line, set)',
    sciProto => 'SCI_MARKERADDSET',
};

=item editor()->markerDelete(line, markerNumber)

Delete a marker from a line.

See Scintilla documentation for  L<SCI_MARKERDELETE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDELETE>

=cut

$autogen{SCI_MARKERDELETE} = {
    subProto => 'markerDelete(line, markerNumber)',
    sciProto => 'SCI_MARKERDELETE',
};

=item editor()->markerDeleteAll(markerNumber)

Delete all markers with a particular number from all lines.

See Scintilla documentation for  L<SCI_MARKERDELETEALL|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDELETEALL>

=cut

$autogen{SCI_MARKERDELETEALL} = {
    subProto => 'markerDeleteAll(markerNumber)',
    sciProto => 'SCI_MARKERDELETEALL',
};

=item editor()->markerGet(line) → int

Get a bit mask of all the markers set on a line.

See Scintilla documentation for  L<SCI_MARKERGET|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERGET>

=cut

$autogen{SCI_MARKERGET} = {
    subProto => 'markerGet(line) → int',
    sciProto => 'SCI_MARKERGET',
};

=item editor()->markerNext(lineStart, markerMask) → int

Find the next line at or after lineStart that includes a marker in mask. Return -1 when no more lines.

See Scintilla documentation for  L<SCI_MARKERNEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERNEXT>

=cut

$autogen{SCI_MARKERNEXT} = {
    subProto => 'markerNext(lineStart, markerMask) → int',
    sciProto => 'SCI_MARKERNEXT',
};

=item editor()->markerPrevious(lineStart, markerMask) → int

Find the previous line before lineStart that includes a marker in mask.

See Scintilla documentation for  L<SCI_MARKERPREVIOUS|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERPREVIOUS>

=cut

$autogen{SCI_MARKERPREVIOUS} = {
    subProto => 'markerPrevious(lineStart, markerMask) → int',
    sciProto => 'SCI_MARKERPREVIOUS',
};

=item editor()->markerLineFromHandle(handle) → int

Retrieve the line number at which a particular marker is located.

See Scintilla documentation for  L<SCI_MARKERLINEFROMHANDLE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERLINEFROMHANDLE>

=cut

$autogen{SCI_MARKERLINEFROMHANDLE} = {
    subProto => 'markerLineFromHandle(handle) → int',
    sciProto => 'SCI_MARKERLINEFROMHANDLE',
};

=item editor()->markerDeleteHandle(handle)

Delete a marker.

See Scintilla documentation for  L<SCI_MARKERDELETEHANDLE|https://www.scintilla.org/ScintillaDoc.html#SCI_MARKERDELETEHANDLE>

=cut

$autogen{SCI_MARKERDELETEHANDLE} = {
    subProto => 'markerDeleteHandle(handle)',
    sciProto => 'SCI_MARKERDELETEHANDLE',
};

=back

=head2 Indicators

=begin scintilla

SCI_INDICSETSTYLE(int indicator, int indicatorStyle)
SCI_INDICGETSTYLE(int indicator) → int
SCI_INDICSETFORE(int indicator, colour fore)
SCI_INDICGETFORE(int indicator) → colour
SCI_INDICSETALPHA(int indicator, alpha alpha)
SCI_INDICGETALPHA(int indicator) → int
SCI_INDICSETOUTLINEALPHA(int indicator, alpha alpha)
SCI_INDICGETOUTLINEALPHA(int indicator) → int
SCI_INDICSETUNDER(int indicator, bool under)
SCI_INDICGETUNDER(int indicator) → bool
SCI_INDICSETHOVERSTYLE(int indicator, int indicatorStyle)
SCI_INDICGETHOVERSTYLE(int indicator) → int
SCI_INDICSETHOVERFORE(int indicator, colour fore)
SCI_INDICGETHOVERFORE(int indicator) → colour
SCI_INDICSETFLAGS(int indicator, int flags)
SCI_INDICGETFLAGS(int indicator) → int

SCI_SETINDICATORCURRENT(int indicator)
SCI_GETINDICATORCURRENT → int
SCI_SETINDICATORVALUE(int value)
SCI_GETINDICATORVALUE → int
SCI_INDICATORFILLRANGE(position start, position lengthFill)
SCI_INDICATORCLEARRANGE(position start, position lengthClear)
SCI_INDICATORALLONFOR(position pos) → int
SCI_INDICATORVALUEAT(int indicator, position pos) → int
SCI_INDICATORSTART(int indicator, position pos) → int
SCI_INDICATOREND(int indicator, position pos) → int
SCI_FINDINDICATORSHOW(position start, position end)
SCI_FINDINDICATORFLASH(position start, position end)
SCI_FINDINDICATORHIDE

=end scintilla

=over

=item editor()->indicSetStyle(indic, style)

Set an indicator to plain, squiggle or TT.

See Scintilla documentation for  L<SCI_INDICSETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETSTYLE>

=cut

$autogen{SCI_INDICSETSTYLE} = {
    subProto => 'indicSetStyle(indic, style)',
    sciProto => 'SCI_INDICSETSTYLE',
};

=item editor()->indicGetStyle(indic) → int

Retrieve the style of an indicator.

See Scintilla documentation for  L<SCI_INDICGETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETSTYLE>

=cut

$autogen{SCI_INDICGETSTYLE} = {
    subProto => 'indicGetStyle(indic) → int',
    sciProto => 'SCI_INDICGETSTYLE',
};

=item editor()->indicSetFore(indic, fore)

Set the foreground colour of an indicator.

See Scintilla documentation for  L<SCI_INDICSETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETFORE>

=cut

$autogen{SCI_INDICSETFORE} = {
    subProto => 'indicSetFore(indic, fore)',
    sciProto => 'SCI_INDICSETFORE',
};

=item editor()->indicGetFore(indic) → tuple

Retrieve the foreground colour of an indicator.

See Scintilla documentation for  L<SCI_INDICGETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETFORE>

=cut

$autogen{SCI_INDICGETFORE} = {
    subProto => 'indicGetFore(indic) → tuple',
    sciProto => 'SCI_INDICGETFORE',
};

=item editor()->indicSetAlpha(indicator, alpha)

Set the alpha fill colour of the given indicator.

See Scintilla documentation for  L<SCI_INDICSETALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETALPHA>

=cut

$autogen{SCI_INDICSETALPHA} = {
    subProto => 'indicSetAlpha(indicator, alpha)',
    sciProto => 'SCI_INDICSETALPHA',
};

=item editor()->indicGetAlpha(indicator) → int

Get the alpha fill colour of the given indicator.

See Scintilla documentation for  L<SCI_INDICGETALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETALPHA>

=cut

$autogen{SCI_INDICGETALPHA} = {
    subProto => 'indicGetAlpha(indicator) → int',
    sciProto => 'SCI_INDICGETALPHA',
};

=item editor()->indicSetOutlineAlpha(indicator, alpha)

Set the alpha outline colour of the given indicator.

See Scintilla documentation for  L<SCI_INDICSETOUTLINEALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETOUTLINEALPHA>

=cut

$autogen{SCI_INDICSETOUTLINEALPHA} = {
    subProto => 'indicSetOutlineAlpha(indicator, alpha)',
    sciProto => 'SCI_INDICSETOUTLINEALPHA',
};

=item editor()->indicGetOutlineAlpha(indicator) → int

Get the alpha outline colour of the given indicator.

See Scintilla documentation for  L<SCI_INDICGETOUTLINEALPHA|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETOUTLINEALPHA>

=cut

$autogen{SCI_INDICGETOUTLINEALPHA} = {
    subProto => 'indicGetOutlineAlpha(indicator) → int',
    sciProto => 'SCI_INDICGETOUTLINEALPHA',
};

=item editor()->indicSetUnder(indic, under)

Set an indicator to draw under text or over(default).

See Scintilla documentation for  L<SCI_INDICSETUNDER|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETUNDER>

=cut

$autogen{SCI_INDICSETUNDER} = {
    subProto => 'indicSetUnder(indic, under)',
    sciProto => 'SCI_INDICSETUNDER',
};

=item editor()->indicGetUnder(indic) → bool

Retrieve whether indicator drawn under or over text.

See Scintilla documentation for  L<SCI_INDICGETUNDER|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETUNDER>

=cut

$autogen{SCI_INDICGETUNDER} = {
    subProto => 'indicGetUnder(indic) → bool',
    sciProto => 'SCI_INDICGETUNDER',
};

=item editor()->SCI_INDICSETHOVERSTYLE

TODO

See Scintilla documentation for  L<SCI_INDICSETHOVERSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETHOVERSTYLE>

=cut

$autogen{SCI_INDICSETHOVERSTYLE} = {
    subProto => 'SCI_INDICSETHOVERSTYLE',
    sciProto => 'SCI_INDICSETHOVERSTYLE',
};

=item editor()->SCI_INDICGETHOVERSTYLE

TODO

See Scintilla documentation for  L<SCI_INDICGETHOVERSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETHOVERSTYLE>

=cut

$autogen{SCI_INDICGETHOVERSTYLE} = {
    subProto => 'SCI_INDICGETHOVERSTYLE',
    sciProto => 'SCI_INDICGETHOVERSTYLE',
};

=item editor()->SCI_INDICSETHOVERFORE

TODO

See Scintilla documentation for  L<SCI_INDICSETHOVERFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETHOVERFORE>

=cut

$autogen{SCI_INDICSETHOVERFORE} = {
    subProto => 'SCI_INDICSETHOVERFORE',
    sciProto => 'SCI_INDICSETHOVERFORE',
};

=item editor()->SCI_INDICGETHOVERFORE

TODO

See Scintilla documentation for  L<SCI_INDICGETHOVERFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETHOVERFORE>

=cut

$autogen{SCI_INDICGETHOVERFORE} = {
    subProto => 'SCI_INDICGETHOVERFORE',
    sciProto => 'SCI_INDICGETHOVERFORE',
};

=item editor()->SCI_INDICSETFLAGS

TODO

See Scintilla documentation for  L<SCI_INDICSETFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICSETFLAGS>

=cut

$autogen{SCI_INDICSETFLAGS} = {
    subProto => 'SCI_INDICSETFLAGS',
    sciProto => 'SCI_INDICSETFLAGS',
};

=item editor()->SCI_INDICGETFLAGS

TODO

See Scintilla documentation for  L<SCI_INDICGETFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICGETFLAGS>

=cut

$autogen{SCI_INDICGETFLAGS} = {
    subProto => 'SCI_INDICGETFLAGS',
    sciProto => 'SCI_INDICGETFLAGS',
};

=item editor()->setIndicatorCurrent(indicator)

Set the indicator used for IndicatorFillRange and IndicatorClearRange

See Scintilla documentation for  L<SCI_SETINDICATORCURRENT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETINDICATORCURRENT>

=cut

$autogen{SCI_SETINDICATORCURRENT} = {
    subProto => 'setIndicatorCurrent(indicator)',
    sciProto => 'SCI_SETINDICATORCURRENT',
};

=item editor()->getIndicatorCurrent() → int

Get the current indicator

See Scintilla documentation for  L<SCI_GETINDICATORCURRENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETINDICATORCURRENT>

=cut

$autogen{SCI_GETINDICATORCURRENT} = {
    subProto => 'getIndicatorCurrent() → int',
    sciProto => 'SCI_GETINDICATORCURRENT',
};

=item editor()->setIndicatorValue(value)

Set the value used for IndicatorFillRange

See Scintilla documentation for  L<SCI_SETINDICATORVALUE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETINDICATORVALUE>

=cut

$autogen{SCI_SETINDICATORVALUE} = {
    subProto => 'setIndicatorValue(value)',
    sciProto => 'SCI_SETINDICATORVALUE',
};

=item editor()->getIndicatorValue() → int

Get the current indicator value

See Scintilla documentation for  L<SCI_GETINDICATORVALUE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETINDICATORVALUE>

=cut

$autogen{SCI_GETINDICATORVALUE} = {
    subProto => 'getIndicatorValue() → int',
    sciProto => 'SCI_GETINDICATORVALUE',
};

=item editor()->indicatorFillRange(position, fillLength)

Turn a indicator on over a range.

See Scintilla documentation for  L<SCI_INDICATORFILLRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATORFILLRANGE>

=cut

$autogen{SCI_INDICATORFILLRANGE} = {
    subProto => 'indicatorFillRange(position, fillLength)',
    sciProto => 'SCI_INDICATORFILLRANGE',
};

=item editor()->indicatorClearRange(position, clearLength)

Turn a indicator off over a range.

See Scintilla documentation for  L<SCI_INDICATORCLEARRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATORCLEARRANGE>

=cut

$autogen{SCI_INDICATORCLEARRANGE} = {
    subProto => 'indicatorClearRange(position, clearLength)',
    sciProto => 'SCI_INDICATORCLEARRANGE',
};

=item editor()->indicatorAllOnFor(position) → int

Are any indicators present at position?

See Scintilla documentation for  L<SCI_INDICATORALLONFOR|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATORALLONFOR>

=cut

$autogen{SCI_INDICATORALLONFOR} = {
    subProto => 'indicatorAllOnFor(position) → int',
    sciProto => 'SCI_INDICATORALLONFOR',
};

=item editor()->indicatorValueAt(indicator, position) → int

What value does a particular indicator have at at a position?

See Scintilla documentation for  L<SCI_INDICATORVALUEAT|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATORVALUEAT>

=cut

$autogen{SCI_INDICATORVALUEAT} = {
    subProto => 'indicatorValueAt(indicator, position) → int',
    sciProto => 'SCI_INDICATORVALUEAT',
};

=item editor()->indicatorStart(indicator, position) → int

Where does a particular indicator start?

See Scintilla documentation for  L<SCI_INDICATORSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATORSTART>

=cut

$autogen{SCI_INDICATORSTART} = {
    subProto => 'indicatorStart(indicator, position) → int',
    sciProto => 'SCI_INDICATORSTART',
};

=item editor()->indicatorEnd(indicator, position) → int

Where does a particular indicator end?

See Scintilla documentation for  L<SCI_INDICATOREND|https://www.scintilla.org/ScintillaDoc.html#SCI_INDICATOREND>

=cut

$autogen{SCI_INDICATOREND} = {
    subProto => 'indicatorEnd(indicator, position) → int',
    sciProto => 'SCI_INDICATOREND',
};

=item editor()->findIndicatorShow(start, end)

On OS X, show a find indicator.

See Scintilla documentation for  L<SCI_FINDINDICATORSHOW|https://www.scintilla.org/ScintillaDoc.html#SCI_FINDINDICATORSHOW>

=cut

$autogen{SCI_FINDINDICATORSHOW} = {
    subProto => 'findIndicatorShow(start, end)',
    sciProto => 'SCI_FINDINDICATORSHOW',
};

=item editor()->findIndicatorFlash(start, end)

On OS X, flash a find indicator, then fade out.

See Scintilla documentation for  L<SCI_FINDINDICATORFLASH|https://www.scintilla.org/ScintillaDoc.html#SCI_FINDINDICATORFLASH>

=cut

$autogen{SCI_FINDINDICATORFLASH} = {
    subProto => 'findIndicatorFlash(start, end)',
    sciProto => 'SCI_FINDINDICATORFLASH',
};

=item editor()->findIndicatorHide()

On OS X, hide the find indicator.

See Scintilla documentation for  L<SCI_FINDINDICATORHIDE|https://www.scintilla.org/ScintillaDoc.html#SCI_FINDINDICATORHIDE>

=cut

$autogen{SCI_FINDINDICATORHIDE} = {
    subProto => 'findIndicatorHide()',
    sciProto => 'SCI_FINDINDICATORHIDE',
};

=back

=head2 Autocompletion

=begin scintilla

SCI_AUTOCSHOW(position lengthEntered, const char *itemList)
SCI_AUTOCCANCEL
SCI_AUTOCACTIVE → bool
SCI_AUTOCPOSSTART → position
SCI_AUTOCCOMPLETE
SCI_AUTOCSTOPS(<unused>, const char *characterSet)
SCI_AUTOCSETSEPARATOR(int separatorCharacter)
SCI_AUTOCGETSEPARATOR → int
SCI_AUTOCSELECT(<unused>, const char *select)
SCI_AUTOCGETCURRENT → int
SCI_AUTOCGETCURRENTTEXT(<unused>, char *text) → int
SCI_AUTOCSETCANCELATSTART(bool cancel)
SCI_AUTOCGETCANCELATSTART → bool
SCI_AUTOCSETFILLUPS(<unused>, const char *characterSet)
SCI_AUTOCSETCHOOSESINGLE(bool chooseSingle)
SCI_AUTOCGETCHOOSESINGLE → bool
SCI_AUTOCSETIGNORECASE(bool ignoreCase)
SCI_AUTOCGETIGNORECASE → bool
SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR(int behaviour)
SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR → int
SCI_AUTOCSETMULTI(int multi)
SCI_AUTOCGETMULTI → int
SCI_AUTOCSETORDER(int order)
SCI_AUTOCGETORDER → int
SCI_AUTOCSETAUTOHIDE(bool autoHide)
SCI_AUTOCGETAUTOHIDE → bool
SCI_AUTOCSETDROPRESTOFWORD(bool dropRestOfWord)
SCI_AUTOCGETDROPRESTOFWORD → bool
SCI_REGISTERIMAGE(int type, const char *xpmData)
SCI_REGISTERRGBAIMAGE(int type, const char *pixels)
SCI_CLEARREGISTEREDIMAGES
SCI_AUTOCSETTYPESEPARATOR(int separatorCharacter)
SCI_AUTOCGETTYPESEPARATOR → int
SCI_AUTOCSETMAXHEIGHT(int rowCount)
SCI_AUTOCGETMAXHEIGHT → int
SCI_AUTOCSETMAXWIDTH(int characterCount)
SCI_AUTOCGETMAXWIDTH → int

=end scintilla

=over

=item editor()->autoCShow(lenEntered, itemList)

Display a auto-completion list. The lenEntered parameter indicates how many characters before the caret should be used to provide context.

See Scintilla documentation for  L<SCI_AUTOCSHOW|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSHOW>

=cut

$autogen{SCI_AUTOCSHOW} = {
    subProto => 'autoCShow(lenEntered, itemList)',
    sciProto => 'SCI_AUTOCSHOW',
};

=item editor()->autoCCancel()

Remove the auto-completion list from the screen.

See Scintilla documentation for  L<SCI_AUTOCCANCEL|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCCANCEL>

=cut

$autogen{SCI_AUTOCCANCEL} = {
    subProto => 'autoCCancel()',
    sciProto => 'SCI_AUTOCCANCEL',
};

=item editor()->autoCActive() → bool

Is there an auto-completion list visible?

See Scintilla documentation for  L<SCI_AUTOCACTIVE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCACTIVE>

=cut

$autogen{SCI_AUTOCACTIVE} = {
    subProto => 'autoCActive() → bool',
    sciProto => 'SCI_AUTOCACTIVE',
};

=item editor()->autoCPosStart() → int

Retrieve the position of the caret when the auto-completion list was displayed.

See Scintilla documentation for  L<SCI_AUTOCPOSSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCPOSSTART>

=cut

$autogen{SCI_AUTOCPOSSTART} = {
    subProto => 'autoCPosStart() → int',
    sciProto => 'SCI_AUTOCPOSSTART',
};

=item editor()->autoCComplete()

User has selected an item so remove the list and insert the selection.

See Scintilla documentation for  L<SCI_AUTOCCOMPLETE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCCOMPLETE>

=cut

$autogen{SCI_AUTOCCOMPLETE} = {
    subProto => 'autoCComplete()',
    sciProto => 'SCI_AUTOCCOMPLETE',
};

=item editor()->autoCStops(characterSet)

Define a set of character that when typed cancel the auto-completion list.

See Scintilla documentation for  L<SCI_AUTOCSTOPS|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSTOPS>

=cut

$autogen{SCI_AUTOCSTOPS} = {
    subProto => 'autoCStops(characterSet)',
    sciProto => 'SCI_AUTOCSTOPS',
};

=item editor()->autoCSetSeparator(separatorCharacter)

Change the separator character in the string setting up an auto-completion list. Default is space but can be changed if items contain space.

See Scintilla documentation for  L<SCI_AUTOCSETSEPARATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETSEPARATOR>

=cut

$autogen{SCI_AUTOCSETSEPARATOR} = {
    subProto => 'autoCSetSeparator(separatorCharacter)',
    sciProto => 'SCI_AUTOCSETSEPARATOR',
};

=item editor()->autoCGetSeparator() → int

Retrieve the auto-completion list separator character.

See Scintilla documentation for  L<SCI_AUTOCGETSEPARATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETSEPARATOR>

=cut

$autogen{SCI_AUTOCGETSEPARATOR} = {
    subProto => 'autoCGetSeparator() → int',
    sciProto => 'SCI_AUTOCGETSEPARATOR',
};

=item editor()->autoCSelect(text)

Select the item in the auto-completion list that starts with a string.

See Scintilla documentation for  L<SCI_AUTOCSELECT|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSELECT>

=cut

$autogen{SCI_AUTOCSELECT} = {
    subProto => 'autoCSelect(text)',
    sciProto => 'SCI_AUTOCSELECT',
};

=item editor()->autoCGetCurrent() → int

Get currently selected item position in the auto-completion list

See Scintilla documentation for  L<SCI_AUTOCGETCURRENT|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETCURRENT>

=cut

$autogen{SCI_AUTOCGETCURRENT} = {
    subProto => 'autoCGetCurrent() → int',
    sciProto => 'SCI_AUTOCGETCURRENT',
};

=item editor()->autoCGetCurrentText() → str

Get currently selected item text in the auto-completion list Returns the length of the item text

See Scintilla documentation for  L<SCI_AUTOCGETCURRENTTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETCURRENTTEXT>

=cut

$autogen{SCI_AUTOCGETCURRENTTEXT} = {
    subProto => 'autoCGetCurrentText() → str',
    sciProto => 'SCI_AUTOCGETCURRENTTEXT',
};

=item editor()->autoCSetCancelAtStart(cancel)

Should the auto-completion list be cancelled if the user backspaces to a position before where the box was created.

See Scintilla documentation for  L<SCI_AUTOCSETCANCELATSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETCANCELATSTART>

=cut

$autogen{SCI_AUTOCSETCANCELATSTART} = {
    subProto => 'autoCSetCancelAtStart(cancel)',
    sciProto => 'SCI_AUTOCSETCANCELATSTART',
};

=item editor()->autoCGetCancelAtStart() → bool

Retrieve whether auto-completion cancelled by backspacing before start.

See Scintilla documentation for  L<SCI_AUTOCGETCANCELATSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETCANCELATSTART>

=cut

$autogen{SCI_AUTOCGETCANCELATSTART} = {
    subProto => 'autoCGetCancelAtStart() → bool',
    sciProto => 'SCI_AUTOCGETCANCELATSTART',
};

=item editor()->autoCSetFillUps(characterSet)

Define a set of characters that when typed will cause the autocompletion to choose the selected item.

See Scintilla documentation for  L<SCI_AUTOCSETFILLUPS|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETFILLUPS>

=cut

$autogen{SCI_AUTOCSETFILLUPS} = {
    subProto => 'autoCSetFillUps(characterSet)',
    sciProto => 'SCI_AUTOCSETFILLUPS',
};

=item editor()->autoCSetChooseSingle(chooseSingle)

Should a single item auto-completion list automatically choose the item.

See Scintilla documentation for  L<SCI_AUTOCSETCHOOSESINGLE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETCHOOSESINGLE>

=cut

$autogen{SCI_AUTOCSETCHOOSESINGLE} = {
    subProto => 'autoCSetChooseSingle(chooseSingle)',
    sciProto => 'SCI_AUTOCSETCHOOSESINGLE',
};

=item editor()->autoCGetChooseSingle() → bool

Retrieve whether a single item auto-completion list automatically choose the item.

See Scintilla documentation for  L<SCI_AUTOCGETCHOOSESINGLE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETCHOOSESINGLE>

=cut

$autogen{SCI_AUTOCGETCHOOSESINGLE} = {
    subProto => 'autoCGetChooseSingle() → bool',
    sciProto => 'SCI_AUTOCGETCHOOSESINGLE',
};

=item editor()->autoCSetIgnoreCase(ignoreCase)

Set whether case is significant when performing auto-completion searches.

See Scintilla documentation for  L<SCI_AUTOCSETIGNORECASE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETIGNORECASE>

=cut

$autogen{SCI_AUTOCSETIGNORECASE} = {
    subProto => 'autoCSetIgnoreCase(ignoreCase)',
    sciProto => 'SCI_AUTOCSETIGNORECASE',
};

=item editor()->autoCGetIgnoreCase() → bool

Retrieve state of ignore case flag.

See Scintilla documentation for  L<SCI_AUTOCGETIGNORECASE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETIGNORECASE>

=cut

$autogen{SCI_AUTOCGETIGNORECASE} = {
    subProto => 'autoCGetIgnoreCase() → bool',
    sciProto => 'SCI_AUTOCGETIGNORECASE',
};

=item editor()->autoCSetCaseInsensitiveBehaviour(behaviour)

Set auto-completion case insensitive behaviour to either prefer case-sensitive matches or have no preference.

See Scintilla documentation for  L<SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR>

=cut

$autogen{SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR} = {
    subProto => 'autoCSetCaseInsensitiveBehaviour(behaviour)',
    sciProto => 'SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR',
};

=item editor()->autoCGetCaseInsensitiveBehaviour() → int

Get auto-completion case insensitive behaviour.

See Scintilla documentation for  L<SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR>

=cut

$autogen{SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR} = {
    subProto => 'autoCGetCaseInsensitiveBehaviour() → int',
    sciProto => 'SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR',
};

=item editor()->SCI_AUTOCSETMULTI

TODO

See Scintilla documentation for  L<SCI_AUTOCSETMULTI|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETMULTI>

=cut

$autogen{SCI_AUTOCSETMULTI} = {
    subProto => 'SCI_AUTOCSETMULTI',
    sciProto => 'SCI_AUTOCSETMULTI',
};

=item editor()->SCI_AUTOCGETMULTI

TODO

See Scintilla documentation for  L<SCI_AUTOCGETMULTI|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETMULTI>

=cut

$autogen{SCI_AUTOCGETMULTI} = {
    subProto => 'SCI_AUTOCGETMULTI',
    sciProto => 'SCI_AUTOCGETMULTI',
};

=item editor()->autoCSetOrder(order)

Set the way autocompletion lists are ordered.

See Scintilla documentation for  L<SCI_AUTOCSETORDER|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETORDER>

=cut

$autogen{SCI_AUTOCSETORDER} = {
    subProto => 'autoCSetOrder(order)',
    sciProto => 'SCI_AUTOCSETORDER',
};

=item editor()->autoCGetOrder() → int

Get the way autocompletion lists are ordered.

See Scintilla documentation for  L<SCI_AUTOCGETORDER|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETORDER>

=cut

$autogen{SCI_AUTOCGETORDER} = {
    subProto => 'autoCGetOrder() → int',
    sciProto => 'SCI_AUTOCGETORDER',
};

=item editor()->autoCSetAutoHide(autoHide)

Set whether or not autocompletion is hidden automatically when nothing matches.

See Scintilla documentation for  L<SCI_AUTOCSETAUTOHIDE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETAUTOHIDE>

=cut

$autogen{SCI_AUTOCSETAUTOHIDE} = {
    subProto => 'autoCSetAutoHide(autoHide)',
    sciProto => 'SCI_AUTOCSETAUTOHIDE',
};

=item editor()->autoCGetAutoHide() → bool

Retrieve whether or not autocompletion is hidden automatically when nothing matches.

See Scintilla documentation for  L<SCI_AUTOCGETAUTOHIDE|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETAUTOHIDE>

=cut

$autogen{SCI_AUTOCGETAUTOHIDE} = {
    subProto => 'autoCGetAutoHide() → bool',
    sciProto => 'SCI_AUTOCGETAUTOHIDE',
};

=item editor()->autoCSetDropRestOfWord(dropRestOfWord)

Set whether or not autocompletion deletes any word characters after the inserted text upon completion.

See Scintilla documentation for  L<SCI_AUTOCSETDROPRESTOFWORD|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETDROPRESTOFWORD>

=cut

$autogen{SCI_AUTOCSETDROPRESTOFWORD} = {
    subProto => 'autoCSetDropRestOfWord(dropRestOfWord)',
    sciProto => 'SCI_AUTOCSETDROPRESTOFWORD',
};

=item editor()->autoCGetDropRestOfWord() → bool

Retrieve whether or not autocompletion deletes any word characters after the inserted text upon completion.

See Scintilla documentation for  L<SCI_AUTOCGETDROPRESTOFWORD|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETDROPRESTOFWORD>

=cut

$autogen{SCI_AUTOCGETDROPRESTOFWORD} = {
    subProto => 'autoCGetDropRestOfWord() → bool',
    sciProto => 'SCI_AUTOCGETDROPRESTOFWORD',
};

=item editor()->registerImage(type, xpmData)

Register an XPM image for use in autocompletion lists.

See Scintilla documentation for  L<SCI_REGISTERIMAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_REGISTERIMAGE>

=cut

$autogen{SCI_REGISTERIMAGE} = {
    subProto => 'registerImage(type, xpmData)',
    sciProto => 'SCI_REGISTERIMAGE',
};

=item editor()->registerRGBAImage(type, pixels)

Register an RGBA image for use in autocompletion lists. It has the width and height from RGBAImageSetWidth/Height

See Scintilla documentation for  L<SCI_REGISTERRGBAIMAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_REGISTERRGBAIMAGE>

=cut

$autogen{SCI_REGISTERRGBAIMAGE} = {
    subProto => 'registerRGBAImage(type, pixels)',
    sciProto => 'SCI_REGISTERRGBAIMAGE',
};

=item editor()->clearRegisteredImages()

Clear all the registered XPM images.

See Scintilla documentation for  L<SCI_CLEARREGISTEREDIMAGES|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARREGISTEREDIMAGES>

=cut

$autogen{SCI_CLEARREGISTEREDIMAGES} = {
    subProto => 'clearRegisteredImages()',
    sciProto => 'SCI_CLEARREGISTEREDIMAGES',
};

=item editor()->autoCGetTypeSeparator() → int

Retrieve the auto-completion list type-separator character.

See Scintilla documentation for  L<SCI_AUTOCGETTYPESEPARATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETTYPESEPARATOR>

=cut

$autogen{SCI_AUTOCGETTYPESEPARATOR} = {
    subProto => 'autoCGetTypeSeparator() → int',
    sciProto => 'SCI_AUTOCGETTYPESEPARATOR',
};

=item editor()->autoCSetTypeSeparator(separatorCharacter)

Change the type-separator character in the string setting up an auto-completion list. Default is ‘?’ but can be changed if items contain ‘?’.

See Scintilla documentation for  L<SCI_AUTOCSETTYPESEPARATOR|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETTYPESEPARATOR>

=cut

$autogen{SCI_AUTOCSETTYPESEPARATOR} = {
    subProto => 'autoCSetTypeSeparator(separatorCharacter)',
    sciProto => 'SCI_AUTOCSETTYPESEPARATOR',
};

=item editor()->autoCSetMaxHeight(rowCount)

Set the maximum height, in rows, of auto-completion and user lists. The default is 5 rows.

See Scintilla documentation for  L<SCI_AUTOCSETMAXHEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETMAXHEIGHT>

=cut

$autogen{SCI_AUTOCSETMAXHEIGHT} = {
    subProto => 'autoCSetMaxHeight(rowCount)',
    sciProto => 'SCI_AUTOCSETMAXHEIGHT',
};

=item editor()->autoCGetMaxHeight() → int

Set the maximum height, in rows, of auto-completion and user lists.

See Scintilla documentation for  L<SCI_AUTOCGETMAXHEIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETMAXHEIGHT>

=cut

$autogen{SCI_AUTOCGETMAXHEIGHT} = {
    subProto => 'autoCGetMaxHeight() → int',
    sciProto => 'SCI_AUTOCGETMAXHEIGHT',
};

=item editor()->autoCSetMaxWidth(characterCount)

Set the maximum width, in characters, of auto-completion and user lists. Set to 0 to autosize to fit longest item, which is the default.

See Scintilla documentation for  L<SCI_AUTOCSETMAXWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCSETMAXWIDTH>

=cut

$autogen{SCI_AUTOCSETMAXWIDTH} = {
    subProto => 'autoCSetMaxWidth(characterCount)',
    sciProto => 'SCI_AUTOCSETMAXWIDTH',
};

=item editor()->autoCGetMaxWidth() → int

Get the maximum width, in characters, of auto-completion and user lists.

See Scintilla documentation for  L<SCI_AUTOCGETMAXWIDTH|https://www.scintilla.org/ScintillaDoc.html#SCI_AUTOCGETMAXWIDTH>

=cut

$autogen{SCI_AUTOCGETMAXWIDTH} = {
    subProto => 'autoCGetMaxWidth() → int',
    sciProto => 'SCI_AUTOCGETMAXWIDTH',
};

=back

=head2 User lists

=begin scintilla

SCI_USERLISTSHOW(int listType, const char *itemList)

=end scintilla

=over

=item editor()->userListShow(listType, itemList)

Display a list of strings and send notification when user chooses one.

See Scintilla documentation for  L<SCI_USERLISTSHOW|https://www.scintilla.org/ScintillaDoc.html#SCI_USERLISTSHOW>

=cut

$autogen{SCI_USERLISTSHOW} = {
    subProto => 'userListShow(listType, itemList)',
    sciProto => 'SCI_USERLISTSHOW',
};

=back

=head2 Call tips

=begin scintilla

SCI_CALLTIPSHOW(position pos, const char *definition)
SCI_CALLTIPCANCEL
SCI_CALLTIPACTIVE → bool
SCI_CALLTIPPOSSTART → position
SCI_CALLTIPSETPOSSTART(position posStart)
SCI_CALLTIPSETHLT(int highlightStart, int highlightEnd)
SCI_CALLTIPSETBACK(colour back)
SCI_CALLTIPSETFORE(colour fore)
SCI_CALLTIPSETFOREHLT(colour fore)
SCI_CALLTIPUSESTYLE(int tabSize)
SCI_CALLTIPSETPOSITION(bool above)

=end scintilla

=over

=item editor()->callTipShow(pos, definition)

Show a call tip containing a definition near position pos.

See Scintilla documentation for  L<SCI_CALLTIPSHOW|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSHOW>

=cut

$autogen{SCI_CALLTIPSHOW} = {
    subProto => 'callTipShow(pos, definition)',
    sciProto => 'SCI_CALLTIPSHOW',
};

=item editor()->callTipCancel()

Remove the call tip from the screen.

See Scintilla documentation for  L<SCI_CALLTIPCANCEL|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPCANCEL>

=cut

$autogen{SCI_CALLTIPCANCEL} = {
    subProto => 'callTipCancel()',
    sciProto => 'SCI_CALLTIPCANCEL',
};

=item editor()->callTipActive() → bool

Is there an active call tip?

See Scintilla documentation for  L<SCI_CALLTIPACTIVE|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPACTIVE>

=cut

$autogen{SCI_CALLTIPACTIVE} = {
    subProto => 'callTipActive() → bool',
    sciProto => 'SCI_CALLTIPACTIVE',
};

=item editor()->callTipPosStart() → int

Retrieve the position where the caret was before displaying the call tip.

See Scintilla documentation for  L<SCI_CALLTIPPOSSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPPOSSTART>

=cut

$autogen{SCI_CALLTIPPOSSTART} = {
    subProto => 'callTipPosStart() → int',
    sciProto => 'SCI_CALLTIPPOSSTART',
};

=item editor()->callTipSetPosStart(posStart)

Set the start position in order to change when backspacing removes the calltip.

See Scintilla documentation for  L<SCI_CALLTIPSETPOSSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETPOSSTART>

=cut

$autogen{SCI_CALLTIPSETPOSSTART} = {
    subProto => 'callTipSetPosStart(posStart)',
    sciProto => 'SCI_CALLTIPSETPOSSTART',
};

=item editor()->callTipSetHlt(start, end)

Highlight a segment of the definition.

See Scintilla documentation for  L<SCI_CALLTIPSETHLT|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETHLT>

=cut

$autogen{SCI_CALLTIPSETHLT} = {
    subProto => 'callTipSetHlt(start, end)',
    sciProto => 'SCI_CALLTIPSETHLT',
};

=item editor()->callTipSetBack(back)

Set the background colour for the call tip.

See Scintilla documentation for  L<SCI_CALLTIPSETBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETBACK>

=cut

$autogen{SCI_CALLTIPSETBACK} = {
    subProto => 'callTipSetBack(back)',
    sciProto => 'SCI_CALLTIPSETBACK',
};

=item editor()->callTipSetFore(fore)

Set the foreground colour for the call tip.

See Scintilla documentation for  L<SCI_CALLTIPSETFORE|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETFORE>

=cut

$autogen{SCI_CALLTIPSETFORE} = {
    subProto => 'callTipSetFore(fore)',
    sciProto => 'SCI_CALLTIPSETFORE',
};

=item editor()->callTipSetForeHlt(fore)

Set the foreground colour for the highlighted part of the call tip.

See Scintilla documentation for  L<SCI_CALLTIPSETFOREHLT|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETFOREHLT>

=cut

$autogen{SCI_CALLTIPSETFOREHLT} = {
    subProto => 'callTipSetForeHlt(fore)',
    sciProto => 'SCI_CALLTIPSETFOREHLT',
};

=item editor()->callTipUseStyle(tabSize)

Enable use of STYLE_CALLTIP and set call tip tab size in pixels.

See Scintilla documentation for  L<SCI_CALLTIPUSESTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPUSESTYLE>

=cut

$autogen{SCI_CALLTIPUSESTYLE} = {
    subProto => 'callTipUseStyle(tabSize)',
    sciProto => 'SCI_CALLTIPUSESTYLE',
};

=item editor()->callTipSetPosition(above)

Set position of calltip, above or below text.

See Scintilla documentation for  L<SCI_CALLTIPSETPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_CALLTIPSETPOSITION>

=cut

$autogen{SCI_CALLTIPSETPOSITION} = {
    subProto => 'callTipSetPosition(above)',
    sciProto => 'SCI_CALLTIPSETPOSITION',
};

=back

=head2 Keyboard commands

=begin scintilla


SCI_LINEDOWN
SCI_LINEDOWNEXTEND
SCI_LINEDOWNRECTEXTEND
SCI_LINESCROLLDOWN
SCI_LINEUP
SCI_LINEUPEXTEND
SCI_LINEUPRECTEXTEND
SCI_LINESCROLLUP
SCI_PARADOWN
SCI_PARADOWNEXTEND
SCI_PARAUP
SCI_PARAUPEXTEND
SCI_CHARLEFT
SCI_CHARLEFTEXTEND
SCI_CHARLEFTRECTEXTEND
SCI_CHARRIGHT
SCI_CHARRIGHTEXTEND
SCI_CHARRIGHTRECTEXTEND
SCI_WORDLEFT
SCI_WORDLEFTEXTEND
SCI_WORDRIGHT
SCI_WORDRIGHTEXTEND
SCI_WORDLEFTEND
SCI_WORDLEFTENDEXTEND
SCI_WORDRIGHTEND
SCI_WORDRIGHTENDEXTEND
SCI_WORDPARTLEFT
SCI_WORDPARTLEFTEXTEND
SCI_WORDPARTRIGHT
SCI_WORDPARTRIGHTEXTEND
SCI_HOME
SCI_HOMEEXTEND
SCI_HOMERECTEXTEND
SCI_HOMEDISPLAY
SCI_HOMEDISPLAYEXTEND
SCI_HOMEWRAP
SCI_HOMEWRAPEXTEND
SCI_VCHOME
SCI_VCHOMEEXTEND
SCI_VCHOMERECTEXTEND
SCI_VCHOMEWRAP
SCI_VCHOMEWRAPEXTEND
SCI_VCHOMEDISPLAY
SCI_VCHOMEDISPLAYEXTEND
SCI_LINEEND
SCI_LINEENDEXTEND
SCI_LINEENDRECTEXTEND
SCI_LINEENDDISPLAY
SCI_LINEENDDISPLAYEXTEND
SCI_LINEENDWRAP
SCI_LINEENDWRAPEXTEND
SCI_DOCUMENTSTART
SCI_DOCUMENTSTARTEXTEND
SCI_DOCUMENTEND
SCI_DOCUMENTENDEXTEND
SCI_PAGEUP
SCI_PAGEUPEXTEND
SCI_PAGEUPRECTEXTEND
SCI_PAGEDOWN
SCI_PAGEDOWNEXTEND
SCI_PAGEDOWNRECTEXTEND
SCI_STUTTEREDPAGEUP
SCI_STUTTEREDPAGEUPEXTEND
SCI_STUTTEREDPAGEDOWN
SCI_STUTTEREDPAGEDOWNEXTEND
SCI_DELETEBACK
SCI_DELETEBACKNOTLINE
SCI_DELWORDLEFT
SCI_DELWORDRIGHT
SCI_DELWORDRIGHTEND
SCI_DELLINELEFT
SCI_DELLINERIGHT
SCI_LINEDELETE
SCI_LINECUT
SCI_LINECOPY
SCI_LINETRANSPOSE
SCI_LINEREVERSE
SCI_LINEDUPLICATE
SCI_LOWERCASE
SCI_UPPERCASE
SCI_CANCEL
SCI_EDITTOGGLEOVERTYPE
SCI_NEWLINE
SCI_FORMFEED
SCI_TAB
SCI_BACKTAB
SCI_SELECTIONDUPLICATE
SCI_VERTICALCENTRECARET
SCI_MOVESELECTEDLINESUP
SCI_MOVESELECTEDLINESDOWN
SCI_SCROLLTOSTART
SCI_SCROLLTOEND

=end scintilla

=over

=item editor()->lineDown()

Move caret down one line.

See Scintilla documentation for  L<SCI_LINEDOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEDOWN>

=cut

$autogen{SCI_LINEDOWN} = {
    subProto => 'lineDown()',
    sciProto => 'SCI_LINEDOWN',
};

=item editor()->lineDownExtend()

Move caret down one line extending selection to new caret position.

See Scintilla documentation for  L<SCI_LINEDOWNEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEDOWNEXTEND>

=cut

$autogen{SCI_LINEDOWNEXTEND} = {
    subProto => 'lineDownExtend()',
    sciProto => 'SCI_LINEDOWNEXTEND',
};

=item editor()->lineUp()

Move caret up one line.

See Scintilla documentation for  L<SCI_LINEUP|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEUP>

=cut

$autogen{SCI_LINEUP} = {
    subProto => 'lineUp()',
    sciProto => 'SCI_LINEUP',
};

=item editor()->lineUpExtend()

Move caret up one line extending selection to new caret position.

See Scintilla documentation for  L<SCI_LINEUPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEUPEXTEND>

=cut

$autogen{SCI_LINEUPEXTEND} = {
    subProto => 'lineUpExtend()',
    sciProto => 'SCI_LINEUPEXTEND',
};

=item editor()->charLeft()

Move caret left one character.

See Scintilla documentation for  L<SCI_CHARLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARLEFT>

=cut

$autogen{SCI_CHARLEFT} = {
    subProto => 'charLeft()',
    sciProto => 'SCI_CHARLEFT',
};

=item editor()->charLeftExtend()

Move caret left one character extending selection to new caret position.

See Scintilla documentation for  L<SCI_CHARLEFTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARLEFTEXTEND>

=cut

$autogen{SCI_CHARLEFTEXTEND} = {
    subProto => 'charLeftExtend()',
    sciProto => 'SCI_CHARLEFTEXTEND',
};

=item editor()->charRight()

Move caret right one character.

See Scintilla documentation for  L<SCI_CHARRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARRIGHT>

=cut

$autogen{SCI_CHARRIGHT} = {
    subProto => 'charRight()',
    sciProto => 'SCI_CHARRIGHT',
};

=item editor()->charRightExtend()

Move caret right one character extending selection to new caret position.

See Scintilla documentation for  L<SCI_CHARRIGHTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARRIGHTEXTEND>

=cut

$autogen{SCI_CHARRIGHTEXTEND} = {
    subProto => 'charRightExtend()',
    sciProto => 'SCI_CHARRIGHTEXTEND',
};

=item editor()->wordLeft()

Move caret left one word.

See Scintilla documentation for  L<SCI_WORDLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDLEFT>

=cut

$autogen{SCI_WORDLEFT} = {
    subProto => 'wordLeft()',
    sciProto => 'SCI_WORDLEFT',
};

=item editor()->wordLeftExtend()

Move caret left one word extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDLEFTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDLEFTEXTEND>

=cut

$autogen{SCI_WORDLEFTEXTEND} = {
    subProto => 'wordLeftExtend()',
    sciProto => 'SCI_WORDLEFTEXTEND',
};

=item editor()->wordRight()

Move caret right one word.

See Scintilla documentation for  L<SCI_WORDRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDRIGHT>

=cut

$autogen{SCI_WORDRIGHT} = {
    subProto => 'wordRight()',
    sciProto => 'SCI_WORDRIGHT',
};

=item editor()->wordRightExtend()

Move caret right one word extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDRIGHTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDRIGHTEXTEND>

=cut

$autogen{SCI_WORDRIGHTEXTEND} = {
    subProto => 'wordRightExtend()',
    sciProto => 'SCI_WORDRIGHTEXTEND',
};

=item editor()->home()

Move caret to first position on line.

See Scintilla documentation for  L<SCI_HOME|https://www.scintilla.org/ScintillaDoc.html#SCI_HOME>

=cut

$autogen{SCI_HOME} = {
    subProto => 'home()',
    sciProto => 'SCI_HOME',
};

=item editor()->homeExtend()

Move caret to first position on line extending selection to new caret position.

See Scintilla documentation for  L<SCI_HOMEEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMEEXTEND>

=cut

$autogen{SCI_HOMEEXTEND} = {
    subProto => 'homeExtend()',
    sciProto => 'SCI_HOMEEXTEND',
};

=item editor()->lineEnd()

Move caret to last position on line.

See Scintilla documentation for  L<SCI_LINEEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEEND>

=cut

$autogen{SCI_LINEEND} = {
    subProto => 'lineEnd()',
    sciProto => 'SCI_LINEEND',
};

=item editor()->lineEndExtend()

Move caret to last position on line extending selection to new caret position.

See Scintilla documentation for  L<SCI_LINEENDEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDEXTEND>

=cut

$autogen{SCI_LINEENDEXTEND} = {
    subProto => 'lineEndExtend()',
    sciProto => 'SCI_LINEENDEXTEND',
};

=item editor()->documentStart()

Move caret to first position in document.

See Scintilla documentation for  L<SCI_DOCUMENTSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_DOCUMENTSTART>

=cut

$autogen{SCI_DOCUMENTSTART} = {
    subProto => 'documentStart()',
    sciProto => 'SCI_DOCUMENTSTART',
};

=item editor()->documentStartExtend()

Move caret to first position in document extending selection to new caret position.

See Scintilla documentation for  L<SCI_DOCUMENTSTARTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_DOCUMENTSTARTEXTEND>

=cut

$autogen{SCI_DOCUMENTSTARTEXTEND} = {
    subProto => 'documentStartExtend()',
    sciProto => 'SCI_DOCUMENTSTARTEXTEND',
};

=item editor()->documentEnd()

Move caret to last position in document.

See Scintilla documentation for  L<SCI_DOCUMENTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_DOCUMENTEND>

=cut

$autogen{SCI_DOCUMENTEND} = {
    subProto => 'documentEnd()',
    sciProto => 'SCI_DOCUMENTEND',
};

=item editor()->documentEndExtend()

Move caret to last position in document extending selection to new caret position.

See Scintilla documentation for  L<SCI_DOCUMENTENDEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_DOCUMENTENDEXTEND>

=cut

$autogen{SCI_DOCUMENTENDEXTEND} = {
    subProto => 'documentEndExtend()',
    sciProto => 'SCI_DOCUMENTENDEXTEND',
};

=item editor()->pageUp()

Move caret one page up.

See Scintilla documentation for  L<SCI_PAGEUP|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEUP>

=cut

$autogen{SCI_PAGEUP} = {
    subProto => 'pageUp()',
    sciProto => 'SCI_PAGEUP',
};

=item editor()->pageUpExtend()

Move caret one page up extending selection to new caret position.

See Scintilla documentation for  L<SCI_PAGEUPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEUPEXTEND>

=cut

$autogen{SCI_PAGEUPEXTEND} = {
    subProto => 'pageUpExtend()',
    sciProto => 'SCI_PAGEUPEXTEND',
};

=item editor()->pageDown()

Move caret one page down.

See Scintilla documentation for  L<SCI_PAGEDOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEDOWN>

=cut

$autogen{SCI_PAGEDOWN} = {
    subProto => 'pageDown()',
    sciProto => 'SCI_PAGEDOWN',
};

=item editor()->pageDownExtend()

Move caret one page down extending selection to new caret position.

See Scintilla documentation for  L<SCI_PAGEDOWNEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEDOWNEXTEND>

=cut

$autogen{SCI_PAGEDOWNEXTEND} = {
    subProto => 'pageDownExtend()',
    sciProto => 'SCI_PAGEDOWNEXTEND',
};

=item editor()->editToggleOvertype()

Switch from insert to overtype mode or the reverse.

See Scintilla documentation for  L<SCI_EDITTOGGLEOVERTYPE|https://www.scintilla.org/ScintillaDoc.html#SCI_EDITTOGGLEOVERTYPE>

=cut

$autogen{SCI_EDITTOGGLEOVERTYPE} = {
    subProto => 'editToggleOvertype()',
    sciProto => 'SCI_EDITTOGGLEOVERTYPE',
};

=item editor()->cancel()

Cancel any modes such as call tip or auto-completion list display.

See Scintilla documentation for  L<SCI_CANCEL|https://www.scintilla.org/ScintillaDoc.html#SCI_CANCEL>

=cut

$autogen{SCI_CANCEL} = {
    subProto => 'cancel()',
    sciProto => 'SCI_CANCEL',
};

=item editor()->deleteBack()

Delete the selection or if no selection, the character before the caret.

See Scintilla documentation for  L<SCI_DELETEBACK|https://www.scintilla.org/ScintillaDoc.html#SCI_DELETEBACK>

=cut

$autogen{SCI_DELETEBACK} = {
    subProto => 'deleteBack()',
    sciProto => 'SCI_DELETEBACK',
};

=item editor()->tab()

If selection is empty or all on one line replace the selection with a tab character. If more than one line selected, indent the lines.

See Scintilla documentation for  L<SCI_TAB|https://www.scintilla.org/ScintillaDoc.html#SCI_TAB>

=cut

$autogen{SCI_TAB} = {
    subProto => 'tab()',
    sciProto => 'SCI_TAB',
};

=item editor()->backTab()

Dedent the selected lines.

See Scintilla documentation for  L<SCI_BACKTAB|https://www.scintilla.org/ScintillaDoc.html#SCI_BACKTAB>

=cut

$autogen{SCI_BACKTAB} = {
    subProto => 'backTab()',
    sciProto => 'SCI_BACKTAB',
};

=item editor()->newLine()

Insert a new line, may use a CRLF, CR or LF depending on EOL mode.

See Scintilla documentation for  L<SCI_NEWLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_NEWLINE>

=cut

$autogen{SCI_NEWLINE} = {
    subProto => 'newLine()',
    sciProto => 'SCI_NEWLINE',
};

=item editor()->formFeed()

Insert a Form Feed character.

See Scintilla documentation for  L<SCI_FORMFEED|https://www.scintilla.org/ScintillaDoc.html#SCI_FORMFEED>

=cut

$autogen{SCI_FORMFEED} = {
    subProto => 'formFeed()',
    sciProto => 'SCI_FORMFEED',
};

=item editor()->vCHome()

Move caret to before first visible character on line. If already there move to first character on line.

See Scintilla documentation for  L<SCI_VCHOME|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOME>

=cut

$autogen{SCI_VCHOME} = {
    subProto => 'vCHome()',
    sciProto => 'SCI_VCHOME',
};

=item editor()->vCHomeExtend()

Like VCHome but extending selection to new caret position.

See Scintilla documentation for  L<SCI_VCHOMEEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMEEXTEND>

=cut

$autogen{SCI_VCHOMEEXTEND} = {
    subProto => 'vCHomeExtend()',
    sciProto => 'SCI_VCHOMEEXTEND',
};

=item editor()->delWordLeft()

Delete the word to the left of the caret.

See Scintilla documentation for  L<SCI_DELWORDLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_DELWORDLEFT>

=cut

$autogen{SCI_DELWORDLEFT} = {
    subProto => 'delWordLeft()',
    sciProto => 'SCI_DELWORDLEFT',
};

=item editor()->delWordRight()

Delete the word to the right of the caret.

See Scintilla documentation for  L<SCI_DELWORDRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_DELWORDRIGHT>

=cut

$autogen{SCI_DELWORDRIGHT} = {
    subProto => 'delWordRight()',
    sciProto => 'SCI_DELWORDRIGHT',
};

=item editor()->delWordRightEnd()

Delete the word to the right of the caret, but not the trailing non-word characters.

See Scintilla documentation for  L<SCI_DELWORDRIGHTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_DELWORDRIGHTEND>

=cut

$autogen{SCI_DELWORDRIGHTEND} = {
    subProto => 'delWordRightEnd()',
    sciProto => 'SCI_DELWORDRIGHTEND',
};

=item editor()->lineCut()

Cut the line containing the caret.

See Scintilla documentation for  L<SCI_LINECUT|https://www.scintilla.org/ScintillaDoc.html#SCI_LINECUT>

=cut

$autogen{SCI_LINECUT} = {
    subProto => 'lineCut()',
    sciProto => 'SCI_LINECUT',
};

=item editor()->lineDelete()

Delete the line containing the caret.

See Scintilla documentation for  L<SCI_LINEDELETE|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEDELETE>

=cut

$autogen{SCI_LINEDELETE} = {
    subProto => 'lineDelete()',
    sciProto => 'SCI_LINEDELETE',
};

=item editor()->lineTranspose()

Switch the current line with the previous.

See Scintilla documentation for  L<SCI_LINETRANSPOSE|https://www.scintilla.org/ScintillaDoc.html#SCI_LINETRANSPOSE>

=cut

$autogen{SCI_LINETRANSPOSE} = {
    subProto => 'lineTranspose()',
    sciProto => 'SCI_LINETRANSPOSE',
};

=item editor()->lineDuplicate()

Duplicate the current line.

See Scintilla documentation for  L<SCI_LINEDUPLICATE|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEDUPLICATE>

=cut

$autogen{SCI_LINEDUPLICATE} = {
    subProto => 'lineDuplicate()',
    sciProto => 'SCI_LINEDUPLICATE',
};

=item editor()->lowerCase()

Transform the selection to lower case.

See Scintilla documentation for  L<SCI_LOWERCASE|https://www.scintilla.org/ScintillaDoc.html#SCI_LOWERCASE>

=cut

$autogen{SCI_LOWERCASE} = {
    subProto => 'lowerCase()',
    sciProto => 'SCI_LOWERCASE',
};

=item editor()->upperCase()

Transform the selection to upper case.

See Scintilla documentation for  L<SCI_UPPERCASE|https://www.scintilla.org/ScintillaDoc.html#SCI_UPPERCASE>

=cut

$autogen{SCI_UPPERCASE} = {
    subProto => 'upperCase()',
    sciProto => 'SCI_UPPERCASE',
};

=item editor()->lineScrollDown()

Scroll the document down, keeping the caret visible.

See Scintilla documentation for  L<SCI_LINESCROLLDOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESCROLLDOWN>

=cut

$autogen{SCI_LINESCROLLDOWN} = {
    subProto => 'lineScrollDown()',
    sciProto => 'SCI_LINESCROLLDOWN',
};

=item editor()->lineScrollUp()

Scroll the document up, keeping the caret visible.

See Scintilla documentation for  L<SCI_LINESCROLLUP|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESCROLLUP>

=cut

$autogen{SCI_LINESCROLLUP} = {
    subProto => 'lineScrollUp()',
    sciProto => 'SCI_LINESCROLLUP',
};

=item editor()->deleteBackNotLine()

Delete the selection or if no selection, the character before the caret. Will not delete the character before at the start of a line.

See Scintilla documentation for  L<SCI_DELETEBACKNOTLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_DELETEBACKNOTLINE>

=cut

$autogen{SCI_DELETEBACKNOTLINE} = {
    subProto => 'deleteBackNotLine()',
    sciProto => 'SCI_DELETEBACKNOTLINE',
};

=item editor()->homeDisplay()

Move caret to first position on display line.

See Scintilla documentation for  L<SCI_HOMEDISPLAY|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMEDISPLAY>

=cut

$autogen{SCI_HOMEDISPLAY} = {
    subProto => 'homeDisplay()',
    sciProto => 'SCI_HOMEDISPLAY',
};

=item editor()->homeDisplayExtend()

Move caret to first position on display line extending selection to new caret position.

See Scintilla documentation for  L<SCI_HOMEDISPLAYEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMEDISPLAYEXTEND>

=cut

$autogen{SCI_HOMEDISPLAYEXTEND} = {
    subProto => 'homeDisplayExtend()',
    sciProto => 'SCI_HOMEDISPLAYEXTEND',
};

=item editor()->lineEndDisplay()

Move caret to last position on display line.

See Scintilla documentation for  L<SCI_LINEENDDISPLAY|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDDISPLAY>

=cut

$autogen{SCI_LINEENDDISPLAY} = {
    subProto => 'lineEndDisplay()',
    sciProto => 'SCI_LINEENDDISPLAY',
};

=item editor()->lineEndDisplayExtend()

Move caret to last position on display line extending selection to new caret position.

See Scintilla documentation for  L<SCI_LINEENDDISPLAYEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDDISPLAYEXTEND>

=cut

$autogen{SCI_LINEENDDISPLAYEXTEND} = {
    subProto => 'lineEndDisplayExtend()',
    sciProto => 'SCI_LINEENDDISPLAYEXTEND',
};

=item editor()->homeWrap()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_HOMEWRAP|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMEWRAP>

=cut

$autogen{SCI_HOMEWRAP} = {
    subProto => 'homeWrap()',
    sciProto => 'SCI_HOMEWRAP',
};

=item editor()->homeWrapExtend()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_HOMEWRAPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMEWRAPEXTEND>

=cut

$autogen{SCI_HOMEWRAPEXTEND} = {
    subProto => 'homeWrapExtend()',
    sciProto => 'SCI_HOMEWRAPEXTEND',
};

=item editor()->lineEndWrap()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_LINEENDWRAP|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDWRAP>

=cut

$autogen{SCI_LINEENDWRAP} = {
    subProto => 'lineEndWrap()',
    sciProto => 'SCI_LINEENDWRAP',
};

=item editor()->lineEndWrapExtend()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_LINEENDWRAPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDWRAPEXTEND>

=cut

$autogen{SCI_LINEENDWRAPEXTEND} = {
    subProto => 'lineEndWrapExtend()',
    sciProto => 'SCI_LINEENDWRAPEXTEND',
};

=item editor()->vCHomeWrap()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_VCHOMEWRAP|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMEWRAP>

=cut

$autogen{SCI_VCHOMEWRAP} = {
    subProto => 'vCHomeWrap()',
    sciProto => 'SCI_VCHOMEWRAP',
};

=item editor()->vCHomeWrapExtend()

These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

See Scintilla documentation for  L<SCI_VCHOMEWRAPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMEWRAPEXTEND>

=cut

$autogen{SCI_VCHOMEWRAPEXTEND} = {
    subProto => 'vCHomeWrapExtend()',
    sciProto => 'SCI_VCHOMEWRAPEXTEND',
};

=item editor()->lineCopy()

Copy the line containing the caret.

See Scintilla documentation for  L<SCI_LINECOPY|https://www.scintilla.org/ScintillaDoc.html#SCI_LINECOPY>

=cut

$autogen{SCI_LINECOPY} = {
    subProto => 'lineCopy()',
    sciProto => 'SCI_LINECOPY',
};

=item editor()->wordPartLeft()

Move to the previous change in capitalisation.

See Scintilla documentation for  L<SCI_WORDPARTLEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDPARTLEFT>

=cut

$autogen{SCI_WORDPARTLEFT} = {
    subProto => 'wordPartLeft()',
    sciProto => 'SCI_WORDPARTLEFT',
};

=item editor()->wordPartLeftExtend()

Move to the previous change in capitalisation extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDPARTLEFTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDPARTLEFTEXTEND>

=cut

$autogen{SCI_WORDPARTLEFTEXTEND} = {
    subProto => 'wordPartLeftExtend()',
    sciProto => 'SCI_WORDPARTLEFTEXTEND',
};

=item editor()->wordPartRight()

Move to the change next in capitalisation.

See Scintilla documentation for  L<SCI_WORDPARTRIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDPARTRIGHT>

=cut

$autogen{SCI_WORDPARTRIGHT} = {
    subProto => 'wordPartRight()',
    sciProto => 'SCI_WORDPARTRIGHT',
};

=item editor()->wordPartRightExtend()

Move to the next change in capitalisation extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDPARTRIGHTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDPARTRIGHTEXTEND>

=cut

$autogen{SCI_WORDPARTRIGHTEXTEND} = {
    subProto => 'wordPartRightExtend()',
    sciProto => 'SCI_WORDPARTRIGHTEXTEND',
};

=item editor()->delLineLeft()

Delete back from the current position to the start of the line.

See Scintilla documentation for  L<SCI_DELLINELEFT|https://www.scintilla.org/ScintillaDoc.html#SCI_DELLINELEFT>

=cut

$autogen{SCI_DELLINELEFT} = {
    subProto => 'delLineLeft()',
    sciProto => 'SCI_DELLINELEFT',
};

=item editor()->delLineRight()

Delete forwards from the current position to the end of the line.

See Scintilla documentation for  L<SCI_DELLINERIGHT|https://www.scintilla.org/ScintillaDoc.html#SCI_DELLINERIGHT>

=cut

$autogen{SCI_DELLINERIGHT} = {
    subProto => 'delLineRight()',
    sciProto => 'SCI_DELLINERIGHT',
};

=item editor()->paraDown()

Move caret between paragraphs (delimited by empty lines).

See Scintilla documentation for  L<SCI_PARADOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_PARADOWN>

=cut

$autogen{SCI_PARADOWN} = {
    subProto => 'paraDown()',
    sciProto => 'SCI_PARADOWN',
};

=item editor()->paraDownExtend()

Move caret between paragraphs (delimited by empty lines).

See Scintilla documentation for  L<SCI_PARADOWNEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PARADOWNEXTEND>

=cut

$autogen{SCI_PARADOWNEXTEND} = {
    subProto => 'paraDownExtend()',
    sciProto => 'SCI_PARADOWNEXTEND',
};

=item editor()->paraUp()

Move caret between paragraphs (delimited by empty lines).

See Scintilla documentation for  L<SCI_PARAUP|https://www.scintilla.org/ScintillaDoc.html#SCI_PARAUP>

=cut

$autogen{SCI_PARAUP} = {
    subProto => 'paraUp()',
    sciProto => 'SCI_PARAUP',
};

=item editor()->paraUpExtend()

Move caret between paragraphs (delimited by empty lines).

See Scintilla documentation for  L<SCI_PARAUPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PARAUPEXTEND>

=cut

$autogen{SCI_PARAUPEXTEND} = {
    subProto => 'paraUpExtend()',
    sciProto => 'SCI_PARAUPEXTEND',
};

=item editor()->lineDownRectExtend()

Move caret down one line, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_LINEDOWNRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEDOWNRECTEXTEND>

=cut

$autogen{SCI_LINEDOWNRECTEXTEND} = {
    subProto => 'lineDownRectExtend()',
    sciProto => 'SCI_LINEDOWNRECTEXTEND',
};

=item editor()->lineUpRectExtend()

Move caret up one line, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_LINEUPRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEUPRECTEXTEND>

=cut

$autogen{SCI_LINEUPRECTEXTEND} = {
    subProto => 'lineUpRectExtend()',
    sciProto => 'SCI_LINEUPRECTEXTEND',
};

=item editor()->charLeftRectExtend()

Move caret left one character, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_CHARLEFTRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARLEFTRECTEXTEND>

=cut

$autogen{SCI_CHARLEFTRECTEXTEND} = {
    subProto => 'charLeftRectExtend()',
    sciProto => 'SCI_CHARLEFTRECTEXTEND',
};

=item editor()->charRightRectExtend()

Move caret right one character, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_CHARRIGHTRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_CHARRIGHTRECTEXTEND>

=cut

$autogen{SCI_CHARRIGHTRECTEXTEND} = {
    subProto => 'charRightRectExtend()',
    sciProto => 'SCI_CHARRIGHTRECTEXTEND',
};

=item editor()->homeRectExtend()

Move caret to first position on line, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_HOMERECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_HOMERECTEXTEND>

=cut

$autogen{SCI_HOMERECTEXTEND} = {
    subProto => 'homeRectExtend()',
    sciProto => 'SCI_HOMERECTEXTEND',
};

=item editor()->vCHomeRectExtend()

Move caret to before first visible character on line. If already there move to first character on line. In either case, extend rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_VCHOMERECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMERECTEXTEND>

=cut

$autogen{SCI_VCHOMERECTEXTEND} = {
    subProto => 'vCHomeRectExtend()',
    sciProto => 'SCI_VCHOMERECTEXTEND',
};

=item editor()->lineEndRectExtend()

Move caret to last position on line, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_LINEENDRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_LINEENDRECTEXTEND>

=cut

$autogen{SCI_LINEENDRECTEXTEND} = {
    subProto => 'lineEndRectExtend()',
    sciProto => 'SCI_LINEENDRECTEXTEND',
};

=item editor()->pageUpRectExtend()

Move caret one page up, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_PAGEUPRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEUPRECTEXTEND>

=cut

$autogen{SCI_PAGEUPRECTEXTEND} = {
    subProto => 'pageUpRectExtend()',
    sciProto => 'SCI_PAGEUPRECTEXTEND',
};

=item editor()->pageDownRectExtend()

Move caret one page down, extending rectangular selection to new caret position.

See Scintilla documentation for  L<SCI_PAGEDOWNRECTEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_PAGEDOWNRECTEXTEND>

=cut

$autogen{SCI_PAGEDOWNRECTEXTEND} = {
    subProto => 'pageDownRectExtend()',
    sciProto => 'SCI_PAGEDOWNRECTEXTEND',
};

=item editor()->stutteredPageUp()

Move caret to top of page, or one page up if already at top of page.

See Scintilla documentation for  L<SCI_STUTTEREDPAGEUP|https://www.scintilla.org/ScintillaDoc.html#SCI_STUTTEREDPAGEUP>

=cut

$autogen{SCI_STUTTEREDPAGEUP} = {
    subProto => 'stutteredPageUp()',
    sciProto => 'SCI_STUTTEREDPAGEUP',
};

=item editor()->stutteredPageUpExtend()

Move caret to top of page, or one page up if already at top of page, extending selection to new caret position.

See Scintilla documentation for  L<SCI_STUTTEREDPAGEUPEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_STUTTEREDPAGEUPEXTEND>

=cut

$autogen{SCI_STUTTEREDPAGEUPEXTEND} = {
    subProto => 'stutteredPageUpExtend()',
    sciProto => 'SCI_STUTTEREDPAGEUPEXTEND',
};

=item editor()->stutteredPageDown()

Move caret to bottom of page, or one page down if already at bottom of page.

See Scintilla documentation for  L<SCI_STUTTEREDPAGEDOWN|https://www.scintilla.org/ScintillaDoc.html#SCI_STUTTEREDPAGEDOWN>

=cut

$autogen{SCI_STUTTEREDPAGEDOWN} = {
    subProto => 'stutteredPageDown()',
    sciProto => 'SCI_STUTTEREDPAGEDOWN',
};

=item editor()->stutteredPageDownExtend()

Move caret to bottom of page, or one page down if already at bottom of page, extending selection to new caret position.

See Scintilla documentation for  L<SCI_STUTTEREDPAGEDOWNEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_STUTTEREDPAGEDOWNEXTEND>

=cut

$autogen{SCI_STUTTEREDPAGEDOWNEXTEND} = {
    subProto => 'stutteredPageDownExtend()',
    sciProto => 'SCI_STUTTEREDPAGEDOWNEXTEND',
};

=item editor()->wordLeftEnd()

Move caret left one word, position cursor at end of word.

See Scintilla documentation for  L<SCI_WORDLEFTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDLEFTEND>

=cut

$autogen{SCI_WORDLEFTEND} = {
    subProto => 'wordLeftEnd()',
    sciProto => 'SCI_WORDLEFTEND',
};

=item editor()->wordLeftEndExtend()

Move caret left one word, position cursor at end of word, extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDLEFTENDEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDLEFTENDEXTEND>

=cut

$autogen{SCI_WORDLEFTENDEXTEND} = {
    subProto => 'wordLeftEndExtend()',
    sciProto => 'SCI_WORDLEFTENDEXTEND',
};

=item editor()->wordRightEnd()

Move caret right one word, position cursor at end of word.

See Scintilla documentation for  L<SCI_WORDRIGHTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDRIGHTEND>

=cut

$autogen{SCI_WORDRIGHTEND} = {
    subProto => 'wordRightEnd()',
    sciProto => 'SCI_WORDRIGHTEND',
};

=item editor()->wordRightEndExtend()

Move caret right one word, position cursor at end of word, extending selection to new caret position.

See Scintilla documentation for  L<SCI_WORDRIGHTENDEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_WORDRIGHTENDEXTEND>

=cut

$autogen{SCI_WORDRIGHTENDEXTEND} = {
    subProto => 'wordRightEndExtend()',
    sciProto => 'SCI_WORDRIGHTENDEXTEND',
};

=item editor()->selectionDuplicate()

Duplicate the selection. If selection empty duplicate the line containing the caret.

See Scintilla documentation for  L<SCI_SELECTIONDUPLICATE|https://www.scintilla.org/ScintillaDoc.html#SCI_SELECTIONDUPLICATE>

=cut

$autogen{SCI_SELECTIONDUPLICATE} = {
    subProto => 'selectionDuplicate()',
    sciProto => 'SCI_SELECTIONDUPLICATE',
};

=item editor()->verticalCentreCaret()

Centre current line in window.

See Scintilla documentation for  L<SCI_VERTICALCENTRECARET|https://www.scintilla.org/ScintillaDoc.html#SCI_VERTICALCENTRECARET>

=cut

$autogen{SCI_VERTICALCENTRECARET} = {
    subProto => 'verticalCentreCaret()',
    sciProto => 'SCI_VERTICALCENTRECARET',
};

=item editor()->scrollToStart()

Scroll to start of document.

See Scintilla documentation for  L<SCI_SCROLLTOSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_SCROLLTOSTART>

=cut

$autogen{SCI_SCROLLTOSTART} = {
    subProto => 'scrollToStart()',
    sciProto => 'SCI_SCROLLTOSTART',
};

=item editor()->scrollToEnd()

Scroll to end of document.

See Scintilla documentation for  L<SCI_SCROLLTOEND|https://www.scintilla.org/ScintillaDoc.html#SCI_SCROLLTOEND>

=cut

$autogen{SCI_SCROLLTOEND} = {
    subProto => 'scrollToEnd()',
    sciProto => 'SCI_SCROLLTOEND',
};

=item editor()->vCHomeDisplay()

Move caret to before first visible character on display line. If already there move to first character on display line.

See Scintilla documentation for  L<SCI_VCHOMEDISPLAY|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMEDISPLAY>

=cut

$autogen{SCI_VCHOMEDISPLAY} = {
    subProto => 'vCHomeDisplay()',
    sciProto => 'SCI_VCHOMEDISPLAY',
};

=item editor()->vCHomeDisplayExtend()

Like VCHomeDisplay but extending selection to new caret position.

See Scintilla documentation for  L<SCI_VCHOMEDISPLAYEXTEND|https://www.scintilla.org/ScintillaDoc.html#SCI_VCHOMEDISPLAYEXTEND>

=cut

$autogen{SCI_VCHOMEDISPLAYEXTEND} = {
    subProto => 'vCHomeDisplayExtend()',
    sciProto => 'SCI_VCHOMEDISPLAYEXTEND',
};

=back

=head2 Key bindings

=begin scintilla

SCI_ASSIGNCMDKEY(int keyDefinition, int sciCommand)
SCI_CLEARCMDKEY(int keyDefinition)
SCI_CLEARALLCMDKEYS
SCI_NULL

=end scintilla

=over

=item editor()->assignCmdKey(km, msg)

When key+modifier combination km is pressed perform msg.

See Scintilla documentation for  L<SCI_ASSIGNCMDKEY|https://www.scintilla.org/ScintillaDoc.html#SCI_ASSIGNCMDKEY>

=cut

$autogen{SCI_ASSIGNCMDKEY} = {
    subProto => 'assignCmdKey(km, msg)',
    sciProto => 'SCI_ASSIGNCMDKEY',
};

=item editor()->clearCmdKey(km)

When key+modifier combination km is pressed do nothing.

See Scintilla documentation for  L<SCI_CLEARCMDKEY|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARCMDKEY>

=cut

$autogen{SCI_CLEARCMDKEY} = {
    subProto => 'clearCmdKey(km)',
    sciProto => 'SCI_CLEARCMDKEY',
};

=item editor()->clearAllCmdKeys()

Drop all key mappings.

See Scintilla documentation for  L<SCI_CLEARALLCMDKEYS|https://www.scintilla.org/ScintillaDoc.html#SCI_CLEARALLCMDKEYS>

=cut

$autogen{SCI_CLEARALLCMDKEYS} = {
    subProto => 'clearAllCmdKeys()',
    sciProto => 'SCI_CLEARALLCMDKEYS',
};

=item editor()->null()

Null operation.

See Scintilla documentation for  L<SCI_NULL|https://www.scintilla.org/ScintillaDoc.html#SCI_NULL>

=cut

$autogen{SCI_NULL} = {
    subProto => 'null()',
    sciProto => 'SCI_NULL',
};

=back

=head2 Popup edit menu

=begin scintilla

SCI_USEPOPUP(int popUpMode)

=end scintilla

=over

=item editor()->usePopUp(allowPopUp)

Set whether a pop up menu is displayed automatically when the user presses the wrong mouse button.

See Scintilla documentation for  L<SCI_USEPOPUP|https://www.scintilla.org/ScintillaDoc.html#SCI_USEPOPUP>

=cut

$autogen{SCI_USEPOPUP} = {
    subProto => 'usePopUp(allowPopUp)',
    sciProto => 'SCI_USEPOPUP',
};

=back

=head2 Macro recording

=begin scintilla

SCI_STARTRECORD
SCI_STOPRECORD

=end scintilla

=over

=item editor()->startRecord()

Start notifying the container of all key presses and commands.

See Scintilla documentation for  L<SCI_STARTRECORD|https://www.scintilla.org/ScintillaDoc.html#SCI_STARTRECORD>

=cut

$autogen{SCI_STARTRECORD} = {
    subProto => 'startRecord()',
    sciProto => 'SCI_STARTRECORD',
};

=item editor()->stopRecord()

Stop notifying the container of all key presses and commands.

See Scintilla documentation for  L<SCI_STOPRECORD|https://www.scintilla.org/ScintillaDoc.html#SCI_STOPRECORD>

=cut

$autogen{SCI_STOPRECORD} = {
    subProto => 'stopRecord()',
    sciProto => 'SCI_STOPRECORD',
};

=back

=head2

=begin scintilla



=end scintilla

=over


=back

=head2 Printing

=begin scintilla

SCI_FORMATRANGE(bool draw, Sci_RangeToFormat *fr) → position
SCI_SETPRINTMAGNIFICATION(int magnification)
SCI_GETPRINTMAGNIFICATION → int
SCI_SETPRINTCOLOURMODE(int mode)
SCI_GETPRINTCOLOURMODE → int
SCI_SETPRINTWRAPMODE(int wrapMode)
SCI_GETPRINTWRAPMODE → int

=end scintilla

=over

=item editor()->SCI_FORMATRANGE

TODO

See Scintilla documentation for  L<SCI_FORMATRANGE|https://www.scintilla.org/ScintillaDoc.html#SCI_FORMATRANGE>

=cut

$autogen{SCI_FORMATRANGE} = {
    subProto => 'SCI_FORMATRANGE',
    sciProto => 'SCI_FORMATRANGE',
};

=item editor()->setPrintMagnification(magnification)

Sets the print magnification added to the point size of each style for printing.

See Scintilla documentation for  L<SCI_SETPRINTMAGNIFICATION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPRINTMAGNIFICATION>

=cut

$autogen{SCI_SETPRINTMAGNIFICATION} = {
    subProto => 'setPrintMagnification(magnification)',
    sciProto => 'SCI_SETPRINTMAGNIFICATION',
};

=item editor()->getPrintMagnification() → int

Returns the print magnification.

See Scintilla documentation for  L<SCI_GETPRINTMAGNIFICATION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPRINTMAGNIFICATION>

=cut

$autogen{SCI_GETPRINTMAGNIFICATION} = {
    subProto => 'getPrintMagnification() → int',
    sciProto => 'SCI_GETPRINTMAGNIFICATION',
};

=item editor()->setPrintColourMode(mode)

Modify colours when printing for clearer printed text.

See Scintilla documentation for  L<SCI_SETPRINTCOLOURMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPRINTCOLOURMODE>

=cut

$autogen{SCI_SETPRINTCOLOURMODE} = {
    subProto => 'setPrintColourMode(mode)',
    sciProto => 'SCI_SETPRINTCOLOURMODE',
};

=item editor()->getPrintColourMode() → int

Returns the print colour mode.

See Scintilla documentation for  L<SCI_GETPRINTCOLOURMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPRINTCOLOURMODE>

=cut

$autogen{SCI_GETPRINTCOLOURMODE} = {
    subProto => 'getPrintColourMode() → int',
    sciProto => 'SCI_GETPRINTCOLOURMODE',
};

=item editor()->setPrintWrapMode(mode)

Set printing to line wrapped (SC_WRAP_WORD) or not line wrapped (SC_WRAP_NONE).

See Scintilla documentation for  L<SCI_SETPRINTWRAPMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPRINTWRAPMODE>

=cut

$autogen{SCI_SETPRINTWRAPMODE} = {
    subProto => 'setPrintWrapMode(mode)',
    sciProto => 'SCI_SETPRINTWRAPMODE',
};

=item editor()->getPrintWrapMode() → int

Is printing line wrapped?

See Scintilla documentation for  L<SCI_GETPRINTWRAPMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPRINTWRAPMODE>

=cut

$autogen{SCI_GETPRINTWRAPMODE} = {
    subProto => 'getPrintWrapMode() → int',
    sciProto => 'SCI_GETPRINTWRAPMODE',
};

=back

=head2 Direct access

=begin scintilla

SCI_GETDIRECTFUNCTION → pointer
SCI_GETDIRECTPOINTER → pointer
SCI_GETCHARACTERPOINTER → pointer
SCI_GETRANGEPOINTER(position start, position lengthRange) → pointer
SCI_GETGAPPOSITION → position

=end scintilla

=over

=item editor()->getDirectFunction() → int

Retrieve a pointer to a function that processes messages for this Scintilla.

See Scintilla documentation for  L<SCI_GETDIRECTFUNCTION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETDIRECTFUNCTION>

=cut

$autogen{SCI_GETDIRECTFUNCTION} = {
    subProto => 'getDirectFunction() → int',
    sciProto => 'SCI_GETDIRECTFUNCTION',
};

=item editor()->getDirectPointer() → int

Retrieve a pointer value to use as the first argument when calling the function returned by GetDirectFunction.

See Scintilla documentation for  L<SCI_GETDIRECTPOINTER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETDIRECTPOINTER>

=cut

$autogen{SCI_GETDIRECTPOINTER} = {
    subProto => 'getDirectPointer() → int',
    sciProto => 'SCI_GETDIRECTPOINTER',
};

=item editor()->getCharacterPointer() → str

Gets a copy of the text of the document, without first allowing Scintilla to make its copy of it. In practice, that means it does exactly the same as Editor.getText, however, if you have the possibility of the user interfering with the document _whilst_ getCharacterPointer() is running, then it’s safer to use getText(). On larger documents, getCharacterPointer() could be noticable quicker.

See Scintilla documentation for  L<SCI_GETCHARACTERPOINTER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCHARACTERPOINTER>

=cut

$autogen{SCI_GETCHARACTERPOINTER} = {
    subProto => 'getCharacterPointer() → str',
    sciProto => 'SCI_GETCHARACTERPOINTER',
};

=item editor()->SCI_GETRANGEPOINTER

TODO

See Scintilla documentation for  L<SCI_GETRANGEPOINTER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETRANGEPOINTER>

=cut

$autogen{SCI_GETRANGEPOINTER} = {
    subProto => 'SCI_GETRANGEPOINTER',
    sciProto => 'SCI_GETRANGEPOINTER',
};

=item editor()->getGapPosition() → int

Return a position which, to avoid performance costs, should not be within the range of a call to GetRangePointer.

See Scintilla documentation for  L<SCI_GETGAPPOSITION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETGAPPOSITION>

=cut

$autogen{SCI_GETGAPPOSITION} = {
    subProto => 'getGapPosition() → int',
    sciProto => 'SCI_GETGAPPOSITION',
};

=back

=head2 Multiple views

=begin scintilla

SCI_GETDOCPOINTER → pointer
SCI_SETDOCPOINTER(<unused>, pointer doc)
SCI_CREATEDOCUMENT(position bytes, int documentOptions) → pointer
SCI_ADDREFDOCUMENT(<unused>, pointer doc)
SCI_RELEASEDOCUMENT(<unused>, pointer doc)
SCI_GETDOCUMENTOPTIONS → int

=end scintilla

=over

=item editor()->getDocPointer() → int

Retrieve a pointer to the document object.

See Scintilla documentation for  L<SCI_GETDOCPOINTER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETDOCPOINTER>

=cut

$autogen{SCI_GETDOCPOINTER} = {
    subProto => 'getDocPointer() → int',
    sciProto => 'SCI_GETDOCPOINTER',
};

=item editor()->setDocPointer(pointer)

Change the document object used.

See Scintilla documentation for  L<SCI_SETDOCPOINTER|https://www.scintilla.org/ScintillaDoc.html#SCI_SETDOCPOINTER>

=cut

$autogen{SCI_SETDOCPOINTER} = {
    subProto => 'setDocPointer(pointer)',
    sciProto => 'SCI_SETDOCPOINTER',
};

=item editor()->createDocument() → int

Create a new document object. Starts with reference count of 1 and not selected into editor.

See Scintilla documentation for  L<SCI_CREATEDOCUMENT|https://www.scintilla.org/ScintillaDoc.html#SCI_CREATEDOCUMENT>

=cut

$autogen{SCI_CREATEDOCUMENT} = {
    subProto => 'createDocument() → int',
    sciProto => 'SCI_CREATEDOCUMENT',
};

=item editor()->addRefDocument(doc)

Extend life of document.

See Scintilla documentation for  L<SCI_ADDREFDOCUMENT|https://www.scintilla.org/ScintillaDoc.html#SCI_ADDREFDOCUMENT>

=cut

$autogen{SCI_ADDREFDOCUMENT} = {
    subProto => 'addRefDocument(doc)',
    sciProto => 'SCI_ADDREFDOCUMENT',
};

=item editor()->releaseDocument(doc)

Release a reference to the document, deleting document if it fades to black.

See Scintilla documentation for  L<SCI_RELEASEDOCUMENT|https://www.scintilla.org/ScintillaDoc.html#SCI_RELEASEDOCUMENT>

=cut

$autogen{SCI_RELEASEDOCUMENT} = {
    subProto => 'releaseDocument(doc)',
    sciProto => 'SCI_RELEASEDOCUMENT',
};

=item editor()->SCI_GETDOCUMENTOPTIONS

TODO

See Scintilla documentation for  L<SCI_GETDOCUMENTOPTIONS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETDOCUMENTOPTIONS>

=cut

$autogen{SCI_GETDOCUMENTOPTIONS} = {
    subProto => 'SCI_GETDOCUMENTOPTIONS',
    sciProto => 'SCI_GETDOCUMENTOPTIONS',
};

=back

=head2 Background loading and saving

=begin scintilla

SCI_CREATELOADER(position bytes, int documentOptions) → pointer

=end scintilla

=over

=item editor()->createLoader(bytes) → int

Create an ILoader*.

See Scintilla documentation for  L<SCI_CREATELOADER|https://www.scintilla.org/ScintillaDoc.html#SCI_CREATELOADER>

=cut

$autogen{SCI_CREATELOADER} = {
    subProto => 'createLoader(bytes) → int',
    sciProto => 'SCI_CREATELOADER',
};

=back

=head2 Folding

=begin scintilla

SCI_VISIBLEFROMDOCLINE(line docLine) → line
SCI_DOCLINEFROMVISIBLE(line displayLine) → line
SCI_SHOWLINES(line lineStart, line lineEnd)
SCI_HIDELINES(line lineStart, line lineEnd)
SCI_GETLINEVISIBLE(line line) → bool
SCI_GETALLLINESVISIBLE → bool
SCI_SETFOLDLEVEL(line line, int level)
SCI_GETFOLDLEVEL(line line) → int
SCI_SETAUTOMATICFOLD(int automaticFold)
SCI_GETAUTOMATICFOLD → int
SCI_SETFOLDFLAGS(int flags)
SCI_GETLASTCHILD(line line, int level) → line
SCI_GETFOLDPARENT(line line) → line
SCI_SETFOLDEXPANDED(line line, bool expanded)
SCI_GETFOLDEXPANDED(line line) → bool
SCI_CONTRACTEDFOLDNEXT(line lineStart) → line
SCI_TOGGLEFOLD(line line)
SCI_TOGGLEFOLDSHOWTEXT(line line, const char *text)
SCI_FOLDDISPLAYTEXTSETSTYLE(int style)
SCI_FOLDDISPLAYTEXTGETSTYLE → int
SCI_SETDEFAULTFOLDDISPLAYTEXT(<unused>, const char *text)
SCI_GETDEFAULTFOLDDISPLAYTEXT(<unused>, char *text) → int
SCI_FOLDLINE(line line, int action)
SCI_FOLDCHILDREN(line line, int action)
SCI_FOLDALL(int action)
SCI_EXPANDCHILDREN(line line, int level)
SCI_ENSUREVISIBLE(line line)
SCI_ENSUREVISIBLEENFORCEPOLICY(line line)

=end scintilla

=over

=item editor()->visibleFromDocLine(line) → int

Find the display line of a document line taking hidden lines into account.

See Scintilla documentation for  L<SCI_VISIBLEFROMDOCLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_VISIBLEFROMDOCLINE>

=cut

$autogen{SCI_VISIBLEFROMDOCLINE} = {
    subProto => 'visibleFromDocLine(line) → int',
    sciProto => 'SCI_VISIBLEFROMDOCLINE',
};

=item editor()->docLineFromVisible(lineDisplay) → int

Find the document line of a display line taking hidden lines into account.

See Scintilla documentation for  L<SCI_DOCLINEFROMVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_DOCLINEFROMVISIBLE>

=cut

$autogen{SCI_DOCLINEFROMVISIBLE} = {
    subProto => 'docLineFromVisible(lineDisplay) → int',
    sciProto => 'SCI_DOCLINEFROMVISIBLE',
};

=item editor()->showLines(lineStart, lineEnd)

Make a range of lines visible.

See Scintilla documentation for  L<SCI_SHOWLINES|https://www.scintilla.org/ScintillaDoc.html#SCI_SHOWLINES>

=cut

$autogen{SCI_SHOWLINES} = {
    subProto => 'showLines(lineStart, lineEnd)',
    sciProto => 'SCI_SHOWLINES',
};

=item editor()->hideLines(lineStart, lineEnd)

Make a range of lines invisible.

See Scintilla documentation for  L<SCI_HIDELINES|https://www.scintilla.org/ScintillaDoc.html#SCI_HIDELINES>

=cut

$autogen{SCI_HIDELINES} = {
    subProto => 'hideLines(lineStart, lineEnd)',
    sciProto => 'SCI_HIDELINES',
};

=item editor()->getLineVisible(line) → bool

Is a line visible?

See Scintilla documentation for  L<SCI_GETLINEVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLINEVISIBLE>

=cut

$autogen{SCI_GETLINEVISIBLE} = {
    subProto => 'getLineVisible(line) → bool',
    sciProto => 'SCI_GETLINEVISIBLE',
};

=item editor()->getAllLinesVisible() → bool

Are all lines visible?

See Scintilla documentation for  L<SCI_GETALLLINESVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETALLLINESVISIBLE>

=cut

$autogen{SCI_GETALLLINESVISIBLE} = {
    subProto => 'getAllLinesVisible() → bool',
    sciProto => 'SCI_GETALLLINESVISIBLE',
};

=item editor()->setFoldLevel(line, level)

Set the fold level of a line. This encodes an integer level along with flags indicating whether the line is a header and whether it is effectively white space.

See Scintilla documentation for  L<SCI_SETFOLDLEVEL|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOLDLEVEL>

=cut

$autogen{SCI_SETFOLDLEVEL} = {
    subProto => 'setFoldLevel(line, level)',
    sciProto => 'SCI_SETFOLDLEVEL',
};

=item editor()->getFoldLevel(line) → int

Retrieve the fold level of a line.

See Scintilla documentation for  L<SCI_GETFOLDLEVEL|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFOLDLEVEL>

=cut

$autogen{SCI_GETFOLDLEVEL} = {
    subProto => 'getFoldLevel(line) → int',
    sciProto => 'SCI_GETFOLDLEVEL',
};

=item editor()->setAutomaticFold(automaticFold)

Set automatic folding behaviours.

See Scintilla documentation for  L<SCI_SETAUTOMATICFOLD|https://www.scintilla.org/ScintillaDoc.html#SCI_SETAUTOMATICFOLD>

=cut

$autogen{SCI_SETAUTOMATICFOLD} = {
    subProto => 'setAutomaticFold(automaticFold)',
    sciProto => 'SCI_SETAUTOMATICFOLD',
};

=item editor()->getAutomaticFold() → int

Get automatic folding behaviours.

See Scintilla documentation for  L<SCI_GETAUTOMATICFOLD|https://www.scintilla.org/ScintillaDoc.html#SCI_GETAUTOMATICFOLD>

=cut

$autogen{SCI_GETAUTOMATICFOLD} = {
    subProto => 'getAutomaticFold() → int',
    sciProto => 'SCI_GETAUTOMATICFOLD',
};

=item editor()->setFoldFlags(flags)

Set some style options for folding.

See Scintilla documentation for  L<SCI_SETFOLDFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOLDFLAGS>

=cut

$autogen{SCI_SETFOLDFLAGS} = {
    subProto => 'setFoldFlags(flags)',
    sciProto => 'SCI_SETFOLDFLAGS',
};

=item editor()->getLastChild(line, level) → int

Find the last child line of a header line.

See Scintilla documentation for  L<SCI_GETLASTCHILD|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLASTCHILD>

=cut

$autogen{SCI_GETLASTCHILD} = {
    subProto => 'getLastChild(line, level) → int',
    sciProto => 'SCI_GETLASTCHILD',
};

=item editor()->getFoldParent(line) → int

Find the parent line of a child line.

See Scintilla documentation for  L<SCI_GETFOLDPARENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFOLDPARENT>

=cut

$autogen{SCI_GETFOLDPARENT} = {
    subProto => 'getFoldParent(line) → int',
    sciProto => 'SCI_GETFOLDPARENT',
};

=item editor()->setFoldExpanded(line, expanded)

Show the children of a header line.

See Scintilla documentation for  L<SCI_SETFOLDEXPANDED|https://www.scintilla.org/ScintillaDoc.html#SCI_SETFOLDEXPANDED>

=cut

$autogen{SCI_SETFOLDEXPANDED} = {
    subProto => 'setFoldExpanded(line, expanded)',
    sciProto => 'SCI_SETFOLDEXPANDED',
};

=item editor()->getFoldExpanded(line) → bool

Is a header line expanded?

See Scintilla documentation for  L<SCI_GETFOLDEXPANDED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETFOLDEXPANDED>

=cut

$autogen{SCI_GETFOLDEXPANDED} = {
    subProto => 'getFoldExpanded(line) → bool',
    sciProto => 'SCI_GETFOLDEXPANDED',
};

=item editor()->contractedFoldNext(lineStart) → int

Find the next line at or after lineStart that is a contracted fold header line. Return -1 when no more lines.

See Scintilla documentation for  L<SCI_CONTRACTEDFOLDNEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_CONTRACTEDFOLDNEXT>

=cut

$autogen{SCI_CONTRACTEDFOLDNEXT} = {
    subProto => 'contractedFoldNext(lineStart) → int',
    sciProto => 'SCI_CONTRACTEDFOLDNEXT',
};

=item editor()->toggleFold(line)

Switch a header line between expanded and contracted.

See Scintilla documentation for  L<SCI_TOGGLEFOLD|https://www.scintilla.org/ScintillaDoc.html#SCI_TOGGLEFOLD>

=cut

$autogen{SCI_TOGGLEFOLD} = {
    subProto => 'toggleFold(line)',
    sciProto => 'SCI_TOGGLEFOLD',
};

=item editor()->SCI_TOGGLEFOLDSHOWTEXT

TODO

See Scintilla documentation for  L<SCI_TOGGLEFOLDSHOWTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_TOGGLEFOLDSHOWTEXT>

=cut

$autogen{SCI_TOGGLEFOLDSHOWTEXT} = {
    subProto => 'SCI_TOGGLEFOLDSHOWTEXT',
    sciProto => 'SCI_TOGGLEFOLDSHOWTEXT',
};

=item editor()->SCI_FOLDDISPLAYTEXTSETSTYLE

TODO

See Scintilla documentation for  L<SCI_FOLDDISPLAYTEXTSETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_FOLDDISPLAYTEXTSETSTYLE>

=cut

$autogen{SCI_FOLDDISPLAYTEXTSETSTYLE} = {
    subProto => 'SCI_FOLDDISPLAYTEXTSETSTYLE',
    sciProto => 'SCI_FOLDDISPLAYTEXTSETSTYLE',
};

=item editor()->SCI_FOLDDISPLAYTEXTGETSTYLE

TODO

See Scintilla documentation for  L<SCI_FOLDDISPLAYTEXTGETSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_FOLDDISPLAYTEXTGETSTYLE>

=cut

$autogen{SCI_FOLDDISPLAYTEXTGETSTYLE} = {
    subProto => 'SCI_FOLDDISPLAYTEXTGETSTYLE',
    sciProto => 'SCI_FOLDDISPLAYTEXTGETSTYLE',
};

=item editor()->SCI_SETDEFAULTFOLDDISPLAYTEXT

TODO

See Scintilla documentation for  L<SCI_SETDEFAULTFOLDDISPLAYTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETDEFAULTFOLDDISPLAYTEXT>

=cut

$autogen{SCI_SETDEFAULTFOLDDISPLAYTEXT} = {
    subProto => 'SCI_SETDEFAULTFOLDDISPLAYTEXT',
    sciProto => 'SCI_SETDEFAULTFOLDDISPLAYTEXT',
};

=item editor()->SCI_GETDEFAULTFOLDDISPLAYTEXT

TODO

See Scintilla documentation for  L<SCI_GETDEFAULTFOLDDISPLAYTEXT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETDEFAULTFOLDDISPLAYTEXT>

=cut

$autogen{SCI_GETDEFAULTFOLDDISPLAYTEXT} = {
    subProto => 'SCI_GETDEFAULTFOLDDISPLAYTEXT',
    sciProto => 'SCI_GETDEFAULTFOLDDISPLAYTEXT',
};

=item editor()->foldLine(line, action)

Expand or contract a fold header.

See Scintilla documentation for  L<SCI_FOLDLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_FOLDLINE>

=cut

$autogen{SCI_FOLDLINE} = {
    subProto => 'foldLine(line, action)',
    sciProto => 'SCI_FOLDLINE',
};

=item editor()->foldChildren(line, action)

Expand or contract a fold header and its children.

See Scintilla documentation for  L<SCI_FOLDCHILDREN|https://www.scintilla.org/ScintillaDoc.html#SCI_FOLDCHILDREN>

=cut

$autogen{SCI_FOLDCHILDREN} = {
    subProto => 'foldChildren(line, action)',
    sciProto => 'SCI_FOLDCHILDREN',
};

=item editor()->foldAll(action)

Expand or contract all fold headers.

See Scintilla documentation for  L<SCI_FOLDALL|https://www.scintilla.org/ScintillaDoc.html#SCI_FOLDALL>

=cut

$autogen{SCI_FOLDALL} = {
    subProto => 'foldAll(action)',
    sciProto => 'SCI_FOLDALL',
};

=item editor()->expandChildren(line, level)

Expand a fold header and all children. Use the level argument instead of the line’s current level.

See Scintilla documentation for  L<SCI_EXPANDCHILDREN|https://www.scintilla.org/ScintillaDoc.html#SCI_EXPANDCHILDREN>

=cut

$autogen{SCI_EXPANDCHILDREN} = {
    subProto => 'expandChildren(line, level)',
    sciProto => 'SCI_EXPANDCHILDREN',
};

=item editor()->ensureVisible(line)

Ensure a particular line is visible by expanding any header line hiding it.

See Scintilla documentation for  L<SCI_ENSUREVISIBLE|https://www.scintilla.org/ScintillaDoc.html#SCI_ENSUREVISIBLE>

=cut

$autogen{SCI_ENSUREVISIBLE} = {
    subProto => 'ensureVisible(line)',
    sciProto => 'SCI_ENSUREVISIBLE',
};

=item editor()->ensureVisibleEnforcePolicy(line)

Ensure a particular line is visible by expanding any header line hiding it. Use the currently set visibility policy to determine which range to display.

See Scintilla documentation for  L<SCI_ENSUREVISIBLEENFORCEPOLICY|https://www.scintilla.org/ScintillaDoc.html#SCI_ENSUREVISIBLEENFORCEPOLICY>

=cut

$autogen{SCI_ENSUREVISIBLEENFORCEPOLICY} = {
    subProto => 'ensureVisibleEnforcePolicy(line)',
    sciProto => 'SCI_ENSUREVISIBLEENFORCEPOLICY',
};

=back

=head2 Line wrapping

=begin scintilla

SCI_SETWRAPMODE(int wrapMode)
SCI_GETWRAPMODE → int
SCI_SETWRAPVISUALFLAGS(int wrapVisualFlags)
SCI_GETWRAPVISUALFLAGS → int
SCI_SETWRAPVISUALFLAGSLOCATION(int wrapVisualFlagsLocation)
SCI_GETWRAPVISUALFLAGSLOCATION → int
SCI_SETWRAPINDENTMODE(int wrapIndentMode)
SCI_GETWRAPINDENTMODE → int
SCI_SETWRAPSTARTINDENT(int indent)
SCI_GETWRAPSTARTINDENT → int
SCI_SETLAYOUTCACHE(int cacheMode)
SCI_GETLAYOUTCACHE → int
SCI_SETPOSITIONCACHE(int size)
SCI_GETPOSITIONCACHE → int
SCI_LINESSPLIT(int pixelWidth)
SCI_LINESJOIN
SCI_WRAPCOUNT(line docLine) → line

=end scintilla

=over

=item editor()->setWrapMode(mode)

Sets whether text is word wrapped.

See Scintilla documentation for  L<SCI_SETWRAPMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPMODE>

=cut

$autogen{SCI_SETWRAPMODE} = {
    subProto => 'setWrapMode(mode)',
    sciProto => 'SCI_SETWRAPMODE',
};

=item editor()->getWrapMode() → int

Retrieve whether text is word wrapped.

See Scintilla documentation for  L<SCI_GETWRAPMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPMODE>

=cut

$autogen{SCI_GETWRAPMODE} = {
    subProto => 'getWrapMode() → int',
    sciProto => 'SCI_GETWRAPMODE',
};

=item editor()->setWrapVisualFlags(wrapVisualFlags)

Set the display mode of visual flags for wrapped lines.

See Scintilla documentation for  L<SCI_SETWRAPVISUALFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPVISUALFLAGS>

=cut

$autogen{SCI_SETWRAPVISUALFLAGS} = {
    subProto => 'setWrapVisualFlags(wrapVisualFlags)',
    sciProto => 'SCI_SETWRAPVISUALFLAGS',
};

=item editor()->getWrapVisualFlags() → int

Retrive the display mode of visual flags for wrapped lines.

See Scintilla documentation for  L<SCI_GETWRAPVISUALFLAGS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPVISUALFLAGS>

=cut

$autogen{SCI_GETWRAPVISUALFLAGS} = {
    subProto => 'getWrapVisualFlags() → int',
    sciProto => 'SCI_GETWRAPVISUALFLAGS',
};

=item editor()->setWrapVisualFlagsLocation(wrapVisualFlagsLocation)

Set the location of visual flags for wrapped lines.

See Scintilla documentation for  L<SCI_SETWRAPVISUALFLAGSLOCATION|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPVISUALFLAGSLOCATION>

=cut

$autogen{SCI_SETWRAPVISUALFLAGSLOCATION} = {
    subProto => 'setWrapVisualFlagsLocation(wrapVisualFlagsLocation)',
    sciProto => 'SCI_SETWRAPVISUALFLAGSLOCATION',
};

=item editor()->getWrapVisualFlagsLocation() → int

Retrive the location of visual flags for wrapped lines.

See Scintilla documentation for  L<SCI_GETWRAPVISUALFLAGSLOCATION|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPVISUALFLAGSLOCATION>

=cut

$autogen{SCI_GETWRAPVISUALFLAGSLOCATION} = {
    subProto => 'getWrapVisualFlagsLocation() → int',
    sciProto => 'SCI_GETWRAPVISUALFLAGSLOCATION',
};

=item editor()->setWrapIndentMode(mode)

Sets how wrapped sublines are placed. Default is fixed.

See Scintilla documentation for  L<SCI_SETWRAPINDENTMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPINDENTMODE>

=cut

$autogen{SCI_SETWRAPINDENTMODE} = {
    subProto => 'setWrapIndentMode(mode)',
    sciProto => 'SCI_SETWRAPINDENTMODE',
};

=item editor()->getWrapIndentMode() → int

Retrieve how wrapped sublines are placed. Default is fixed.

See Scintilla documentation for  L<SCI_GETWRAPINDENTMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPINDENTMODE>

=cut

$autogen{SCI_GETWRAPINDENTMODE} = {
    subProto => 'getWrapIndentMode() → int',
    sciProto => 'SCI_GETWRAPINDENTMODE',
};

=item editor()->setWrapStartIndent(indent)

Set the start indent for wrapped lines.

See Scintilla documentation for  L<SCI_SETWRAPSTARTINDENT|https://www.scintilla.org/ScintillaDoc.html#SCI_SETWRAPSTARTINDENT>

=cut

$autogen{SCI_SETWRAPSTARTINDENT} = {
    subProto => 'setWrapStartIndent(indent)',
    sciProto => 'SCI_SETWRAPSTARTINDENT',
};

=item editor()->getWrapStartIndent() → int

Retrive the start indent for wrapped lines.

See Scintilla documentation for  L<SCI_GETWRAPSTARTINDENT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETWRAPSTARTINDENT>

=cut

$autogen{SCI_GETWRAPSTARTINDENT} = {
    subProto => 'getWrapStartIndent() → int',
    sciProto => 'SCI_GETWRAPSTARTINDENT',
};

=item editor()->setLayoutCache(mode)

Sets the degree of caching of layout information.

See Scintilla documentation for  L<SCI_SETLAYOUTCACHE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLAYOUTCACHE>

=cut

$autogen{SCI_SETLAYOUTCACHE} = {
    subProto => 'setLayoutCache(mode)',
    sciProto => 'SCI_SETLAYOUTCACHE',
};

=item editor()->getLayoutCache() → int

Retrieve the degree of caching of layout information.

See Scintilla documentation for  L<SCI_GETLAYOUTCACHE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLAYOUTCACHE>

=cut

$autogen{SCI_GETLAYOUTCACHE} = {
    subProto => 'getLayoutCache() → int',
    sciProto => 'SCI_GETLAYOUTCACHE',
};

=item editor()->setPositionCache(size)

Set number of entries in position cache

See Scintilla documentation for  L<SCI_SETPOSITIONCACHE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPOSITIONCACHE>

=cut

$autogen{SCI_SETPOSITIONCACHE} = {
    subProto => 'setPositionCache(size)',
    sciProto => 'SCI_SETPOSITIONCACHE',
};

=item editor()->getPositionCache() → int

How many entries are allocated to the position cache?

See Scintilla documentation for  L<SCI_GETPOSITIONCACHE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPOSITIONCACHE>

=cut

$autogen{SCI_GETPOSITIONCACHE} = {
    subProto => 'getPositionCache() → int',
    sciProto => 'SCI_GETPOSITIONCACHE',
};

=item editor()->linesSplit(pixelWidth)

Split the lines in the target into lines that are less wide than pixelWidth where possible.

See Scintilla documentation for  L<SCI_LINESSPLIT|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESSPLIT>

=cut

$autogen{SCI_LINESSPLIT} = {
    subProto => 'linesSplit(pixelWidth)',
    sciProto => 'SCI_LINESSPLIT',
};

=item editor()->linesJoin()

Join the lines in the target.

See Scintilla documentation for  L<SCI_LINESJOIN|https://www.scintilla.org/ScintillaDoc.html#SCI_LINESJOIN>

=cut

$autogen{SCI_LINESJOIN} = {
    subProto => 'linesJoin()',
    sciProto => 'SCI_LINESJOIN',
};

=item editor()->wrapCount(line) → int

The number of display lines needed to wrap a document line

See Scintilla documentation for  L<SCI_WRAPCOUNT|https://www.scintilla.org/ScintillaDoc.html#SCI_WRAPCOUNT>

=cut

$autogen{SCI_WRAPCOUNT} = {
    subProto => 'wrapCount(line) → int',
    sciProto => 'SCI_WRAPCOUNT',
};

=back

=head2 Zooming

=begin scintilla

SCI_ZOOMIN
SCI_ZOOMOUT
SCI_SETZOOM(int zoomInPoints)
SCI_GETZOOM → int

=end scintilla

=over

=item editor()->zoomIn()

Magnify the displayed text by increasing the sizes by 1 point.

See Scintilla documentation for  L<SCI_ZOOMIN|https://www.scintilla.org/ScintillaDoc.html#SCI_ZOOMIN>

=cut

$autogen{SCI_ZOOMIN} = {
    subProto => 'zoomIn()',
    sciProto => 'SCI_ZOOMIN',
};

=item editor()->zoomOut()

Make the displayed text smaller by decreasing the sizes by 1 point.

See Scintilla documentation for  L<SCI_ZOOMOUT|https://www.scintilla.org/ScintillaDoc.html#SCI_ZOOMOUT>

=cut

$autogen{SCI_ZOOMOUT} = {
    subProto => 'zoomOut()',
    sciProto => 'SCI_ZOOMOUT',
};

=item editor()->setZoom(zoom)

Set the zoom level. This number of points is added to the size of all fonts. It may be positive to magnify or negative to reduce.

See Scintilla documentation for  L<SCI_SETZOOM|https://www.scintilla.org/ScintillaDoc.html#SCI_SETZOOM>

=cut

$autogen{SCI_SETZOOM} = {
    subProto => 'setZoom(zoom)',
    sciProto => 'SCI_SETZOOM',
};

=item editor()->getZoom() → int

Retrieve the zoom level.

See Scintilla documentation for  L<SCI_GETZOOM|https://www.scintilla.org/ScintillaDoc.html#SCI_GETZOOM>

=cut

$autogen{SCI_GETZOOM} = {
    subProto => 'getZoom() → int',
    sciProto => 'SCI_GETZOOM',
};

=back

=head2 Long lines

=begin scintilla

SCI_SETEDGEMODE(int edgeMode)
SCI_GETEDGEMODE → int
SCI_SETEDGECOLUMN(position column)
SCI_GETEDGECOLUMN → position
SCI_SETEDGECOLOUR(colour edgeColour)
SCI_GETEDGECOLOUR → colour

SCI_MULTIEDGEADDLINE(position column, colour edgeColour)
SCI_MULTIEDGECLEARALL

=end scintilla

=over

=item editor()->getEdgeMode() → int

Retrieve the edge highlight mode.

See Scintilla documentation for  L<SCI_GETEDGEMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEDGEMODE>

=cut

$autogen{SCI_GETEDGEMODE} = {
    subProto => 'getEdgeMode() → int',
    sciProto => 'SCI_GETEDGEMODE',
};

=item editor()->setEdgeMode(mode)

The edge may be displayed by a line (EDGE_LINE) or by highlighting text that goes beyond it (EDGE_BACKGROUND) or not displayed at all (EDGE_NONE).

See Scintilla documentation for  L<SCI_SETEDGEMODE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEDGEMODE>

=cut

$autogen{SCI_SETEDGEMODE} = {
    subProto => 'setEdgeMode(mode)',
    sciProto => 'SCI_SETEDGEMODE',
};

=item editor()->getEdgeColumn() → int

Retrieve the column number which text should be kept within.

See Scintilla documentation for  L<SCI_GETEDGECOLUMN|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEDGECOLUMN>

=cut

$autogen{SCI_GETEDGECOLUMN} = {
    subProto => 'getEdgeColumn() → int',
    sciProto => 'SCI_GETEDGECOLUMN',
};

=item editor()->setEdgeColumn(column)

Set the column number of the edge. If text goes past the edge then it is highlighted.

See Scintilla documentation for  L<SCI_SETEDGECOLUMN|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEDGECOLUMN>

=cut

$autogen{SCI_SETEDGECOLUMN} = {
    subProto => 'setEdgeColumn(column)',
    sciProto => 'SCI_SETEDGECOLUMN',
};

=item editor()->getEdgeColour() → tuple

Retrieve the colour used in edge indication.

See Scintilla documentation for  L<SCI_GETEDGECOLOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_GETEDGECOLOUR>

=cut

$autogen{SCI_GETEDGECOLOUR} = {
    subProto => 'getEdgeColour() → tuple',
    sciProto => 'SCI_GETEDGECOLOUR',
};

=item editor()->setEdgeColour(edgeColour)

Change the colour used in edge indication.

See Scintilla documentation for  L<SCI_SETEDGECOLOUR|https://www.scintilla.org/ScintillaDoc.html#SCI_SETEDGECOLOUR>

=cut

$autogen{SCI_SETEDGECOLOUR} = {
    subProto => 'setEdgeColour(edgeColour)',
    sciProto => 'SCI_SETEDGECOLOUR',
};

=item editor()->SCI_MULTIEDGEADDLINE

TODO

See Scintilla documentation for  L<SCI_MULTIEDGEADDLINE|https://www.scintilla.org/ScintillaDoc.html#SCI_MULTIEDGEADDLINE>

=cut

$autogen{SCI_MULTIEDGEADDLINE} = {
    subProto => 'SCI_MULTIEDGEADDLINE',
    sciProto => 'SCI_MULTIEDGEADDLINE',
};

=item editor()->SCI_MULTIEDGECLEARALL

TODO

See Scintilla documentation for  L<SCI_MULTIEDGECLEARALL|https://www.scintilla.org/ScintillaDoc.html#SCI_MULTIEDGECLEARALL>

=cut

$autogen{SCI_MULTIEDGECLEARALL} = {
    subProto => 'SCI_MULTIEDGECLEARALL',
    sciProto => 'SCI_MULTIEDGECLEARALL',
};

=back

=head2 Accessibility

=begin scintilla

SCI_SETACCESSIBILITY(int accessibility)
SCI_GETACCESSIBILITY → int

=end scintilla

=over

=item editor()->SCI_SETACCESSIBILITY

TODO

See Scintilla documentation for  L<SCI_SETACCESSIBILITY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETACCESSIBILITY>

=cut

$autogen{SCI_SETACCESSIBILITY} = {
    subProto => 'SCI_SETACCESSIBILITY',
    sciProto => 'SCI_SETACCESSIBILITY',
};

=item editor()->SCI_GETACCESSIBILITY

TODO

See Scintilla documentation for  L<SCI_GETACCESSIBILITY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETACCESSIBILITY>

=cut

$autogen{SCI_GETACCESSIBILITY} = {
    subProto => 'SCI_GETACCESSIBILITY',
    sciProto => 'SCI_GETACCESSIBILITY',
};

=back

=head2 Lexer

=begin scintilla

SCI_SETLEXER(int lexer)
SCI_GETLEXER → int
SCI_SETLEXERLANGUAGE(<unused>, const char *language)
SCI_GETLEXERLANGUAGE(<unused>, char *language) → int
SCI_LOADLEXERLIBRARY(<unused>, const char *path)
SCI_COLOURISE(position start, position end)
SCI_CHANGELEXERSTATE(position start, position end) → int
SCI_PROPERTYNAMES(<unused>, char *names) → int
SCI_PROPERTYTYPE(const char *name) → int
SCI_DESCRIBEPROPERTY(const char *name, char *description) → int
SCI_SETPROPERTY(const char *key, const char *value)
SCI_GETPROPERTY(const char *key, char *value) → int
SCI_GETPROPERTYEXPANDED(const char *key, char *value) → int
SCI_GETPROPERTYINT(const char *key, int defaultValue) → int
SCI_DESCRIBEKEYWORDSETS(<unused>, char *descriptions) → int
SCI_SETKEYWORDS(int keyWordSet, const char *keyWords)
SCI_GETSUBSTYLEBASES(<unused>, char *styles) → int
SCI_DISTANCETOSECONDARYSTYLES → int
SCI_ALLOCATESUBSTYLES(int styleBase, int numberStyles) → int
SCI_FREESUBSTYLES
SCI_GETSUBSTYLESSTART(int styleBase) → int
SCI_GETSUBSTYLESLENGTH(int styleBase) → int
SCI_GETSTYLEFROMSUBSTYLE(int subStyle) → int
SCI_GETPRIMARYSTYLEFROMSTYLE(int style) → int
SCI_SETIDENTIFIERS(int style, const char *identifiers)
SCI_PRIVATELEXERCALL(int operation, pointer pointer) → pointer
SCI_GETNAMEDSTYLES → int
SCI_NAMEOFSTYLE(int style, char *name) → int
SCI_TAGSOFSTYLE(int style, char *tags) → int
SCI_DESCRIPTIONOFSTYLE(int style, char *description) → int

=end scintilla

=over

=item editor()->setLexer(lexer)

Set the lexing language of the document.

See Scintilla documentation for  L<SCI_SETLEXER|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLEXER>

=cut

$autogen{SCI_SETLEXER} = {
    subProto => 'setLexer(lexer)',
    sciProto => 'SCI_SETLEXER',
};

=item editor()->getLexer() → int

Retrieve the lexing language of the document.

See Scintilla documentation for  L<SCI_GETLEXER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLEXER>

=cut

$autogen{SCI_GETLEXER} = {
    subProto => 'getLexer() → int',
    sciProto => 'SCI_GETLEXER',
};

=item editor()->setLexerLanguage(language)

Set the lexing language of the document based on string name.

See Scintilla documentation for  L<SCI_SETLEXERLANGUAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_SETLEXERLANGUAGE>

=cut

$autogen{SCI_SETLEXERLANGUAGE} = {
    subProto => 'setLexerLanguage(language)',
    sciProto => 'SCI_SETLEXERLANGUAGE',
};

=item editor()->getLexerLanguage() → str

Retrieve the name of the lexer. Return the length of the text.

See Scintilla documentation for  L<SCI_GETLEXERLANGUAGE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETLEXERLANGUAGE>

=cut

$autogen{SCI_GETLEXERLANGUAGE} = {
    subProto => 'getLexerLanguage() → str',
    sciProto => 'SCI_GETLEXERLANGUAGE',
};

=item editor()->loadLexerLibrary(path)

Load a lexer library (dll / so).

See Scintilla documentation for  L<SCI_LOADLEXERLIBRARY|https://www.scintilla.org/ScintillaDoc.html#SCI_LOADLEXERLIBRARY>

=cut

$autogen{SCI_LOADLEXERLIBRARY} = {
    subProto => 'loadLexerLibrary(path)',
    sciProto => 'SCI_LOADLEXERLIBRARY',
};

=item editor()->colourise(start, end)

Colourise a segment of the document using the current lexing language.

See Scintilla documentation for  L<SCI_COLOURISE|https://www.scintilla.org/ScintillaDoc.html#SCI_COLOURISE>

=cut

$autogen{SCI_COLOURISE} = {
    subProto => 'colourise(start, end)',
    sciProto => 'SCI_COLOURISE',
};

=item editor()->changeLexerState(start, end) → int

Indicate that the internal state of a lexer has changed over a range and therefore there may be a need to redraw.

See Scintilla documentation for  L<SCI_CHANGELEXERSTATE|https://www.scintilla.org/ScintillaDoc.html#SCI_CHANGELEXERSTATE>

=cut

$autogen{SCI_CHANGELEXERSTATE} = {
    subProto => 'changeLexerState(start, end) → int',
    sciProto => 'SCI_CHANGELEXERSTATE',
};

=item editor()->propertyNames() → str

Retrieve a ‘\n’ separated list of properties understood by the current lexer.

See Scintilla documentation for  L<SCI_PROPERTYNAMES|https://www.scintilla.org/ScintillaDoc.html#SCI_PROPERTYNAMES>

=cut

$autogen{SCI_PROPERTYNAMES} = {
    subProto => 'propertyNames() → str',
    sciProto => 'SCI_PROPERTYNAMES',
};

=item editor()->propertyType(name) → int

Retrieve the type of a property.

See Scintilla documentation for  L<SCI_PROPERTYTYPE|https://www.scintilla.org/ScintillaDoc.html#SCI_PROPERTYTYPE>

=cut

$autogen{SCI_PROPERTYTYPE} = {
    subProto => 'propertyType(name) → int',
    sciProto => 'SCI_PROPERTYTYPE',
};

=item editor()->describeProperty() → str

Describe a property.

See Scintilla documentation for  L<SCI_DESCRIBEPROPERTY|https://www.scintilla.org/ScintillaDoc.html#SCI_DESCRIBEPROPERTY>

=cut

$autogen{SCI_DESCRIBEPROPERTY} = {
    subProto => 'describeProperty() → str',
    sciProto => 'SCI_DESCRIBEPROPERTY',
};

=item editor()->setProperty(key, value)

Set up a value that may be used by a lexer for some optional feature.

See Scintilla documentation for  L<SCI_SETPROPERTY|https://www.scintilla.org/ScintillaDoc.html#SCI_SETPROPERTY>

=cut

$autogen{SCI_SETPROPERTY} = {
    subProto => 'setProperty(key, value)',
    sciProto => 'SCI_SETPROPERTY',
};

=item editor()->getProperty(key) → str

Retrieve a “property” value previously set with SetProperty.

See Scintilla documentation for  L<SCI_GETPROPERTY|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPROPERTY>

=cut

$autogen{SCI_GETPROPERTY} = {
    subProto => 'getProperty(key) → str',
    sciProto => 'SCI_GETPROPERTY',
};

=item editor()->getPropertyExpanded(key) → str

Retrieve a “property” value previously set with SetProperty, with “$()” variable replacement on returned buffer.

See Scintilla documentation for  L<SCI_GETPROPERTYEXPANDED|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPROPERTYEXPANDED>

=cut

$autogen{SCI_GETPROPERTYEXPANDED} = {
    subProto => 'getPropertyExpanded(key) → str',
    sciProto => 'SCI_GETPROPERTYEXPANDED',
};

=item editor()->getPropertyInt(key) → int

Retrieve a “property” value previously set with SetProperty, interpreted as an int AFTER any “$()” variable replacement.

See Scintilla documentation for  L<SCI_GETPROPERTYINT|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPROPERTYINT>

=cut

$autogen{SCI_GETPROPERTYINT} = {
    subProto => 'getPropertyInt(key) → int',
    sciProto => 'SCI_GETPROPERTYINT',
};

=item editor()->describeKeyWordSets() → str

Retrieve a ‘\n’ separated list of descriptions of the keyword sets understood by the current lexer.

See Scintilla documentation for  L<SCI_DESCRIBEKEYWORDSETS|https://www.scintilla.org/ScintillaDoc.html#SCI_DESCRIBEKEYWORDSETS>

=cut

$autogen{SCI_DESCRIBEKEYWORDSETS} = {
    subProto => 'describeKeyWordSets() → str',
    sciProto => 'SCI_DESCRIBEKEYWORDSETS',
};

=item editor()->setKeyWords(keywordSet, keyWords)

Set up the key words used by the lexer.

See Scintilla documentation for  L<SCI_SETKEYWORDS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETKEYWORDS>

=cut

$autogen{SCI_SETKEYWORDS} = {
    subProto => 'setKeyWords(keywordSet, keyWords)',
    sciProto => 'SCI_SETKEYWORDS',
};

=item editor()->getSubStyleBases() → str

Get the set of base styles that can be extended with sub styles

See Scintilla documentation for  L<SCI_GETSUBSTYLEBASES|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSUBSTYLEBASES>

=cut

$autogen{SCI_GETSUBSTYLEBASES} = {
    subProto => 'getSubStyleBases() → str',
    sciProto => 'SCI_GETSUBSTYLEBASES',
};

=item editor()->distanceToSecondaryStyles() → int

Where styles are duplicated by a feature such as active/inactive code return the distance between the two types.

See Scintilla documentation for  L<SCI_DISTANCETOSECONDARYSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_DISTANCETOSECONDARYSTYLES>

=cut

$autogen{SCI_DISTANCETOSECONDARYSTYLES} = {
    subProto => 'distanceToSecondaryStyles() → int',
    sciProto => 'SCI_DISTANCETOSECONDARYSTYLES',
};

=item editor()->allocateSubStyles(styleBase, numberStyles) → int

Allocate a set of sub styles for a particular base style, returning start of range

See Scintilla documentation for  L<SCI_ALLOCATESUBSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_ALLOCATESUBSTYLES>

=cut

$autogen{SCI_ALLOCATESUBSTYLES} = {
    subProto => 'allocateSubStyles(styleBase, numberStyles) → int',
    sciProto => 'SCI_ALLOCATESUBSTYLES',
};

=item editor()->freeSubStyles()

Free allocated sub styles

See Scintilla documentation for  L<SCI_FREESUBSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_FREESUBSTYLES>

=cut

$autogen{SCI_FREESUBSTYLES} = {
    subProto => 'freeSubStyles()',
    sciProto => 'SCI_FREESUBSTYLES',
};

=item editor()->getSubStylesStart(styleBase) → int

The starting style number for the sub styles associated with a base style

See Scintilla documentation for  L<SCI_GETSUBSTYLESSTART|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSUBSTYLESSTART>

=cut

$autogen{SCI_GETSUBSTYLESSTART} = {
    subProto => 'getSubStylesStart(styleBase) → int',
    sciProto => 'SCI_GETSUBSTYLESSTART',
};

=item editor()->getSubStylesLength(styleBase) → int

The number of sub styles associated with a base style

See Scintilla documentation for  L<SCI_GETSUBSTYLESLENGTH|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSUBSTYLESLENGTH>

=cut

$autogen{SCI_GETSUBSTYLESLENGTH} = {
    subProto => 'getSubStylesLength(styleBase) → int',
    sciProto => 'SCI_GETSUBSTYLESLENGTH',
};

=item editor()->getStyleFromSubStyle(subStyle) → int

For a sub style, return the base style, else return the argument.

See Scintilla documentation for  L<SCI_GETSTYLEFROMSUBSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETSTYLEFROMSUBSTYLE>

=cut

$autogen{SCI_GETSTYLEFROMSUBSTYLE} = {
    subProto => 'getStyleFromSubStyle(subStyle) → int',
    sciProto => 'SCI_GETSTYLEFROMSUBSTYLE',
};

=item editor()->getPrimaryStyleFromStyle(style) → int

For a secondary style, return the primary style, else return the argument.

See Scintilla documentation for  L<SCI_GETPRIMARYSTYLEFROMSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_GETPRIMARYSTYLEFROMSTYLE>

=cut

$autogen{SCI_GETPRIMARYSTYLEFROMSTYLE} = {
    subProto => 'getPrimaryStyleFromStyle(style) → int',
    sciProto => 'SCI_GETPRIMARYSTYLEFROMSTYLE',
};

=item editor()->setIdentifiers(style, identifiers)

Set the identifiers that are shown in a particular style

See Scintilla documentation for  L<SCI_SETIDENTIFIERS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETIDENTIFIERS>

=cut

$autogen{SCI_SETIDENTIFIERS} = {
    subProto => 'setIdentifiers(style, identifiers)',
    sciProto => 'SCI_SETIDENTIFIERS',
};

=item editor()->privateLexerCall(operation, pointer) → int

For private communication between an application and a known lexer.

See Scintilla documentation for  L<SCI_PRIVATELEXERCALL|https://www.scintilla.org/ScintillaDoc.html#SCI_PRIVATELEXERCALL>

=cut

$autogen{SCI_PRIVATELEXERCALL} = {
    subProto => 'privateLexerCall(operation, pointer) → int',
    sciProto => 'SCI_PRIVATELEXERCALL',
};

=item editor()->SCI_GETNAMEDSTYLES

TODO

See Scintilla documentation for  L<SCI_GETNAMEDSTYLES|https://www.scintilla.org/ScintillaDoc.html#SCI_GETNAMEDSTYLES>

=cut

$autogen{SCI_GETNAMEDSTYLES} = {
    subProto => 'SCI_GETNAMEDSTYLES',
    sciProto => 'SCI_GETNAMEDSTYLES',
};

=item editor()->SCI_NAMEOFSTYLE

TODO

See Scintilla documentation for  L<SCI_NAMEOFSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_NAMEOFSTYLE>

=cut

$autogen{SCI_NAMEOFSTYLE} = {
    subProto => 'SCI_NAMEOFSTYLE',
    sciProto => 'SCI_NAMEOFSTYLE',
};

=item editor()->SCI_TAGSOFSTYLE

TODO

See Scintilla documentation for  L<SCI_TAGSOFSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_TAGSOFSTYLE>

=cut

$autogen{SCI_TAGSOFSTYLE} = {
    subProto => 'SCI_TAGSOFSTYLE',
    sciProto => 'SCI_TAGSOFSTYLE',
};

=item editor()->SCI_DESCRIPTIONOFSTYLE

TODO

See Scintilla documentation for  L<SCI_DESCRIPTIONOFSTYLE|https://www.scintilla.org/ScintillaDoc.html#SCI_DESCRIPTIONOFSTYLE>

=cut

$autogen{SCI_DESCRIPTIONOFSTYLE} = {
    subProto => 'SCI_DESCRIPTIONOFSTYLE',
    sciProto => 'SCI_DESCRIPTIONOFSTYLE',
};

=back

=head2 Notifications

=begin scintilla

SCN_STYLENEEDED
SCN_CHARADDED
SCN_SAVEPOINTREACHED
SCN_SAVEPOINTLEFT
SCN_MODIFYATTEMPTRO
SCN_KEY
SCN_DOUBLECLICK
SCN_UPDATEUI
SCN_MODIFIED
SCN_MACRORECORD
SCN_MARGINCLICK
SCN_NEEDSHOWN
SCN_PAINTED
SCN_USERLISTSELECTION
SCN_URIDROPPED
SCN_DWELLSTART
SCN_DWELLEND
SCN_ZOOM
SCN_HOTSPOTCLICK
SCN_HOTSPOTDOUBLECLICK
SCN_HOTSPOTRELEASECLICK
SCN_INDICATORCLICK
SCN_INDICATORRELEASE
SCN_CALLTIPCLICK
SCN_AUTOCSELECTION
SCN_AUTOCCANCELLED
SCN_AUTOCCHARDELETED
SCN_FOCUSIN
SCN_FOCUSOUT
SCN_AUTOCCOMPLETED
SCN_MARGINRIGHTCLICK
SCN_AUTOCSELECTIONCHANGE

SCI_SETMODEVENTMASK(int eventMask)
SCI_GETMODEVENTMASK → int
SCI_SETCOMMANDEVENTS(bool commandEvents)
SCI_GETCOMMANDEVENTS → bool
SCI_SETMOUSEDWELLTIME(int periodMilliseconds)
SCI_GETMOUSEDWELLTIME → int
SCI_SETIDENTIFIER(int identifier)
SCI_GETIDENTIFIER → int

SCEN_CHANGE
SCEN_SETFOCUS
SCEN_KILLFOCUS

=end scintilla

=over

=item editor()->setModEventMask(mask)

Set which document modification events are sent to the container.

See Scintilla documentation for  L<SCI_SETMODEVENTMASK|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMODEVENTMASK>

=cut

$autogen{SCI_SETMODEVENTMASK} = {
    subProto => 'setModEventMask(mask)',
    sciProto => 'SCI_SETMODEVENTMASK',
};

=item editor()->getModEventMask() → int

Get which document modification events are sent to the container.

See Scintilla documentation for  L<SCI_GETMODEVENTMASK|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMODEVENTMASK>

=cut

$autogen{SCI_GETMODEVENTMASK} = {
    subProto => 'getModEventMask() → int',
    sciProto => 'SCI_GETMODEVENTMASK',
};

=item editor()->SCI_SETCOMMANDEVENTS

TODO

See Scintilla documentation for  L<SCI_SETCOMMANDEVENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_SETCOMMANDEVENTS>

=cut

$autogen{SCI_SETCOMMANDEVENTS} = {
    subProto => 'SCI_SETCOMMANDEVENTS',
    sciProto => 'SCI_SETCOMMANDEVENTS',
};

=item editor()->SCI_GETCOMMANDEVENTS

TODO

See Scintilla documentation for  L<SCI_GETCOMMANDEVENTS|https://www.scintilla.org/ScintillaDoc.html#SCI_GETCOMMANDEVENTS>

=cut

$autogen{SCI_GETCOMMANDEVENTS} = {
    subProto => 'SCI_GETCOMMANDEVENTS',
    sciProto => 'SCI_GETCOMMANDEVENTS',
};

=item editor()->setMouseDwellTime(periodMilliseconds)

Sets the time the mouse must sit still to generate a mouse dwell event.

See Scintilla documentation for  L<SCI_SETMOUSEDWELLTIME|https://www.scintilla.org/ScintillaDoc.html#SCI_SETMOUSEDWELLTIME>

=cut

$autogen{SCI_SETMOUSEDWELLTIME} = {
    subProto => 'setMouseDwellTime(periodMilliseconds)',
    sciProto => 'SCI_SETMOUSEDWELLTIME',
};

=item editor()->getMouseDwellTime() → int

Retrieve the time the mouse must sit still to generate a mouse dwell event.

See Scintilla documentation for  L<SCI_GETMOUSEDWELLTIME|https://www.scintilla.org/ScintillaDoc.html#SCI_GETMOUSEDWELLTIME>

=cut

$autogen{SCI_GETMOUSEDWELLTIME} = {
    subProto => 'getMouseDwellTime() → int',
    sciProto => 'SCI_GETMOUSEDWELLTIME',
};

=item editor()->setIdentifier(identifier)

Set the identifier reported as idFrom in notification messages.

See Scintilla documentation for  L<SCI_SETIDENTIFIER|https://www.scintilla.org/ScintillaDoc.html#SCI_SETIDENTIFIER>

=cut

$autogen{SCI_SETIDENTIFIER} = {
    subProto => 'setIdentifier(identifier)',
    sciProto => 'SCI_SETIDENTIFIER',
};

=item editor()->getIdentifier() → int

Get the identifier.

See Scintilla documentation for  L<SCI_GETIDENTIFIER|https://www.scintilla.org/ScintillaDoc.html#SCI_GETIDENTIFIER>

=cut

$autogen{SCI_GETIDENTIFIER} = {
    subProto => 'getIdentifier() → int',
    sciProto => 'SCI_GETIDENTIFIER',
};

=item editor()->research(...)

TODO: need to grab the docs for .research(), .pyreplace, .pymlreplace, .pysearch, .pymnlsearch again

=back

=head1 INSTALLATION

Installed as part of L<Win32::Mechanize::NotepadPlusPlus>


=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Win32-Mechanize-NotepadPlusPlus AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-Mechanize-NotepadPlusPlus>,
or thru the repository's interface at L<https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues>.

=head1 COPYRIGHT

Copyright (C) 2018,2019 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
