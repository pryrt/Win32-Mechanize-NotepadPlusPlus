package Win32::Mechanize::NotepadPlusPlus::Editor;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use Carp;
use Win32::Mechanize::NotepadPlusPlus::__hwnd;

use Data::Dumper; $Data::Dumper::Useqq++;


our $VERSION = '0.000001';  # TODO = make this automatically the same version as NotepadPlusPlus.pm

=pod

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

=head1 PythonScript API

    Editor.getCharacterPointer() → str
    Gets a copy of the text of the document, without first allowing Scintilla to make it’s copy of it. In practice, that means it does exactly the same as Editor.getText, however, if you have the possibility of the user interfering with the document _whilst_ getCharacterPointer() is running, then it’s safer to use getText(). On larger documents, getCharacterPointer() could be noticable quicker.

    See Scintilla documentation for SCI_GETCHARACTERPOINTER

    Editor.addText(text) → int
    Add text to the document at current position.

    See Scintilla documentation for SCI_ADDTEXT

    Editor.addStyledText(c) → int
    Add array of cells to document.

    See Scintilla documentation for SCI_ADDSTYLEDTEXT

    Editor.insertText(pos, text)
    Insert string at a position.

    See Scintilla documentation for SCI_INSERTTEXT

    Editor.clearAll()
    Delete all text in the document.

    See Scintilla documentation for SCI_CLEARALL

    Editor.deleteRange(pos, deleteLength)
    Delete a range of text in the document.

    See Scintilla documentation for SCI_DELETERANGE

    Editor.clearDocumentStyle()
    Set all style bytes to 0, remove all folding information.

    See Scintilla documentation for SCI_CLEARDOCUMENTSTYLE

    Editor.getLength() → int
    Returns the number of bytes in the document.

    See Scintilla documentation for SCI_GETLENGTH

    Editor.getCharAt(pos) → int
    Returns the character byte at the position.

    See Scintilla documentation for SCI_GETCHARAT

    Editor.getCurrentPos() → int
    Returns the position of the caret.

    See Scintilla documentation for SCI_GETCURRENTPOS

    Editor.getAnchor() → int
    Returns the position of the opposite end of the selection to the caret.

    See Scintilla documentation for SCI_GETANCHOR

    Editor.getStyleAt(pos) → int
    Returns the style byte at the position.

    See Scintilla documentation for SCI_GETSTYLEAT

    Editor.redo()
    Redoes the next action on the undo history.

    See Scintilla documentation for SCI_REDO

    Editor.setUndoCollection(collectUndo)
    Choose between collecting actions into the undo history and discarding them.

    See Scintilla documentation for SCI_SETUNDOCOLLECTION

    Editor.selectAll()
    Select all the text in the document.

    See Scintilla documentation for SCI_SELECTALL

    Editor.setSavePoint()
    Remember the current position in the undo history as the position at which the document was saved.

    See Scintilla documentation for SCI_SETSAVEPOINT

    Editor.getStyledText(start, end) → tuple
    Retrieve a buffer of cells. Returns the number of bytes in the buffer not including terminating NULs.

    See Scintilla documentation for SCI_GETSTYLEDTEXT

    Editor.canRedo() → bool
    Are there any redoable actions in the undo history?

    See Scintilla documentation for SCI_CANREDO

    Editor.markerLineFromHandle(handle) → int
    Retrieve the line number at which a particular marker is located.

    See Scintilla documentation for SCI_MARKERLINEFROMHANDLE

    Editor.markerDeleteHandle(handle)
    Delete a marker.

    See Scintilla documentation for SCI_MARKERDELETEHANDLE

    Editor.getUndoCollection() → bool
    Is undo history being collected?

    See Scintilla documentation for SCI_GETUNDOCOLLECTION

    Editor.getViewWS() → int
    Are white space characters currently visible? Returns one of SCWS_* constants.

    See Scintilla documentation for SCI_GETVIEWWS

    Editor.setViewWS(viewWS)
    Make white space characters invisible, always visible or visible outside indentation.

    See Scintilla documentation for SCI_SETVIEWWS

    Editor.positionFromPoint(x, y) → int
    Find the position from a point within the window.

    See Scintilla documentation for SCI_POSITIONFROMPOINT

    Editor.positionFromPointClose(x, y) → int
    Find the position from a point within the window but return INVALID_POSITION if not close to text.

    See Scintilla documentation for SCI_POSITIONFROMPOINTCLOSE

    Editor.gotoLine(line)
    Set caret to start of a line and ensure it is visible.

    See Scintilla documentation for SCI_GOTOLINE

    Editor.gotoPos(pos)
    Set caret to a position and ensure it is visible.

    See Scintilla documentation for SCI_GOTOPOS

    Editor.setAnchor(posAnchor)
    Set the selection anchor to a position. The anchor is the opposite end of the selection from the caret.

    See Scintilla documentation for SCI_SETANCHOR

    Editor.getCurLine() → str
    Retrieve the text of the line containing the caret. Returns the index of the caret on the line.

    See Scintilla documentation for SCI_GETCURLINE

    Editor.getEndStyled() → int
    Retrieve the position of the last correctly styled character.

    See Scintilla documentation for SCI_GETENDSTYLED

    Editor.convertEOLs(eolMode)
    Convert all line endings in the document to one mode.

    See Scintilla documentation for SCI_CONVERTEOLS

    Editor.getEOLMode() → int
    Retrieve the current end of line mode - one of CRLF, CR, or LF.

    See Scintilla documentation for SCI_GETEOLMODE

    Editor.setEOLMode(eolMode)
    Set the current end of line mode.

    See Scintilla documentation for SCI_SETEOLMODE

    Editor.startStyling(pos, mask)
    Set the current styling position to pos and the styling mask to mask. The styling mask can be used to protect some bits in each styling byte from modification.

    See Scintilla documentation for SCI_STARTSTYLING

    Editor.setStyling(length, style)
    Change style from current styling position for length characters to a style and move the current styling position to after this newly styled segment.

    See Scintilla documentation for SCI_SETSTYLING

    Editor.getBufferedDraw() → bool
    Is drawing done first into a buffer or direct to the screen?

    See Scintilla documentation for SCI_GETBUFFEREDDRAW

    Editor.setBufferedDraw(buffered)
    If drawing is buffered then each line of text is drawn into a bitmap buffer before drawing it to the screen to avoid flicker.

    See Scintilla documentation for SCI_SETBUFFEREDDRAW

    Editor.setTabWidth(tabWidth)
    Change the visible size of a tab to be a multiple of the width of a space character.

    See Scintilla documentation for SCI_SETTABWIDTH

    Editor.getTabWidth() → int
    Retrieve the visible size of a tab.

    See Scintilla documentation for SCI_GETTABWIDTH

    Editor.setCodePage(codePage)
    Set the code page used to interpret the bytes of the document as characters. The SC_CP_UTF8 value can be used to enter Unicode mode.

    See Scintilla documentation for SCI_SETCODEPAGE

    Editor.markerDefine(markerNumber, markerSymbol)
    Set the symbol used for a particular marker number.

    See Scintilla documentation for SCI_MARKERDEFINE

    Editor.markerSetFore(markerNumber, fore)
    Set the foreground colour used for a particular marker number.

    See Scintilla documentation for SCI_MARKERSETFORE

    Editor.markerSetBack(markerNumber, back)
    Set the background colour used for a particular marker number.

    See Scintilla documentation for SCI_MARKERSETBACK

    Editor.markerSetBackSelected(markerNumber, back)
    Set the background colour used for a particular marker number when its folding block is selected.

    See Scintilla documentation for SCI_MARKERSETBACKSELECTED

    Editor.markerEnableHighlight(enabled)
    Enable/disable highlight for current folding bloc (smallest one that contains the caret)

    See Scintilla documentation for SCI_MARKERENABLEHIGHLIGHT

    Editor.markerAdd(line, markerNumber) → int
    Add a marker to a line, returning an ID which can be used to find or delete the marker.

    See Scintilla documentation for SCI_MARKERADD

    Editor.markerDelete(line, markerNumber)
    Delete a marker from a line.

    See Scintilla documentation for SCI_MARKERDELETE

    Editor.markerDeleteAll(markerNumber)
    Delete all markers with a particular number from all lines.

    See Scintilla documentation for SCI_MARKERDELETEALL

    Editor.markerGet(line) → int
    Get a bit mask of all the markers set on a line.

    See Scintilla documentation for SCI_MARKERGET

    Editor.markerNext(lineStart, markerMask) → int
    Find the next line at or after lineStart that includes a marker in mask. Return -1 when no more lines.

    See Scintilla documentation for SCI_MARKERNEXT

    Editor.markerPrevious(lineStart, markerMask) → int
    Find the previous line before lineStart that includes a marker in mask.

    See Scintilla documentation for SCI_MARKERPREVIOUS

    Editor.markerDefinePixmap(markerNumber, pixmap)
    Define a marker from a pixmap.

    See Scintilla documentation for SCI_MARKERDEFINEPIXMAP

    Editor.markerAddSet(line, set)
    Add a set of markers to a line.

    See Scintilla documentation for SCI_MARKERADDSET

    Editor.markerSetAlpha(markerNumber, alpha)
    Set the alpha used for a marker that is drawn in the text area, not the margin.

    See Scintilla documentation for SCI_MARKERSETALPHA

    Editor.setMarginTypeN(margin, marginType)
    Set a margin to be either numeric or symbolic.

    See Scintilla documentation for SCI_SETMARGINTYPEN

    Editor.getMarginTypeN(margin) → int
    Retrieve the type of a margin.

    See Scintilla documentation for SCI_GETMARGINTYPEN

    Editor.setMarginWidthN(margin, pixelWidth)
    Set the width of a margin to a width expressed in pixels.

    See Scintilla documentation for SCI_SETMARGINWIDTHN

    Editor.getMarginWidthN(margin) → int
    Retrieve the width of a margin in pixels.

    See Scintilla documentation for SCI_GETMARGINWIDTHN

    Editor.setMarginMaskN(margin, mask)
    Set a mask that determines which markers are displayed in a margin.

    See Scintilla documentation for SCI_SETMARGINMASKN

    Editor.getMarginMaskN(margin) → int
    Retrieve the marker mask of a margin.

    See Scintilla documentation for SCI_GETMARGINMASKN

    Editor.setMarginSensitiveN(margin, sensitive)
    Make a margin sensitive or insensitive to mouse clicks.

    See Scintilla documentation for SCI_SETMARGINSENSITIVEN

    Editor.getMarginSensitiveN(margin) → bool
    Retrieve the mouse click sensitivity of a margin.

    See Scintilla documentation for SCI_GETMARGINSENSITIVEN

    Editor.setMarginCursorN(margin, cursor)
    Set the cursor shown when the mouse is inside a margin.

    See Scintilla documentation for SCI_SETMARGINCURSORN

    Editor.getMarginCursorN(margin) → int
    Retrieve the cursor shown in a margin.

    See Scintilla documentation for SCI_GETMARGINCURSORN

    Editor.styleClearAll()
    Clear all the styles and make equivalent to the global default style.

    See Scintilla documentation for SCI_STYLECLEARALL

    Editor.styleSetFore(style, fore)
    Set the foreground colour of a style.

    See Scintilla documentation for SCI_STYLESETFORE

    Editor.styleSetBack(style, back)
    Set the background colour of a style.

    See Scintilla documentation for SCI_STYLESETBACK

    Editor.styleSetBold(style, bold)
    Set a style to be bold or not.

    See Scintilla documentation for SCI_STYLESETBOLD

    Editor.styleSetItalic(style, italic)
    Set a style to be italic or not.

    See Scintilla documentation for SCI_STYLESETITALIC

    Editor.styleSetSize(style, sizePoints)
    Set the size of characters of a style.

    See Scintilla documentation for SCI_STYLESETSIZE

    Editor.styleSetFont(style, fontName)
    Set the font of a style.

    See Scintilla documentation for SCI_STYLESETFONT

    Editor.styleSetEOLFilled(style, filled)
    Set a style to have its end of line filled or not.

    See Scintilla documentation for SCI_STYLESETEOLFILLED

    Editor.styleResetDefault()
    Reset the default style to its state at startup

    See Scintilla documentation for SCI_STYLERESETDEFAULT

    Editor.styleSetUnderline(style, underline)
    Set a style to be underlined or not.

    See Scintilla documentation for SCI_STYLESETUNDERLINE

    Editor.styleGetFore(style) → tuple
    Get the foreground colour of a style.

    See Scintilla documentation for SCI_STYLEGETFORE

    Editor.styleGetBack(style) → tuple
    Get the background colour of a style.

    See Scintilla documentation for SCI_STYLEGETBACK

    Editor.styleGetBold(style) → bool
    Get is a style bold or not.

    See Scintilla documentation for SCI_STYLEGETBOLD

    Editor.styleGetItalic(style) → bool
    Get is a style italic or not.

    See Scintilla documentation for SCI_STYLEGETITALIC

    Editor.styleGetSize(style) → int
    Get the size of characters of a style.

    See Scintilla documentation for SCI_STYLEGETSIZE

    Editor.styleGetFont(style) → str
    Get the font of a style. Returns the length of the fontName

    See Scintilla documentation for SCI_STYLEGETFONT

    Editor.styleGetEOLFilled(style) → bool
    Get is a style to have its end of line filled or not.

    See Scintilla documentation for SCI_STYLEGETEOLFILLED

    Editor.styleGetUnderline(style) → bool
    Get is a style underlined or not.

    See Scintilla documentation for SCI_STYLEGETUNDERLINE

    Editor.styleGetCase(style) → int
    Get is a style mixed case, or to force upper or lower case.

    See Scintilla documentation for SCI_STYLEGETCASE

    Editor.styleGetCharacterSet(style) → int
    Get the character get of the font in a style.

    See Scintilla documentation for SCI_STYLEGETCHARACTERSET

    Editor.styleGetVisible(style) → bool
    Get is a style visible or not.

    See Scintilla documentation for SCI_STYLEGETVISIBLE

    Editor.styleGetChangeable(style) → bool
    Get is a style changeable or not (read only). Experimental feature, currently buggy.

    See Scintilla documentation for SCI_STYLEGETCHANGEABLE

    Editor.styleGetHotSpot(style) → bool
    Get is a style a hotspot or not.

    See Scintilla documentation for SCI_STYLEGETHOTSPOT

    Editor.styleSetCase(style, caseForce)
    Set a style to be mixed case, or to force upper or lower case.

    See Scintilla documentation for SCI_STYLESETCASE

    Editor.styleSetSizeFractional(style, caseForce)
    Set the size of characters of a style. Size is in points multiplied by 100.

    See Scintilla documentation for SCI_STYLESETSIZEFRACTIONAL

    Editor.styleGetSizeFractional(style) → int
    Get the size of characters of a style in points multiplied by 100

    See Scintilla documentation for SCI_STYLEGETSIZEFRACTIONAL

    Editor.styleSetWeight(style, weight)
    Set the weight of characters of a style.

    See Scintilla documentation for SCI_STYLESETWEIGHT

    Editor.styleGetWeight(style) → int
    Get the weight of characters of a style.

    See Scintilla documentation for SCI_STYLEGETWEIGHT

    Editor.styleSetCharacterSet(style, characterSet)
    Set the character set of the font in a style.

    See Scintilla documentation for SCI_STYLESETCHARACTERSET

    Editor.styleSetHotSpot(style, hotspot)
    Set a style to be a hotspot or not.

    See Scintilla documentation for SCI_STYLESETHOTSPOT

    Editor.setSelFore(useSetting, fore)
    Set the foreground colour of the main and additional selections and whether to use this setting.

    See Scintilla documentation for SCI_SETSELFORE

    Editor.setSelBack(useSetting, back)
    Set the background colour of the main and additional selections and whether to use this setting.

    See Scintilla documentation for SCI_SETSELBACK

    Editor.getSelAlpha() → int
    Get the alpha of the selection.

    See Scintilla documentation for SCI_GETSELALPHA

    Editor.setSelAlpha(alpha)
    Set the alpha of the selection.

    See Scintilla documentation for SCI_SETSELALPHA

    Editor.getSelEOLFilled() → bool
    Is the selection end of line filled?

    See Scintilla documentation for SCI_GETSELEOLFILLED

    Editor.setSelEOLFilled(filled)
    Set the selection to have its end of line filled or not.

    See Scintilla documentation for SCI_SETSELEOLFILLED

    Editor.setCaretFore(fore)
    Set the foreground colour of the caret.

    See Scintilla documentation for SCI_SETCARETFORE

    Editor.assignCmdKey(km, msg)
    When key+modifier combination km is pressed perform msg.

    See Scintilla documentation for SCI_ASSIGNCMDKEY

    Editor.clearCmdKey(km)
    When key+modifier combination km is pressed do nothing.

    See Scintilla documentation for SCI_CLEARCMDKEY

    Editor.clearAllCmdKeys()
    Drop all key mappings.

    See Scintilla documentation for SCI_CLEARALLCMDKEYS

    Editor.setStylingEx(styles) → int
    Set the styles for a segment of the document.

    See Scintilla documentation for SCI_SETSTYLINGEX

    Editor.styleSetVisible(style, visible)
    Set a style to be visible or not.

    See Scintilla documentation for SCI_STYLESETVISIBLE

    Editor.getCaretPeriod() → int
    Get the time in milliseconds that the caret is on and off.

    See Scintilla documentation for SCI_GETCARETPERIOD

    Editor.setCaretPeriod(periodMilliseconds)
    Get the time in milliseconds that the caret is on and off. 0 = steady on.

    See Scintilla documentation for SCI_SETCARETPERIOD

    Editor.setWordChars(characters)
    Set the set of characters making up words for when moving or selecting by word. First sets defaults like SetCharsDefault.

    See Scintilla documentation for SCI_SETWORDCHARS

    Editor.getWordChars() → str
    Get the set of characters making up words for when moving or selecting by word. Retuns the number of characters

    See Scintilla documentation for SCI_GETWORDCHARS

    Editor.beginUndoAction()
    Start a sequence of actions that is undone and redone as a unit. May be nested.

    See Scintilla documentation for SCI_BEGINUNDOACTION

    Editor.endUndoAction()
    End a sequence of actions that is undone and redone as a unit.

    See Scintilla documentation for SCI_ENDUNDOACTION

    Editor.indicSetStyle(indic, style)
    Set an indicator to plain, squiggle or TT.

    See Scintilla documentation for SCI_INDICSETSTYLE

    Editor.indicGetStyle(indic) → int
    Retrieve the style of an indicator.

    See Scintilla documentation for SCI_INDICGETSTYLE

    Editor.indicSetFore(indic, fore)
    Set the foreground colour of an indicator.

    See Scintilla documentation for SCI_INDICSETFORE

    Editor.indicGetFore(indic) → tuple
    Retrieve the foreground colour of an indicator.

    See Scintilla documentation for SCI_INDICGETFORE

    Editor.indicSetUnder(indic, under)
    Set an indicator to draw under text or over(default).

    See Scintilla documentation for SCI_INDICSETUNDER

    Editor.indicGetUnder(indic) → bool
    Retrieve whether indicator drawn under or over text.

    See Scintilla documentation for SCI_INDICGETUNDER

    Editor.setWhitespaceFore(useSetting, fore)
    Set the foreground colour of all whitespace and whether to use this setting.

    See Scintilla documentation for SCI_SETWHITESPACEFORE

    Editor.setWhitespaceBack(useSetting, back)
    Set the background colour of all whitespace and whether to use this setting.

    See Scintilla documentation for SCI_SETWHITESPACEBACK

    Editor.setWhitespaceSize(size)
    Set the size of the dots used to mark space characters.

    See Scintilla documentation for SCI_SETWHITESPACESIZE

    Editor.getWhitespaceSize() → int
    Get the size of the dots used to mark space characters.

    See Scintilla documentation for SCI_GETWHITESPACESIZE

    Editor.setStyleBits(bits)
    Divide each styling byte into lexical class bits (default: 5) and indicator bits (default: 3). If a lexer requires more than 32 lexical states, then this is used to expand the possible states.

    See Scintilla documentation for SCI_SETSTYLEBITS

    Editor.getStyleBits() → int
    Retrieve number of bits in style bytes used to hold the lexical state.

    See Scintilla documentation for SCI_GETSTYLEBITS

    Editor.setLineState(line, state)
    Used to hold extra styling information for each line.

    See Scintilla documentation for SCI_SETLINESTATE

    Editor.getLineState(line) → int
    Retrieve the extra styling information for a line.

    See Scintilla documentation for SCI_GETLINESTATE

    Editor.getMaxLineState() → int
    Retrieve the last line number that has line state.

    See Scintilla documentation for SCI_GETMAXLINESTATE

    Editor.getCaretLineVisible() → bool
    Is the background of the line containing the caret in a different colour?

    See Scintilla documentation for SCI_GETCARETLINEVISIBLE

    Editor.setCaretLineVisible(show)
    Display the background of the line containing the caret in a different colour.

    See Scintilla documentation for SCI_SETCARETLINEVISIBLE

    Editor.getCaretLineBack() → tuple
    Get the colour of the background of the line containing the caret.

    See Scintilla documentation for SCI_GETCARETLINEBACK

    Editor.setCaretLineBack(back)
    Set the colour of the background of the line containing the caret.

    See Scintilla documentation for SCI_SETCARETLINEBACK

    Editor.styleSetChangeable(style, changeable)
    Set a style to be changeable or not (read only). Experimental feature, currently buggy.

    See Scintilla documentation for SCI_STYLESETCHANGEABLE

    Editor.autoCShow(lenEntered, itemList)
    Display a auto-completion list. The lenEntered parameter indicates how many characters before the caret should be used to provide context.

    See Scintilla documentation for SCI_AUTOCSHOW

    Editor.autoCCancel()
    Remove the auto-completion list from the screen.

    See Scintilla documentation for SCI_AUTOCCANCEL

    Editor.autoCActive() → bool
    Is there an auto-completion list visible?

    See Scintilla documentation for SCI_AUTOCACTIVE

    Editor.autoCPosStart() → int
    Retrieve the position of the caret when the auto-completion list was displayed.

    See Scintilla documentation for SCI_AUTOCPOSSTART

    Editor.autoCComplete()
    User has selected an item so remove the list and insert the selection.

    See Scintilla documentation for SCI_AUTOCCOMPLETE

    Editor.autoCStops(characterSet)
    Define a set of character that when typed cancel the auto-completion list.

    See Scintilla documentation for SCI_AUTOCSTOPS

    Editor.autoCSetSeparator(separatorCharacter)
    Change the separator character in the string setting up an auto-completion list. Default is space but can be changed if items contain space.

    See Scintilla documentation for SCI_AUTOCSETSEPARATOR

    Editor.autoCGetSeparator() → int
    Retrieve the auto-completion list separator character.

    See Scintilla documentation for SCI_AUTOCGETSEPARATOR

    Editor.autoCSelect(text)
    Select the item in the auto-completion list that starts with a string.

    See Scintilla documentation for SCI_AUTOCSELECT

    Editor.autoCSetCancelAtStart(cancel)
    Should the auto-completion list be cancelled if the user backspaces to a position before where the box was created.

    See Scintilla documentation for SCI_AUTOCSETCANCELATSTART

    Editor.autoCGetCancelAtStart() → bool
    Retrieve whether auto-completion cancelled by backspacing before start.

    See Scintilla documentation for SCI_AUTOCGETCANCELATSTART

    Editor.autoCSetFillUps(characterSet)
    Define a set of characters that when typed will cause the autocompletion to choose the selected item.

    See Scintilla documentation for SCI_AUTOCSETFILLUPS

    Editor.autoCSetChooseSingle(chooseSingle)
    Should a single item auto-completion list automatically choose the item.

    See Scintilla documentation for SCI_AUTOCSETCHOOSESINGLE

    Editor.autoCGetChooseSingle() → bool
    Retrieve whether a single item auto-completion list automatically choose the item.

    See Scintilla documentation for SCI_AUTOCGETCHOOSESINGLE

    Editor.autoCSetIgnoreCase(ignoreCase)
    Set whether case is significant when performing auto-completion searches.

    See Scintilla documentation for SCI_AUTOCSETIGNORECASE

    Editor.autoCGetIgnoreCase() → bool
    Retrieve state of ignore case flag.

    See Scintilla documentation for SCI_AUTOCGETIGNORECASE

    Editor.userListShow(listType, itemList)
    Display a list of strings and send notification when user chooses one.

    See Scintilla documentation for SCI_USERLISTSHOW

    Editor.autoCSetAutoHide(autoHide)
    Set whether or not autocompletion is hidden automatically when nothing matches.

    See Scintilla documentation for SCI_AUTOCSETAUTOHIDE

    Editor.autoCGetAutoHide() → bool
    Retrieve whether or not autocompletion is hidden automatically when nothing matches.

    See Scintilla documentation for SCI_AUTOCGETAUTOHIDE

    Editor.autoCSetDropRestOfWord(dropRestOfWord)
    Set whether or not autocompletion deletes any word characters after the inserted text upon completion.

    See Scintilla documentation for SCI_AUTOCSETDROPRESTOFWORD

    Editor.autoCGetDropRestOfWord() → bool
    Retrieve whether or not autocompletion deletes any word characters after the inserted text upon completion.

    See Scintilla documentation for SCI_AUTOCGETDROPRESTOFWORD

    Editor.registerImage(type, xpmData)
    Register an XPM image for use in autocompletion lists.

    See Scintilla documentation for SCI_REGISTERIMAGE

    Editor.clearRegisteredImages()
    Clear all the registered XPM images.

    See Scintilla documentation for SCI_CLEARREGISTEREDIMAGES

    Editor.autoCGetTypeSeparator() → int
    Retrieve the auto-completion list type-separator character.

    See Scintilla documentation for SCI_AUTOCGETTYPESEPARATOR

    Editor.autoCSetTypeSeparator(separatorCharacter)
    Change the type-separator character in the string setting up an auto-completion list. Default is ‘?’ but can be changed if items contain ‘?’.

    See Scintilla documentation for SCI_AUTOCSETTYPESEPARATOR

    Editor.autoCSetMaxWidth(characterCount)
    Set the maximum width, in characters, of auto-completion and user lists. Set to 0 to autosize to fit longest item, which is the default.

    See Scintilla documentation for SCI_AUTOCSETMAXWIDTH

    Editor.autoCGetMaxWidth() → int
    Get the maximum width, in characters, of auto-completion and user lists.

    See Scintilla documentation for SCI_AUTOCGETMAXWIDTH

    Editor.autoCSetMaxHeight(rowCount)
    Set the maximum height, in rows, of auto-completion and user lists. The default is 5 rows.

    See Scintilla documentation for SCI_AUTOCSETMAXHEIGHT

    Editor.autoCGetMaxHeight() → int
    Set the maximum height, in rows, of auto-completion and user lists.

    See Scintilla documentation for SCI_AUTOCGETMAXHEIGHT

    Editor.setIndent(indentSize)
    Set the number of spaces used for one level of indentation.

    See Scintilla documentation for SCI_SETINDENT

    Editor.getIndent() → int
    Retrieve indentation size.

    See Scintilla documentation for SCI_GETINDENT

    Editor.setUseTabs(useTabs)
    Indentation will only use space characters if useTabs is false, otherwise it will use a combination of tabs and spaces.

    See Scintilla documentation for SCI_SETUSETABS

    Editor.getUseTabs() → bool
    Retrieve whether tabs will be used in indentation.

    See Scintilla documentation for SCI_GETUSETABS

    Editor.setLineIndentation(line, indentSize)
    Change the indentation of a line to a number of columns.

    See Scintilla documentation for SCI_SETLINEINDENTATION

    Editor.getLineIndentation(line) → int
    Retrieve the number of columns that a line is indented.

    See Scintilla documentation for SCI_GETLINEINDENTATION

    Editor.getLineIndentPosition(line) → int
    Retrieve the position before the first non indentation character on a line.

    See Scintilla documentation for SCI_GETLINEINDENTPOSITION

    Editor.getColumn(pos) → int
    Retrieve the column number of a position, taking tab width into account.

    See Scintilla documentation for SCI_GETCOLUMN

    Editor.countCharacters(startPos, endPos) → int
    Count characters between two positions.

    See Scintilla documentation for SCI_COUNTCHARACTERS

    Editor.setHScrollBar(show)
    Show or hide the horizontal scroll bar.

    See Scintilla documentation for SCI_SETHSCROLLBAR

    Editor.getHScrollBar() → bool
    Is the horizontal scroll bar visible?

    See Scintilla documentation for SCI_GETHSCROLLBAR

    Editor.setIndentationGuides(indentView)
    Show or hide indentation guides.

    See Scintilla documentation for SCI_SETINDENTATIONGUIDES

    Editor.getIndentationGuides() → int
    Are the indentation guides visible?

    See Scintilla documentation for SCI_GETINDENTATIONGUIDES

    Editor.setHighlightGuide(column)
    Set the highlighted indentation guide column. 0 = no highlighted guide.

    See Scintilla documentation for SCI_SETHIGHLIGHTGUIDE

    Editor.getHighlightGuide() → int
    Get the highlighted indentation guide column.

    See Scintilla documentation for SCI_GETHIGHLIGHTGUIDE

    Editor.getLineEndPosition(line) → int
    Get the position after the last visible characters on a line.

    See Scintilla documentation for SCI_GETLINEENDPOSITION

    Editor.getCodePage() → int
    Get the code page used to interpret the bytes of the document as characters.

    See Scintilla documentation for SCI_GETCODEPAGE

    Editor.getCaretFore() → tuple
    Get the foreground colour of the caret.

    See Scintilla documentation for SCI_GETCARETFORE

    Editor.getReadOnly() → bool
    In read-only mode?

    See Scintilla documentation for SCI_GETREADONLY

    Editor.setCurrentPos(pos)
    Sets the position of the caret.

    See Scintilla documentation for SCI_SETCURRENTPOS

    Editor.setSelectionStart(pos)
    Sets the position that starts the selection - this becomes the anchor.

    See Scintilla documentation for SCI_SETSELECTIONSTART

    Editor.getSelectionStart() → int
    Returns the position at the start of the selection.

    See Scintilla documentation for SCI_GETSELECTIONSTART

    Editor.setSelectionEnd(pos)
    Sets the position that ends the selection - this becomes the currentPosition.

    See Scintilla documentation for SCI_SETSELECTIONEND

    Editor.getSelectionEnd() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETSELECTIONEND

    Editor.setEmptySelection(pos)
    Set caret to a position, while removing any existing selection.

    See Scintilla documentation for SCI_SETEMPTYSELECTION

    Editor.setPrintMagnification(magnification)
    Sets the print magnification added to the point size of each style for printing.

    See Scintilla documentation for SCI_SETPRINTMAGNIFICATION

    Editor.getPrintMagnification() → int
    Returns the print magnification.

    See Scintilla documentation for SCI_GETPRINTMAGNIFICATION

    Editor.setPrintColourMode(mode)
    Modify colours when printing for clearer printed text.

    See Scintilla documentation for SCI_SETPRINTCOLOURMODE

    Editor.getPrintColourMode() → int
    Returns the print colour mode.

    See Scintilla documentation for SCI_GETPRINTCOLOURMODE

    Editor.findText(flags, start, end, ft) → object
    Find some text in the document.

    See Scintilla documentation for SCI_FINDTEXT

    Editor.getFirstVisibleLine() → int
    Retrieve the display line at the top of the display.

    See Scintilla documentation for SCI_GETFIRSTVISIBLELINE

    Editor.getLine(line) → str
    Retrieve the contents of a line. Returns the length of the line.

    See Scintilla documentation for SCI_GETLINE

    Editor.getLineCount() → int
    Returns the number of lines in the document. There is always at least one.

    See Scintilla documentation for SCI_GETLINECOUNT

    Editor.setMarginLeft(pixelWidth)
    Sets the size in pixels of the left margin.

    See Scintilla documentation for SCI_SETMARGINLEFT

    Editor.getMarginLeft() → int
    Returns the size in pixels of the left margin.

    See Scintilla documentation for SCI_GETMARGINLEFT

    Editor.setMarginRight(pixelWidth)
    Sets the size in pixels of the right margin.

    See Scintilla documentation for SCI_SETMARGINRIGHT

    Editor.getMarginRight() → int
    Returns the size in pixels of the right margin.

    See Scintilla documentation for SCI_GETMARGINRIGHT

    Editor.getModify() → bool
    Is the document different from when it was last saved?

    See Scintilla documentation for SCI_GETMODIFY

    Editor.setSel(start, end)
    Select a range of text.

    See Scintilla documentation for SCI_SETSEL

    Editor.getSelText() → str
    Retrieve the selected text. Return the length of the text.

    See Scintilla documentation for SCI_GETSELTEXT

    Editor.getTextRange(start, end) → str
    Retrieve a range of text. Return the length of the text.

    See Scintilla documentation for SCI_GETTEXTRANGE

    Editor.hideSelection(normal)
    Draw the selection in normal style or with selection highlighted.

    See Scintilla documentation for SCI_HIDESELECTION

    Editor.pointXFromPosition(pos) → int
    Retrieve the x value of the point in the window where a position is displayed.

    See Scintilla documentation for SCI_POINTXFROMPOSITION

    Editor.pointYFromPosition(pos) → int
    Retrieve the y value of the point in the window where a position is displayed.

    See Scintilla documentation for SCI_POINTYFROMPOSITION

    Editor.lineFromPosition(pos) → int
    Retrieve the line containing a position.

    See Scintilla documentation for SCI_LINEFROMPOSITION

    Editor.positionFromLine(line) → int
    Retrieve the position at the start of a line.

    See Scintilla documentation for SCI_POSITIONFROMLINE

    Editor.lineScroll(columns, lines)
    Scroll horizontally and vertically.

    See Scintilla documentation for SCI_LINESCROLL

    Editor.scrollCaret()
    Ensure the caret is visible.

    See Scintilla documentation for SCI_SCROLLCARET

    Editor.scrollRange(secondary, primary)
    Scroll the argument positions and the range between them into view giving priority to the primary position then the secondary position. This may be used to make a search match visible.

    See Scintilla documentation for SCI_SCROLLRANGE

    Editor.replaceSel(text)
    Replace the selected text with the argument text.

    See Scintilla documentation for SCI_REPLACESEL

    Editor.setReadOnly(readOnly)
    Set to read only or read write.

    See Scintilla documentation for SCI_SETREADONLY

    Editor.null()
    Null operation.

    See Scintilla documentation for SCI_NULL

    Editor.canPaste() → bool
    Will a paste succeed?

    See Scintilla documentation for SCI_CANPASTE

    Editor.canUndo() → bool
    Are there any undoable actions in the undo history?

    See Scintilla documentation for SCI_CANUNDO

    Editor.emptyUndoBuffer()
    Delete the undo history.

    See Scintilla documentation for SCI_EMPTYUNDOBUFFER

    Editor.undo()
    Undo one action in the undo history.

    See Scintilla documentation for SCI_UNDO

    Editor.cut()
    Cut the selection to the clipboard.

    See Scintilla documentation for SCI_CUT

    Editor.copy()
    Copy the selection to the clipboard.

    See Scintilla documentation for SCI_COPY

    Editor.paste()
    Paste the contents of the clipboard into the document replacing the selection.

    See Scintilla documentation for SCI_PASTE

    Editor.clear()
    Clear the selection.

    See Scintilla documentation for SCI_CLEAR

    Editor.setText(text)
    Replace the contents of the document with the argument text.

    See Scintilla documentation for SCI_SETTEXT

    Editor.getText() → str
    Retrieve all the text in the document. Returns number of characters retrieved.

    See Scintilla documentation for SCI_GETTEXT

    Editor.getTextLength() → int
    Retrieve the number of characters in the document.

    See Scintilla documentation for SCI_GETTEXTLENGTH

    Editor.getDirectFunction() → int
    Retrieve a pointer to a function that processes messages for this Scintilla.

    See Scintilla documentation for SCI_GETDIRECTFUNCTION

    Editor.getDirectPointer() → int
    Retrieve a pointer value to use as the first argument when calling the function returned by GetDirectFunction.

    See Scintilla documentation for SCI_GETDIRECTPOINTER

    Editor.setOvertype(overtype)
    Set to overtype (true) or insert mode.

    See Scintilla documentation for SCI_SETOVERTYPE

    Editor.getOvertype() → bool
    Returns true if overtype mode is active otherwise false is returned.

    See Scintilla documentation for SCI_GETOVERTYPE

    Editor.setCaretWidth(pixelWidth)
    Set the width of the insert mode caret.

    See Scintilla documentation for SCI_SETCARETWIDTH

    Editor.getCaretWidth() → int
    Returns the width of the insert mode caret.

    See Scintilla documentation for SCI_GETCARETWIDTH

    Editor.setTargetStart(pos)
    Sets the position that starts the target which is used for updating the document without affecting the scroll position.

    See Scintilla documentation for SCI_SETTARGETSTART

    Editor.getTargetStart() → int
    Get the position that starts the target.

    See Scintilla documentation for SCI_GETTARGETSTART

    Editor.setTargetEnd(pos)
    Sets the position that ends the target which is used for updating the document without affecting the scroll position.

    See Scintilla documentation for SCI_SETTARGETEND

    Editor.getTargetEnd() → int
    Get the position that ends the target.

    See Scintilla documentation for SCI_GETTARGETEND

    Editor.replaceTarget(text) → int
    Replace the target text with the argument text. Text is counted so it can contain NULs. Returns the length of the replacement text.

    See Scintilla documentation for SCI_REPLACETARGET

    Editor.replaceTargetRE(text) → int
    Replace the target text with the argument text after \d processing. Text is counted so it can contain NULs. Looks for \d where d is between 1 and 9 and replaces these with the strings matched in the last search operation which were surrounded by \( and \). Returns the length of the replacement text including any change caused by processing the \d patterns.

    See Scintilla documentation for SCI_REPLACETARGETRE

    Editor.searchInTarget(text) → int
    Search for a counted string in the target and set the target to the found range. Text is counted so it can contain NULs. Returns length of range or -1 for failure in which case target is not moved.

    See Scintilla documentation for SCI_SEARCHINTARGET

    Editor.setSearchFlags(flags)
    Set the search flags used by SearchInTarget.

    See Scintilla documentation for SCI_SETSEARCHFLAGS

    Editor.getSearchFlags() → int
    Get the search flags used by SearchInTarget.

    See Scintilla documentation for SCI_GETSEARCHFLAGS

    Editor.callTipShow(pos, definition)
    Show a call tip containing a definition near position pos.

    See Scintilla documentation for SCI_CALLTIPSHOW

    Editor.callTipCancel()
    Remove the call tip from the screen.

    See Scintilla documentation for SCI_CALLTIPCANCEL

    Editor.callTipActive() → bool
    Is there an active call tip?

    See Scintilla documentation for SCI_CALLTIPACTIVE

    Editor.callTipPosStart() → int
    Retrieve the position where the caret was before displaying the call tip.

    See Scintilla documentation for SCI_CALLTIPPOSSTART

    Editor.callTipSetPosStart(posStart)
    Set the start position in order to change when backspacing removes the calltip.

    See Scintilla documentation for SCI_CALLTIPSETPOSSTART

    Editor.callTipSetHlt(start, end)
    Highlight a segment of the definition.

    See Scintilla documentation for SCI_CALLTIPSETHLT

    Editor.callTipSetBack(back)
    Set the background colour for the call tip.

    See Scintilla documentation for SCI_CALLTIPSETBACK

    Editor.callTipSetFore(fore)
    Set the foreground colour for the call tip.

    See Scintilla documentation for SCI_CALLTIPSETFORE

    Editor.callTipSetForeHlt(fore)
    Set the foreground colour for the highlighted part of the call tip.

    See Scintilla documentation for SCI_CALLTIPSETFOREHLT

    Editor.callTipUseStyle(tabSize)
    Enable use of STYLE_CALLTIP and set call tip tab size in pixels.

    See Scintilla documentation for SCI_CALLTIPUSESTYLE

    Editor.callTipSetPosition(above)
    Set position of calltip, above or below text.

    See Scintilla documentation for SCI_CALLTIPSETPOSITION

    Editor.visibleFromDocLine(line) → int
    Find the display line of a document line taking hidden lines into account.

    See Scintilla documentation for SCI_VISIBLEFROMDOCLINE

    Editor.docLineFromVisible(lineDisplay) → int
    Find the document line of a display line taking hidden lines into account.

    See Scintilla documentation for SCI_DOCLINEFROMVISIBLE

    Editor.wrapCount(line) → int
    The number of display lines needed to wrap a document line

    See Scintilla documentation for SCI_WRAPCOUNT

    Editor.setFoldLevel(line, level)
    Set the fold level of a line. This encodes an integer level along with flags indicating whether the line is a header and whether it is effectively white space.

    See Scintilla documentation for SCI_SETFOLDLEVEL

    Editor.getFoldLevel(line) → int
    Retrieve the fold level of a line.

    See Scintilla documentation for SCI_GETFOLDLEVEL

    Editor.getLastChild(line, level) → int
    Find the last child line of a header line.

    See Scintilla documentation for SCI_GETLASTCHILD

    Editor.getFoldParent(line) → int
    Find the parent line of a child line.

    See Scintilla documentation for SCI_GETFOLDPARENT

    Editor.showLines(lineStart, lineEnd)
    Make a range of lines visible.

    See Scintilla documentation for SCI_SHOWLINES

    Editor.hideLines(lineStart, lineEnd)
    Make a range of lines invisible.

    See Scintilla documentation for SCI_HIDELINES

    Editor.getLineVisible(line) → bool
    Is a line visible?

    See Scintilla documentation for SCI_GETLINEVISIBLE

    Editor.getAllLinesVisible() → bool
    Are all lines visible?

    See Scintilla documentation for SCI_GETALLLINESVISIBLE

    Editor.setFoldExpanded(line, expanded)
    Show the children of a header line.

    See Scintilla documentation for SCI_SETFOLDEXPANDED

    Editor.getFoldExpanded(line) → bool
    Is a header line expanded?

    See Scintilla documentation for SCI_GETFOLDEXPANDED

    Editor.toggleFold(line)
    Switch a header line between expanded and contracted.

    See Scintilla documentation for SCI_TOGGLEFOLD

    Editor.foldLine(line, action)
    Expand or contract a fold header.

    See Scintilla documentation for SCI_FOLDLINE

    Editor.foldChildren(line, action)
    Expand or contract a fold header and its children.

    See Scintilla documentation for SCI_FOLDCHILDREN

    Editor.expandChildren(line, level)
    Expand a fold header and all children. Use the level argument instead of the line’s current level.

    See Scintilla documentation for SCI_EXPANDCHILDREN

    Editor.foldAll(action)
    Expand or contract all fold headers.

    See Scintilla documentation for SCI_FOLDALL

    Editor.ensureVisible(line)
    Ensure a particular line is visible by expanding any header line hiding it.

    See Scintilla documentation for SCI_ENSUREVISIBLE

    Editor.setAutomaticFold(automaticFold)
    Set automatic folding behaviours.

    See Scintilla documentation for SCI_SETAUTOMATICFOLD

    Editor.getAutomaticFold() → int
    Get automatic folding behaviours.

    See Scintilla documentation for SCI_GETAUTOMATICFOLD

    Editor.setFoldFlags(flags)
    Set some style options for folding.

    See Scintilla documentation for SCI_SETFOLDFLAGS

    Editor.ensureVisibleEnforcePolicy(line)
    Ensure a particular line is visible by expanding any header line hiding it. Use the currently set visibility policy to determine which range to display.

    See Scintilla documentation for SCI_ENSUREVISIBLEENFORCEPOLICY

    Editor.setTabIndents(tabIndents)
    Sets whether a tab pressed when caret is within indentation indents.

    See Scintilla documentation for SCI_SETTABINDENTS

    Editor.getTabIndents() → bool
    Does a tab pressed when caret is within indentation indent?

    See Scintilla documentation for SCI_GETTABINDENTS

    Editor.setBackSpaceUnIndents(bsUnIndents)
    Sets whether a backspace pressed when caret is within indentation unindents.

    See Scintilla documentation for SCI_SETBACKSPACEUNINDENTS

    Editor.getBackSpaceUnIndents() → bool
    Does a backspace pressed when caret is within indentation unindent?

    See Scintilla documentation for SCI_GETBACKSPACEUNINDENTS

    Editor.setMouseDwellTime(periodMilliseconds)
    Sets the time the mouse must sit still to generate a mouse dwell event.

    See Scintilla documentation for SCI_SETMOUSEDWELLTIME

    Editor.getMouseDwellTime() → int
    Retrieve the time the mouse must sit still to generate a mouse dwell event.

    See Scintilla documentation for SCI_GETMOUSEDWELLTIME

    Editor.wordStartPosition(pos, onlyWordCharacters) → int
    Get position of start of word.

    See Scintilla documentation for SCI_WORDSTARTPOSITION

    Editor.wordEndPosition(pos, onlyWordCharacters) → int
    Get position of end of word.

    See Scintilla documentation for SCI_WORDENDPOSITION

    Editor.setWrapMode(mode)
    Sets whether text is word wrapped.

    See Scintilla documentation for SCI_SETWRAPMODE

    Editor.getWrapMode() → int
    Retrieve whether text is word wrapped.

    See Scintilla documentation for SCI_GETWRAPMODE

    Editor.setWrapVisualFlags(wrapVisualFlags)
    Set the display mode of visual flags for wrapped lines.

    See Scintilla documentation for SCI_SETWRAPVISUALFLAGS

    Editor.getWrapVisualFlags() → int
    Retrive the display mode of visual flags for wrapped lines.

    See Scintilla documentation for SCI_GETWRAPVISUALFLAGS

    Editor.setWrapVisualFlagsLocation(wrapVisualFlagsLocation)
    Set the location of visual flags for wrapped lines.

    See Scintilla documentation for SCI_SETWRAPVISUALFLAGSLOCATION

    Editor.getWrapVisualFlagsLocation() → int
    Retrive the location of visual flags for wrapped lines.

    See Scintilla documentation for SCI_GETWRAPVISUALFLAGSLOCATION

    Editor.setWrapStartIndent(indent)
    Set the start indent for wrapped lines.

    See Scintilla documentation for SCI_SETWRAPSTARTINDENT

    Editor.getWrapStartIndent() → int
    Retrive the start indent for wrapped lines.

    See Scintilla documentation for SCI_GETWRAPSTARTINDENT

    Editor.setWrapIndentMode(mode)
    Sets how wrapped sublines are placed. Default is fixed.

    See Scintilla documentation for SCI_SETWRAPINDENTMODE

    Editor.getWrapIndentMode() → int
    Retrieve how wrapped sublines are placed. Default is fixed.

    See Scintilla documentation for SCI_GETWRAPINDENTMODE

    Editor.setLayoutCache(mode)
    Sets the degree of caching of layout information.

    See Scintilla documentation for SCI_SETLAYOUTCACHE

    Editor.getLayoutCache() → int
    Retrieve the degree of caching of layout information.

    See Scintilla documentation for SCI_GETLAYOUTCACHE

    Editor.setScrollWidth(pixelWidth)
    Sets the document width assumed for scrolling.

    See Scintilla documentation for SCI_SETSCROLLWIDTH

    Editor.getScrollWidth() → int
    Retrieve the document width assumed for scrolling.

    See Scintilla documentation for SCI_GETSCROLLWIDTH

    Editor.setScrollWidthTracking(tracking)
    Sets whether the maximum width line displayed is used to set scroll width.

    See Scintilla documentation for SCI_SETSCROLLWIDTHTRACKING

    Editor.getScrollWidthTracking() → bool
    Retrieve whether the scroll width tracks wide lines.

    See Scintilla documentation for SCI_GETSCROLLWIDTHTRACKING

    Editor.textWidth(style, text) → int
    Measure the pixel width of some text in a particular style. NUL terminated text argument. Does not handle tab or control characters.

    See Scintilla documentation for SCI_TEXTWIDTH

    Editor.setEndAtLastLine(endAtLastLine)
    Sets the scroll range so that maximum scroll position has the last line at the bottom of the view (default). Setting this to false allows scrolling one page below the last line.

    See Scintilla documentation for SCI_SETENDATLASTLINE

    Editor.getEndAtLastLine() → bool
    Retrieve whether the maximum scroll position has the last line at the bottom of the view.

    See Scintilla documentation for SCI_GETENDATLASTLINE

    Editor.textHeight(line) → int
    Retrieve the height of a particular line of text in pixels.

    See Scintilla documentation for SCI_TEXTHEIGHT

    Editor.setVScrollBar(show)
    Show or hide the vertical scroll bar.

    See Scintilla documentation for SCI_SETVSCROLLBAR

    Editor.getVScrollBar() → bool
    Is the vertical scroll bar visible?

    See Scintilla documentation for SCI_GETVSCROLLBAR

    Editor.appendText(text) → int
    Append a string to the end of the document without changing the selection.

    See Scintilla documentation for SCI_APPENDTEXT

    Editor.getTwoPhaseDraw() → bool
    Is drawing done in two phases with backgrounds drawn before faoregrounds?

    See Scintilla documentation for SCI_GETTWOPHASEDRAW

    Editor.setTwoPhaseDraw(twoPhase)
    In twoPhaseDraw mode, drawing is performed in two phases, first the background and then the foreground. This avoids chopping off characters that overlap the next run.

    See Scintilla documentation for SCI_SETTWOPHASEDRAW

    Editor.setFontQuality(fontQuality)
    Choose the quality level for text from the FontQuality enumeration.

    See Scintilla documentation for SCI_SETFONTQUALITY

    Editor.getFontQuality() → int
    Retrieve the quality level for text.

    See Scintilla documentation for SCI_GETFONTQUALITY

    Editor.setFirstVisibleLine(lineDisplay)
    Scroll so that a display line is at the top of the display.

    See Scintilla documentation for SCI_SETFIRSTVISIBLELINE

    Editor.setMultiPaste(multiPaste)
    Change the effect of pasting when there are multiple selections.

    See Scintilla documentation for SCI_SETMULTIPASTE

    Editor.getMultiPaste() → int
    Retrieve the effect of pasting when there are multiple selections..

    See Scintilla documentation for SCI_GETMULTIPASTE

    Editor.getTag(tagNumber) → str
    Retrieve the value of a tag from a regular expression search.

    See Scintilla documentation for SCI_GETTAG

    Editor.targetFromSelection()
    Make the target range start and end be the same as the selection range start and end.

    See Scintilla documentation for SCI_TARGETFROMSELECTION

    Editor.linesJoin()
    Join the lines in the target.

    See Scintilla documentation for SCI_LINESJOIN

    Editor.linesSplit(pixelWidth)
    Split the lines in the target into lines that are less wide than pixelWidth where possible.

    See Scintilla documentation for SCI_LINESSPLIT

    Editor.setFoldMarginColour(useSetting, back)
    Set the colours used as a chequerboard pattern in the fold margin

    See Scintilla documentation for SCI_SETFOLDMARGINCOLOUR

    Editor.setFoldMarginHiColour(useSetting, fore)
    Set the colours used as a chequerboard pattern in the fold margin

    See Scintilla documentation for SCI_SETFOLDMARGINHICOLOUR

    Editor.lineDown()
    Move caret down one line.

    See Scintilla documentation for SCI_LINEDOWN

    Editor.lineDownExtend()
    Move caret down one line extending selection to new caret position.

    See Scintilla documentation for SCI_LINEDOWNEXTEND

    Editor.lineUp()
    Move caret up one line.

    See Scintilla documentation for SCI_LINEUP

    Editor.lineUpExtend()
    Move caret up one line extending selection to new caret position.

    See Scintilla documentation for SCI_LINEUPEXTEND

    Editor.charLeft()
    Move caret left one character.

    See Scintilla documentation for SCI_CHARLEFT

    Editor.charLeftExtend()
    Move caret left one character extending selection to new caret position.

    See Scintilla documentation for SCI_CHARLEFTEXTEND

    Editor.charRight()
    Move caret right one character.

    See Scintilla documentation for SCI_CHARRIGHT

    Editor.charRightExtend()
    Move caret right one character extending selection to new caret position.

    See Scintilla documentation for SCI_CHARRIGHTEXTEND

    Editor.wordLeft()
    Move caret left one word.

    See Scintilla documentation for SCI_WORDLEFT

    Editor.wordLeftExtend()
    Move caret left one word extending selection to new caret position.

    See Scintilla documentation for SCI_WORDLEFTEXTEND

    Editor.wordRight()
    Move caret right one word.

    See Scintilla documentation for SCI_WORDRIGHT

    Editor.wordRightExtend()
    Move caret right one word extending selection to new caret position.

    See Scintilla documentation for SCI_WORDRIGHTEXTEND

    Editor.home()
    Move caret to first position on line.

    See Scintilla documentation for SCI_HOME

    Editor.homeExtend()
    Move caret to first position on line extending selection to new caret position.

    See Scintilla documentation for SCI_HOMEEXTEND

    Editor.lineEnd()
    Move caret to last position on line.

    See Scintilla documentation for SCI_LINEEND

    Editor.lineEndExtend()
    Move caret to last position on line extending selection to new caret position.

    See Scintilla documentation for SCI_LINEENDEXTEND

    Editor.documentStart()
    Move caret to first position in document.

    See Scintilla documentation for SCI_DOCUMENTSTART

    Editor.documentStartExtend()
    Move caret to first position in document extending selection to new caret position.

    See Scintilla documentation for SCI_DOCUMENTSTARTEXTEND

    Editor.documentEnd()
    Move caret to last position in document.

    See Scintilla documentation for SCI_DOCUMENTEND

    Editor.documentEndExtend()
    Move caret to last position in document extending selection to new caret position.

    See Scintilla documentation for SCI_DOCUMENTENDEXTEND

    Editor.pageUp()
    Move caret one page up.

    See Scintilla documentation for SCI_PAGEUP

    Editor.pageUpExtend()
    Move caret one page up extending selection to new caret position.

    See Scintilla documentation for SCI_PAGEUPEXTEND

    Editor.pageDown()
    Move caret one page down.

    See Scintilla documentation for SCI_PAGEDOWN

    Editor.pageDownExtend()
    Move caret one page down extending selection to new caret position.

    See Scintilla documentation for SCI_PAGEDOWNEXTEND

    Editor.editToggleOvertype()
    Switch from insert to overtype mode or the reverse.

    See Scintilla documentation for SCI_EDITTOGGLEOVERTYPE

    Editor.cancel()
    Cancel any modes such as call tip or auto-completion list display.

    See Scintilla documentation for SCI_CANCEL

    Editor.deleteBack()
    Delete the selection or if no selection, the character before the caret.

    See Scintilla documentation for SCI_DELETEBACK

    Editor.tab()
    If selection is empty or all on one line replace the selection with a tab character. If more than one line selected, indent the lines.

    See Scintilla documentation for SCI_TAB

    Editor.backTab()
    Dedent the selected lines.

    See Scintilla documentation for SCI_BACKTAB

    Editor.newLine()
    Insert a new line, may use a CRLF, CR or LF depending on EOL mode.

    See Scintilla documentation for SCI_NEWLINE

    Editor.formFeed()
    Insert a Form Feed character.

    See Scintilla documentation for SCI_FORMFEED

    Editor.vCHome()
    Move caret to before first visible character on line. If already there move to first character on line.

    See Scintilla documentation for SCI_VCHOME

    Editor.vCHomeExtend()
    Like VCHome but extending selection to new caret position.

    See Scintilla documentation for SCI_VCHOMEEXTEND

    Editor.zoomIn()
    Magnify the displayed text by increasing the sizes by 1 point.

    See Scintilla documentation for SCI_ZOOMIN

    Editor.zoomOut()
    Make the displayed text smaller by decreasing the sizes by 1 point.

    See Scintilla documentation for SCI_ZOOMOUT

    Editor.delWordLeft()
    Delete the word to the left of the caret.

    See Scintilla documentation for SCI_DELWORDLEFT

    Editor.delWordRight()
    Delete the word to the right of the caret.

    See Scintilla documentation for SCI_DELWORDRIGHT

    Editor.delWordRightEnd()
    Delete the word to the right of the caret, but not the trailing non-word characters.

    See Scintilla documentation for SCI_DELWORDRIGHTEND

    Editor.lineCut()
    Cut the line containing the caret.

    See Scintilla documentation for SCI_LINECUT

    Editor.lineDelete()
    Delete the line containing the caret.

    See Scintilla documentation for SCI_LINEDELETE

    Editor.lineTranspose()
    Switch the current line with the previous.

    See Scintilla documentation for SCI_LINETRANSPOSE

    Editor.lineDuplicate()
    Duplicate the current line.

    See Scintilla documentation for SCI_LINEDUPLICATE

    Editor.lowerCase()
    Transform the selection to lower case.

    See Scintilla documentation for SCI_LOWERCASE

    Editor.upperCase()
    Transform the selection to upper case.

    See Scintilla documentation for SCI_UPPERCASE

    Editor.lineScrollDown()
    Scroll the document down, keeping the caret visible.

    See Scintilla documentation for SCI_LINESCROLLDOWN

    Editor.lineScrollUp()
    Scroll the document up, keeping the caret visible.

    See Scintilla documentation for SCI_LINESCROLLUP

    Editor.deleteBackNotLine()
    Delete the selection or if no selection, the character before the caret. Will not delete the character before at the start of a line.

    See Scintilla documentation for SCI_DELETEBACKNOTLINE

    Editor.homeDisplay()
    Move caret to first position on display line.

    See Scintilla documentation for SCI_HOMEDISPLAY

    Editor.homeDisplayExtend()
    Move caret to first position on display line extending selection to new caret position.

    See Scintilla documentation for SCI_HOMEDISPLAYEXTEND

    Editor.lineEndDisplay()
    Move caret to last position on display line.

    See Scintilla documentation for SCI_LINEENDDISPLAY

    Editor.lineEndDisplayExtend()
    Move caret to last position on display line extending selection to new caret position.

    See Scintilla documentation for SCI_LINEENDDISPLAYEXTEND

    Editor.homeWrap()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_HOMEWRAP

    Editor.homeWrapExtend()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_HOMEWRAPEXTEND

    Editor.lineEndWrap()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_LINEENDWRAP

    Editor.lineEndWrapExtend()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_LINEENDWRAPEXTEND

    Editor.vCHomeWrap()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_VCHOMEWRAP

    Editor.vCHomeWrapExtend()
    These are like their namesakes Home(Extend)?, LineEnd(Extend)?, VCHome(Extend)? except they behave differently when word-wrap is enabled: They go first to the start / end of the display line, like (Home|LineEnd)Display The difference is that, the cursor is already at the point, it goes on to the start or end of the document line, as appropriate for (Home|LineEnd|VCHome)(Extend)?.

    See Scintilla documentation for SCI_VCHOMEWRAPEXTEND

    Editor.lineCopy()
    Copy the line containing the caret.

    See Scintilla documentation for SCI_LINECOPY

    Editor.moveCaretInsideView()
    Move the caret inside current view if it’s not there already.

    See Scintilla documentation for SCI_MOVECARETINSIDEVIEW

    Editor.lineLength(line) → int
    How many characters are on a line, including end of line characters?

    See Scintilla documentation for SCI_LINELENGTH

    Editor.braceHighlight(pos1, pos2)
    Highlight the characters at two positions.

    See Scintilla documentation for SCI_BRACEHIGHLIGHT

    Editor.braceHighlightIndicator(useBraceHighlightIndicator, indicator)
    Use specified indicator to highlight matching braces instead of changing their style.

    See Scintilla documentation for SCI_BRACEHIGHLIGHTINDICATOR

    Editor.braceBadLight(pos)
    Highlight the character at a position indicating there is no matching brace.

    See Scintilla documentation for SCI_BRACEBADLIGHT

    Editor.braceBadLightIndicator(useBraceBadLightIndicator, indicator)
    Use specified indicator to highlight non matching brace instead of changing its style.

    See Scintilla documentation for SCI_BRACEBADLIGHTINDICATOR

    Editor.braceMatch(pos) → int
    Find the position of a matching brace or INVALID_POSITION if no match.

    See Scintilla documentation for SCI_BRACEMATCH

    Editor.getViewEOL() → bool
    Are the end of line characters visible?

    See Scintilla documentation for SCI_GETVIEWEOL

    Editor.setViewEOL(visible)
    Make the end of line characters visible or invisible.

    See Scintilla documentation for SCI_SETVIEWEOL

    Editor.getDocPointer() → int
    Retrieve a pointer to the document object.

    See Scintilla documentation for SCI_GETDOCPOINTER

    Editor.setDocPointer(pointer)
    Change the document object used.

    See Scintilla documentation for SCI_SETDOCPOINTER

    Editor.setModEventMask(mask)
    Set which document modification events are sent to the container.

    See Scintilla documentation for SCI_SETMODEVENTMASK

    Editor.getEdgeColumn() → int
    Retrieve the column number which text should be kept within.

    See Scintilla documentation for SCI_GETEDGECOLUMN

    Editor.setEdgeColumn(column)
    Set the column number of the edge. If text goes past the edge then it is highlighted.

    See Scintilla documentation for SCI_SETEDGECOLUMN

    Editor.getEdgeMode() → int
    Retrieve the edge highlight mode.

    See Scintilla documentation for SCI_GETEDGEMODE

    Editor.setEdgeMode(mode)
    The edge may be displayed by a line (EDGE_LINE) or by highlighting text that goes beyond it (EDGE_BACKGROUND) or not displayed at all (EDGE_NONE).

    See Scintilla documentation for SCI_SETEDGEMODE

    Editor.getEdgeColour() → tuple
    Retrieve the colour used in edge indication.

    See Scintilla documentation for SCI_GETEDGECOLOUR

    Editor.setEdgeColour(edgeColour)
    Change the colour used in edge indication.

    See Scintilla documentation for SCI_SETEDGECOLOUR

    Editor.searchAnchor()
    Sets the current caret position to be the search anchor.

    See Scintilla documentation for SCI_SEARCHANCHOR

    Editor.searchNext(flags, text) → int
    Find some text starting at the search anchor. Does not ensure the selection is visible.

    See Scintilla documentation for SCI_SEARCHNEXT

    Editor.searchPrev(flags, text) → int
    Find some text starting at the search anchor and moving backwards. Does not ensure the selection is visible.

    See Scintilla documentation for SCI_SEARCHPREV

    Editor.linesOnScreen() → int
    Retrieves the number of lines completely visible.

    See Scintilla documentation for SCI_LINESONSCREEN

    Editor.usePopUp(allowPopUp)
    Set whether a pop up menu is displayed automatically when the user presses the wrong mouse button.

    See Scintilla documentation for SCI_USEPOPUP

    Editor.selectionIsRectangle() → bool
    Is the selection rectangular? The alternative is the more common stream selection.

    See Scintilla documentation for SCI_SELECTIONISRECTANGLE

    Editor.setZoom(zoom)
    Set the zoom level. This number of points is added to the size of all fonts. It may be positive to magnify or negative to reduce.

    See Scintilla documentation for SCI_SETZOOM

    Editor.getZoom() → int
    Retrieve the zoom level.

    See Scintilla documentation for SCI_GETZOOM

    Editor.createDocument() → int
    Create a new document object. Starts with reference count of 1 and not selected into editor.

    See Scintilla documentation for SCI_CREATEDOCUMENT

    Editor.addRefDocument(doc)
    Extend life of document.

    See Scintilla documentation for SCI_ADDREFDOCUMENT

    Editor.releaseDocument(doc)
    Release a reference to the document, deleting document if it fades to black.

    See Scintilla documentation for SCI_RELEASEDOCUMENT

    Editor.getModEventMask() → int
    Get which document modification events are sent to the container.

    See Scintilla documentation for SCI_GETMODEVENTMASK

    Editor.setFocus(focus)
    Change internal focus flag.

    See Scintilla documentation for SCI_SETFOCUS

    Editor.getFocus() → bool
    Get internal focus flag.

    See Scintilla documentation for SCI_GETFOCUS

    Editor.setStatus(statusCode)
    Change error status - 0 = OK.

    See Scintilla documentation for SCI_SETSTATUS

    Editor.getStatus() → int
    Get error status.

    See Scintilla documentation for SCI_GETSTATUS

    Editor.setMouseDownCaptures(captures)
    Set whether the mouse is captured when its button is pressed.

    See Scintilla documentation for SCI_SETMOUSEDOWNCAPTURES

    Editor.getMouseDownCaptures() → bool
    Get whether mouse gets captured.

    See Scintilla documentation for SCI_GETMOUSEDOWNCAPTURES

    Editor.setCursor(cursorType)
    Sets the cursor to one of the SC_CURSOR* values.

    See Scintilla documentation for SCI_SETCURSOR

    Editor.getCursor() → int
    Get cursor type.

    See Scintilla documentation for SCI_GETCURSOR

    Editor.setControlCharSymbol(symbol)
    Change the way control characters are displayed: If symbol is < 32, keep the drawn way, else, use the given character.

    See Scintilla documentation for SCI_SETCONTROLCHARSYMBOL

    Editor.getControlCharSymbol() → int
    Get the way control characters are displayed.

    See Scintilla documentation for SCI_GETCONTROLCHARSYMBOL

    Editor.wordPartLeft()
    Move to the previous change in capitalisation.

    See Scintilla documentation for SCI_WORDPARTLEFT

    Editor.wordPartLeftExtend()
    Move to the previous change in capitalisation extending selection to new caret position.

    See Scintilla documentation for SCI_WORDPARTLEFTEXTEND

    Editor.wordPartRight()
    Move to the change next in capitalisation.

    See Scintilla documentation for SCI_WORDPARTRIGHT

    Editor.wordPartRightExtend()
    Move to the next change in capitalisation extending selection to new caret position.

    See Scintilla documentation for SCI_WORDPARTRIGHTEXTEND

    Editor.setVisiblePolicy(visiblePolicy, visibleSlop)
    Set the way the display area is determined when a particular line is to be moved to by Find, FindNext, GotoLine, etc.

    See Scintilla documentation for SCI_SETVISIBLEPOLICY

    Editor.delLineLeft()
    Delete back from the current position to the start of the line.

    See Scintilla documentation for SCI_DELLINELEFT

    Editor.delLineRight()
    Delete forwards from the current position to the end of the line.

    See Scintilla documentation for SCI_DELLINERIGHT

    Editor.setXOffset(newOffset)
    Get and Set the xOffset (ie, horizontal scroll position).

    See Scintilla documentation for SCI_SETXOFFSET

    Editor.getXOffset() → int
    Get and Set the xOffset (ie, horizontal scroll position).

    See Scintilla documentation for SCI_GETXOFFSET

    Editor.chooseCaretX()
    Set the last x chosen value to be the caret x position.

    See Scintilla documentation for SCI_CHOOSECARETX

    Editor.grabFocus()
    Set the focus to this Scintilla widget.

    See Scintilla documentation for SCI_GRABFOCUS

    Editor.setXCaretPolicy(caretPolicy, caretSlop)
    Set the way the caret is kept visible when going sideways. The exclusion zone is given in pixels.

    See Scintilla documentation for SCI_SETXCARETPOLICY

    Editor.setYCaretPolicy(caretPolicy, caretSlop)
    Set the way the line the caret is on is kept visible. The exclusion zone is given in lines.

    See Scintilla documentation for SCI_SETYCARETPOLICY

    Editor.setPrintWrapMode(mode)
    Set printing to line wrapped (SC_WRAP_WORD) or not line wrapped (SC_WRAP_NONE).

    See Scintilla documentation for SCI_SETPRINTWRAPMODE

    Editor.getPrintWrapMode() → int
    Is printing line wrapped?

    See Scintilla documentation for SCI_GETPRINTWRAPMODE

    Editor.setHotspotActiveFore(useSetting, fore)
    Set a fore colour for active hotspots.

    See Scintilla documentation for SCI_SETHOTSPOTACTIVEFORE

    Editor.getHotspotActiveFore() → tuple
    Get the fore colour for active hotspots.

    See Scintilla documentation for SCI_GETHOTSPOTACTIVEFORE

    Editor.setHotspotActiveBack(useSetting, back)
    Set a back colour for active hotspots.

    See Scintilla documentation for SCI_SETHOTSPOTACTIVEBACK

    Editor.getHotspotActiveBack() → tuple
    Get the back colour for active hotspots.

    See Scintilla documentation for SCI_GETHOTSPOTACTIVEBACK

    Editor.setHotspotActiveUnderline(underline)
    Enable / Disable underlining active hotspots.

    See Scintilla documentation for SCI_SETHOTSPOTACTIVEUNDERLINE

    Editor.getHotspotActiveUnderline() → bool
    Get whether underlining for active hotspots.

    See Scintilla documentation for SCI_GETHOTSPOTACTIVEUNDERLINE

    Editor.setHotspotSingleLine(singleLine)
    Limit hotspots to single line so hotspots on two lines don’t merge.

    See Scintilla documentation for SCI_SETHOTSPOTSINGLELINE

    Editor.getHotspotSingleLine() → bool
    Get the HotspotSingleLine property

    See Scintilla documentation for SCI_GETHOTSPOTSINGLELINE

    Editor.paraDown()
    Move caret between paragraphs (delimited by empty lines).

    See Scintilla documentation for SCI_PARADOWN

    Editor.paraDownExtend()
    Move caret between paragraphs (delimited by empty lines).

    See Scintilla documentation for SCI_PARADOWNEXTEND

    Editor.paraUp()
    Move caret between paragraphs (delimited by empty lines).

    See Scintilla documentation for SCI_PARAUP

    Editor.paraUpExtend()
    Move caret between paragraphs (delimited by empty lines).

    See Scintilla documentation for SCI_PARAUPEXTEND

    Editor.positionBefore(pos) → int
    Given a valid document position, return the previous position taking code page into account. Returns 0 if passed 0.

    See Scintilla documentation for SCI_POSITIONBEFORE

    Editor.positionAfter(pos) → int
    Given a valid document position, return the next position taking code page into account. Maximum value returned is the last position in the document.

    See Scintilla documentation for SCI_POSITIONAFTER

    Editor.positionRelative(pos, relative) → int
    Given a valid document position, return a position that differs in a number of characters. Returned value is always between 0 and last position in document.

    See Scintilla documentation for SCI_POSITIONRELATIVE

    Editor.copyRange(start, end)
    Copy a range of text to the clipboard. Positions are clipped into the document.

    See Scintilla documentation for SCI_COPYRANGE

    Editor.copyText(text) → int
    Copy argument text to the clipboard.

    See Scintilla documentation for SCI_COPYTEXT

    Editor.setSelectionMode(mode)
    Set the selection mode to stream (SC_SEL_STREAM) or rectangular (SC_SEL_RECTANGLE/SC_SEL_THIN) or by lines (SC_SEL_LINES).

    See Scintilla documentation for SCI_SETSELECTIONMODE

    Editor.getSelectionMode() → int
    Get the mode of the current selection.

    See Scintilla documentation for SCI_GETSELECTIONMODE

    Editor.getLineSelStartPosition(line) → int
    Retrieve the position of the start of the selection at the given line (INVALID_POSITION if no selection on this line).

    See Scintilla documentation for SCI_GETLINESELSTARTPOSITION

    Editor.getLineSelEndPosition(line) → int
    Retrieve the position of the end of the selection at the given line (INVALID_POSITION if no selection on this line).

    See Scintilla documentation for SCI_GETLINESELENDPOSITION

    Editor.lineDownRectExtend()
    Move caret down one line, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_LINEDOWNRECTEXTEND

    Editor.lineUpRectExtend()
    Move caret up one line, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_LINEUPRECTEXTEND

    Editor.charLeftRectExtend()
    Move caret left one character, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_CHARLEFTRECTEXTEND

    Editor.charRightRectExtend()
    Move caret right one character, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_CHARRIGHTRECTEXTEND

    Editor.homeRectExtend()
    Move caret to first position on line, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_HOMERECTEXTEND

    Editor.vCHomeRectExtend()
    Move caret to before first visible character on line. If already there move to first character on line. In either case, extend rectangular selection to new caret position.

    See Scintilla documentation for SCI_VCHOMERECTEXTEND

    Editor.lineEndRectExtend()
    Move caret to last position on line, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_LINEENDRECTEXTEND

    Editor.pageUpRectExtend()
    Move caret one page up, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_PAGEUPRECTEXTEND

    Editor.pageDownRectExtend()
    Move caret one page down, extending rectangular selection to new caret position.

    See Scintilla documentation for SCI_PAGEDOWNRECTEXTEND

    Editor.stutteredPageUp()
    Move caret to top of page, or one page up if already at top of page.

    See Scintilla documentation for SCI_STUTTEREDPAGEUP

    Editor.stutteredPageUpExtend()
    Move caret to top of page, or one page up if already at top of page, extending selection to new caret position.

    See Scintilla documentation for SCI_STUTTEREDPAGEUPEXTEND

    Editor.stutteredPageDown()
    Move caret to bottom of page, or one page down if already at bottom of page.

    See Scintilla documentation for SCI_STUTTEREDPAGEDOWN

    Editor.stutteredPageDownExtend()
    Move caret to bottom of page, or one page down if already at bottom of page, extending selection to new caret position.

    See Scintilla documentation for SCI_STUTTEREDPAGEDOWNEXTEND

    Editor.wordLeftEnd()
    Move caret left one word, position cursor at end of word.

    See Scintilla documentation for SCI_WORDLEFTEND

    Editor.wordLeftEndExtend()
    Move caret left one word, position cursor at end of word, extending selection to new caret position.

    See Scintilla documentation for SCI_WORDLEFTENDEXTEND

    Editor.wordRightEnd()
    Move caret right one word, position cursor at end of word.

    See Scintilla documentation for SCI_WORDRIGHTEND

    Editor.wordRightEndExtend()
    Move caret right one word, position cursor at end of word, extending selection to new caret position.

    See Scintilla documentation for SCI_WORDRIGHTENDEXTEND

    Editor.setWhitespaceChars(characters)
    Set the set of characters making up whitespace for when moving or selecting by word. Should be called after SetWordChars.

    See Scintilla documentation for SCI_SETWHITESPACECHARS

    Editor.getWhitespaceChars() → str
    Get the set of characters making up whitespace for when moving or selecting by word.

    See Scintilla documentation for SCI_GETWHITESPACECHARS

    Editor.setPunctuationChars(characters)
    Set the set of characters making up punctuation characters Should be called after SetWordChars.

    See Scintilla documentation for SCI_SETPUNCTUATIONCHARS

    Editor.getPunctuationChars() → str
    Get the set of characters making up punctuation characters

    See Scintilla documentation for SCI_GETPUNCTUATIONCHARS

    Editor.setCharsDefault()
    Reset the set of characters for whitespace and word characters to the defaults.

    See Scintilla documentation for SCI_SETCHARSDEFAULT

    Editor.autoCGetCurrent() → int
    Get currently selected item position in the auto-completion list

    See Scintilla documentation for SCI_AUTOCGETCURRENT

    Editor.autoCGetCurrentText() → str
    Get currently selected item text in the auto-completion list Returns the length of the item text

    See Scintilla documentation for SCI_AUTOCGETCURRENTTEXT

    Editor.autoCSetCaseInsensitiveBehaviour(behaviour)
    Set auto-completion case insensitive behaviour to either prefer case-sensitive matches or have no preference.

    See Scintilla documentation for SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR

    Editor.autoCGetCaseInsensitiveBehaviour() → int
    Get auto-completion case insensitive behaviour.

    See Scintilla documentation for SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR

    Editor.autoCSetOrder(order)
    Set the way autocompletion lists are ordered.

    See Scintilla documentation for SCI_AUTOCSETORDER

    Editor.autoCGetOrder() → int
    Get the way autocompletion lists are ordered.

    See Scintilla documentation for SCI_AUTOCGETORDER

    Editor.allocate(bytes)
    Enlarge the document to a particular size of text bytes.

    See Scintilla documentation for SCI_ALLOCATE

    Editor.targetAsUTF8() → str
    Returns the target converted to UTF8. Return the length in bytes.

    See Scintilla documentation for SCI_TARGETASUTF8

    Editor.setLengthForEncode(bytes)
    Set the length of the utf8 argument for calling EncodedFromUTF8. Set to -1 and the string will be measured to the first nul.

    See Scintilla documentation for SCI_SETLENGTHFORENCODE

    Editor.encodedFromUTF8() → str
    Translates a UTF8 string into the document encoding. Return the length of the result in bytes. On error return 0.

    See Scintilla documentation for SCI_ENCODEDFROMUTF8

    Editor.findColumn(line, column) → int
    Find the position of a column on a line taking into account tabs and multi-byte characters. If beyond end of line, return line end position.

    See Scintilla documentation for SCI_FINDCOLUMN

    Editor.getCaretSticky() → int
    Can the caret preferred x position only be changed by explicit movement commands?

    See Scintilla documentation for SCI_GETCARETSTICKY

    Editor.setCaretSticky(useCaretStickyBehaviour)
    Stop the caret preferred x position changing when the user types.

    See Scintilla documentation for SCI_SETCARETSTICKY

    Editor.toggleCaretSticky()
    Switch between sticky and non-sticky: meant to be bound to a key.

    See Scintilla documentation for SCI_TOGGLECARETSTICKY

    Editor.setPasteConvertEndings(convert)
    Enable/Disable convert-on-paste for line endings

    See Scintilla documentation for SCI_SETPASTECONVERTENDINGS

    Editor.getPasteConvertEndings() → bool
    Get convert-on-paste setting

    See Scintilla documentation for SCI_GETPASTECONVERTENDINGS

    Editor.selectionDuplicate()
    Duplicate the selection. If selection empty duplicate the line containing the caret.

    See Scintilla documentation for SCI_SELECTIONDUPLICATE

    Editor.setCaretLineBackAlpha(alpha)
    Set background alpha of the caret line.

    See Scintilla documentation for SCI_SETCARETLINEBACKALPHA

    Editor.getCaretLineBackAlpha() → int
    Get the background alpha of the caret line.

    See Scintilla documentation for SCI_GETCARETLINEBACKALPHA

    Editor.setCaretStyle(caretStyle)
    Set the style of the caret to be drawn.

    See Scintilla documentation for SCI_SETCARETSTYLE

    Editor.getCaretStyle() → int
    Returns the current style of the caret.

    See Scintilla documentation for SCI_GETCARETSTYLE

    Editor.setIndicatorCurrent(indicator)
    Set the indicator used for IndicatorFillRange and IndicatorClearRange

    See Scintilla documentation for SCI_SETINDICATORCURRENT

    Editor.getIndicatorCurrent() → int
    Get the current indicator

    See Scintilla documentation for SCI_GETINDICATORCURRENT

    Editor.setIndicatorValue(value)
    Set the value used for IndicatorFillRange

    See Scintilla documentation for SCI_SETINDICATORVALUE

    Editor.getIndicatorValue() → int
    Get the current indicator value

    See Scintilla documentation for SCI_GETINDICATORVALUE

    Editor.indicatorFillRange(position, fillLength)
    Turn a indicator on over a range.

    See Scintilla documentation for SCI_INDICATORFILLRANGE

    Editor.indicatorClearRange(position, clearLength)
    Turn a indicator off over a range.

    See Scintilla documentation for SCI_INDICATORCLEARRANGE

    Editor.indicatorAllOnFor(position) → int
    Are any indicators present at position?

    See Scintilla documentation for SCI_INDICATORALLONFOR

    Editor.indicatorValueAt(indicator, position) → int
    What value does a particular indicator have at at a position?

    See Scintilla documentation for SCI_INDICATORVALUEAT

    Editor.indicatorStart(indicator, position) → int
    Where does a particular indicator start?

    See Scintilla documentation for SCI_INDICATORSTART

    Editor.indicatorEnd(indicator, position) → int
    Where does a particular indicator end?

    See Scintilla documentation for SCI_INDICATOREND

    Editor.setPositionCache(size)
    Set number of entries in position cache

    See Scintilla documentation for SCI_SETPOSITIONCACHE

    Editor.getPositionCache() → int
    How many entries are allocated to the position cache?

    See Scintilla documentation for SCI_GETPOSITIONCACHE

    Editor.copyAllowLine()
    Copy the selection, if selection empty copy the line with the caret

    See Scintilla documentation for SCI_COPYALLOWLINE

    Editor.getGapPosition() → int
    Return a position which, to avoid performance costs, should not be within the range of a call to GetRangePointer.

    See Scintilla documentation for SCI_GETGAPPOSITION

    Editor.setKeysUnicode(keysUnicode)
    Always interpret keyboard input as Unicode

    See Scintilla documentation for SCI_SETKEYSUNICODE

    Editor.getKeysUnicode() → bool
    Are keys always interpreted as Unicode?

    See Scintilla documentation for SCI_GETKEYSUNICODE

    Editor.indicSetAlpha(indicator, alpha)
    Set the alpha fill colour of the given indicator.

    See Scintilla documentation for SCI_INDICSETALPHA

    Editor.indicGetAlpha(indicator) → int
    Get the alpha fill colour of the given indicator.

    See Scintilla documentation for SCI_INDICGETALPHA

    Editor.indicSetOutlineAlpha(indicator, alpha)
    Set the alpha outline colour of the given indicator.

    See Scintilla documentation for SCI_INDICSETOUTLINEALPHA

    Editor.indicGetOutlineAlpha(indicator) → int
    Get the alpha outline colour of the given indicator.

    See Scintilla documentation for SCI_INDICGETOUTLINEALPHA

    Editor.setExtraAscent(extraAscent)
    Set extra ascent for each line

    See Scintilla documentation for SCI_SETEXTRAASCENT

    Editor.getExtraAscent() → int
    Get extra ascent for each line

    See Scintilla documentation for SCI_GETEXTRAASCENT

    Editor.setExtraDescent(extraDescent)
    Set extra descent for each line

    See Scintilla documentation for SCI_SETEXTRADESCENT

    Editor.getExtraDescent() → int
    Get extra descent for each line

    See Scintilla documentation for SCI_GETEXTRADESCENT

    Editor.markerSymbolDefined(markerNumber) → int
    Which symbol was defined for markerNumber with MarkerDefine

    See Scintilla documentation for SCI_MARKERSYMBOLDEFINED

    Editor.marginSetText(line, text)
    Set the text in the text margin for a line

    See Scintilla documentation for SCI_MARGINSETTEXT

    Editor.marginGetText(line) → str
    Get the text in the text margin for a line

    See Scintilla documentation for SCI_MARGINGETTEXT

    Editor.marginSetStyle(line, style)
    Set the style number for the text margin for a line

    See Scintilla documentation for SCI_MARGINSETSTYLE

    Editor.marginGetStyle(line) → int
    Get the style number for the text margin for a line

    See Scintilla documentation for SCI_MARGINGETSTYLE

    Editor.marginSetStyles(line, styles)
    Set the style in the text margin for a line

    See Scintilla documentation for SCI_MARGINSETSTYLES

    Editor.marginGetStyles(line) → str
    Get the styles in the text margin for a line

    See Scintilla documentation for SCI_MARGINGETSTYLES

    Editor.marginTextClearAll()
    Clear the margin text on all lines

    See Scintilla documentation for SCI_MARGINTEXTCLEARALL

    Editor.marginSetStyleOffset(style)
    Get the start of the range of style numbers used for margin text

    See Scintilla documentation for SCI_MARGINSETSTYLEOFFSET

    Editor.marginGetStyleOffset() → int
    Get the start of the range of style numbers used for margin text

    See Scintilla documentation for SCI_MARGINGETSTYLEOFFSET

    Editor.setMarginOptions(marginOptions)
    Set the margin options.

    See Scintilla documentation for SCI_SETMARGINOPTIONS

    Editor.getMarginOptions() → int
    Get the margin options.

    See Scintilla documentation for SCI_GETMARGINOPTIONS

    Editor.annotationSetText(line, text)
    Set the annotation text for a line

    See Scintilla documentation for SCI_ANNOTATIONSETTEXT

    Editor.annotationGetText(line) → str
    Get the annotation text for a line

    See Scintilla documentation for SCI_ANNOTATIONGETTEXT

    Editor.annotationSetStyle(line, style)
    Set the style number for the annotations for a line

    See Scintilla documentation for SCI_ANNOTATIONSETSTYLE

    Editor.annotationGetStyle(line) → int
    Get the style number for the annotations for a line

    See Scintilla documentation for SCI_ANNOTATIONGETSTYLE

    Editor.annotationSetStyles(line, styles)
    Set the annotation styles for a line

    See Scintilla documentation for SCI_ANNOTATIONSETSTYLES

    Editor.annotationGetStyles(line) → str
    Get the annotation styles for a line

    See Scintilla documentation for SCI_ANNOTATIONGETSTYLES

    Editor.annotationGetLines(line) → int
    Get the number of annotation lines for a line

    See Scintilla documentation for SCI_ANNOTATIONGETLINES

    Editor.annotationClearAll()
    Clear the annotations from all lines

    See Scintilla documentation for SCI_ANNOTATIONCLEARALL

    Editor.annotationSetVisible(visible)
    Set the visibility for the annotations for a view

    See Scintilla documentation for SCI_ANNOTATIONSETVISIBLE

    Editor.annotationGetVisible() → int
    Get the visibility for the annotations for a view

    See Scintilla documentation for SCI_ANNOTATIONGETVISIBLE

    Editor.annotationSetStyleOffset(style)
    Get the start of the range of style numbers used for annotations

    See Scintilla documentation for SCI_ANNOTATIONSETSTYLEOFFSET

    Editor.annotationGetStyleOffset() → int
    Get the start of the range of style numbers used for annotations

    See Scintilla documentation for SCI_ANNOTATIONGETSTYLEOFFSET

    Editor.releaseAllExtendedStyles()
    Release all extended (>255) style numbers

    See Scintilla documentation for SCI_RELEASEALLEXTENDEDSTYLES

    Editor.allocateExtendedStyles(numberStyles) → int
    Allocate some extended (>255) style numbers and return the start of the range

    See Scintilla documentation for SCI_ALLOCATEEXTENDEDSTYLES

    Editor.addUndoAction(token, flags)
    Add a container action to the undo stack

    See Scintilla documentation for SCI_ADDUNDOACTION

    Editor.charPositionFromPoint(x, y) → int
    Find the position of a character from a point within the window.

    See Scintilla documentation for SCI_CHARPOSITIONFROMPOINT

    Editor.charPositionFromPointClose(x, y) → int
    Find the position of a character from a point within the window. Return INVALID_POSITION if not close to text.

    See Scintilla documentation for SCI_CHARPOSITIONFROMPOINTCLOSE

    Editor.setMouseSelectionRectangularSwitch(mouseSelectionRectangularSwitch)
    Set whether switching to rectangular mode while selecting with the mouse is allowed.

    See Scintilla documentation for SCI_SETMOUSESELECTIONRECTANGULARSWITCH

    Editor.getMouseSelectionRectangularSwitch() → bool
    Whether switching to rectangular mode while selecting with the mouse is allowed.

    See Scintilla documentation for SCI_GETMOUSESELECTIONRECTANGULARSWITCH

    Editor.setMultipleSelection(multipleSelection)
    Set whether multiple selections can be made

    See Scintilla documentation for SCI_SETMULTIPLESELECTION

    Editor.getMultipleSelection() → bool
    Whether multiple selections can be made

    See Scintilla documentation for SCI_GETMULTIPLESELECTION

    Editor.setAdditionalSelectionTyping(additionalSelectionTyping)
    Set whether typing can be performed into multiple selections

    See Scintilla documentation for SCI_SETADDITIONALSELECTIONTYPING

    Editor.getAdditionalSelectionTyping() → bool
    Whether typing can be performed into multiple selections

    See Scintilla documentation for SCI_GETADDITIONALSELECTIONTYPING

    Editor.setAdditionalCaretsBlink(additionalCaretsBlink)
    Set whether additional carets will blink

    See Scintilla documentation for SCI_SETADDITIONALCARETSBLINK

    Editor.getAdditionalCaretsBlink() → bool
    Whether additional carets will blink

    See Scintilla documentation for SCI_GETADDITIONALCARETSBLINK

    Editor.setAdditionalCaretsVisible(additionalCaretsBlink)
    Set whether additional carets are visible

    See Scintilla documentation for SCI_SETADDITIONALCARETSVISIBLE

    Editor.getAdditionalCaretsVisible() → bool
    Whether additional carets are visible

    See Scintilla documentation for SCI_GETADDITIONALCARETSVISIBLE

    Editor.getSelections() → int
    How many selections are there?

    See Scintilla documentation for SCI_GETSELECTIONS

    Editor.getSelectionEmpty() → bool
    Is every selected range empty?

    See Scintilla documentation for SCI_GETSELECTIONEMPTY

    Editor.clearSelections()
    Clear selections to a single empty stream selection

    See Scintilla documentation for SCI_CLEARSELECTIONS

    Editor.setSelection(caret, anchor) → int
    Set a simple selection

    See Scintilla documentation for SCI_SETSELECTION

    Editor.addSelection(caret, anchor) → int
    Add a selection

    See Scintilla documentation for SCI_ADDSELECTION

    Editor.dropSelectionN(selection)
    Drop one selection

    See Scintilla documentation for SCI_DROPSELECTIONN

    Editor.setMainSelection(selection)
    Set the main selection

    See Scintilla documentation for SCI_SETMAINSELECTION

    Editor.getMainSelection() → int
    Which selection is the main selection

    See Scintilla documentation for SCI_GETMAINSELECTION

    Editor.setSelectionNCaret(selection, pos)
    Which selection is the main selection

    See Scintilla documentation for SCI_SETSELECTIONNCARET

    Editor.getSelectionNCaret(selection) → int
    Which selection is the main selection

    See Scintilla documentation for SCI_GETSELECTIONNCARET

    Editor.setSelectionNAnchor(selection, posAnchor)
    Which selection is the main selection

    See Scintilla documentation for SCI_SETSELECTIONNANCHOR

    Editor.getSelectionNAnchor(selection) → int
    Which selection is the main selection

    See Scintilla documentation for SCI_GETSELECTIONNANCHOR

    Editor.setSelectionNCaretVirtualSpace(selection, space)
    Which selection is the main selection

    See Scintilla documentation for SCI_SETSELECTIONNCARETVIRTUALSPACE

    Editor.getSelectionNCaretVirtualSpace(selection) → int
    Which selection is the main selection

    See Scintilla documentation for SCI_GETSELECTIONNCARETVIRTUALSPACE

    Editor.setSelectionNAnchorVirtualSpace(selection, space)
    Which selection is the main selection

    See Scintilla documentation for SCI_SETSELECTIONNANCHORVIRTUALSPACE

    Editor.getSelectionNAnchorVirtualSpace(selection) → int
    Which selection is the main selection

    See Scintilla documentation for SCI_GETSELECTIONNANCHORVIRTUALSPACE

    Editor.setSelectionNStart(selection, pos)
    Sets the position that starts the selection - this becomes the anchor.

    See Scintilla documentation for SCI_SETSELECTIONNSTART

    Editor.getSelectionNStart(selection) → int
    Returns the position at the start of the selection.

    See Scintilla documentation for SCI_GETSELECTIONNSTART

    Editor.setSelectionNEnd(selection, pos)
    Sets the position that ends the selection - this becomes the currentPosition.

    See Scintilla documentation for SCI_SETSELECTIONNEND

    Editor.getSelectionNEnd(selection) → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETSELECTIONNEND

    Editor.setRectangularSelectionCaret(pos)
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_SETRECTANGULARSELECTIONCARET

    Editor.getRectangularSelectionCaret() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETRECTANGULARSELECTIONCARET

    Editor.setRectangularSelectionAnchor(posAnchor)
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_SETRECTANGULARSELECTIONANCHOR

    Editor.getRectangularSelectionAnchor() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETRECTANGULARSELECTIONANCHOR

    Editor.setRectangularSelectionCaretVirtualSpace(space)
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE

    Editor.getRectangularSelectionCaretVirtualSpace() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE

    Editor.setRectangularSelectionAnchorVirtualSpace(space)
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE

    Editor.getRectangularSelectionAnchorVirtualSpace() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE

    Editor.setVirtualSpaceOptions(virtualSpaceOptions)
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_SETVIRTUALSPACEOPTIONS

    Editor.getVirtualSpaceOptions() → int
    Returns the position at the end of the selection.

    See Scintilla documentation for SCI_GETVIRTUALSPACEOPTIONS

    Editor.setRectangularSelectionModifier(modifier)
    On GTK+, allow selecting the modifier key to use for mouse-based rectangular selection. Often the window manager requires Alt+Mouse Drag for moving windows. Valid values are SCMOD_CTRL(default), SCMOD_ALT, or SCMOD_SUPER.

    See Scintilla documentation for SCI_SETRECTANGULARSELECTIONMODIFIER

    Editor.getRectangularSelectionModifier() → int
    Get the modifier key used for rectangular selection.

    See Scintilla documentation for SCI_GETRECTANGULARSELECTIONMODIFIER

    Editor.setAdditionalSelFore(fore)
    Set the foreground colour of additional selections. Must have previously called SetSelFore with non-zero first argument for this to have an effect.

    See Scintilla documentation for SCI_SETADDITIONALSELFORE

    Editor.setAdditionalSelBack(back)
    Set the background colour of additional selections. Must have previously called SetSelBack with non-zero first argument for this to have an effect.

    See Scintilla documentation for SCI_SETADDITIONALSELBACK

    Editor.setAdditionalSelAlpha(alpha)
    Set the alpha of the selection.

    See Scintilla documentation for SCI_SETADDITIONALSELALPHA

    Editor.getAdditionalSelAlpha() → int
    Get the alpha of the selection.

    See Scintilla documentation for SCI_GETADDITIONALSELALPHA

    Editor.setAdditionalCaretFore(fore)
    Set the foreground colour of additional carets.

    See Scintilla documentation for SCI_SETADDITIONALCARETFORE

    Editor.getAdditionalCaretFore() → tuple
    Get the foreground colour of additional carets.

    See Scintilla documentation for SCI_GETADDITIONALCARETFORE

    Editor.rotateSelection()
    Set the main selection to the next selection.

    See Scintilla documentation for SCI_ROTATESELECTION

    Editor.swapMainAnchorCaret()
    Swap that caret and anchor of the main selection.

    See Scintilla documentation for SCI_SWAPMAINANCHORCARET

    Editor.changeLexerState(start, end) → int
    Indicate that the internal state of a lexer has changed over a range and therefore there may be a need to redraw.

    See Scintilla documentation for SCI_CHANGELEXERSTATE

    Editor.contractedFoldNext(lineStart) → int
    Find the next line at or after lineStart that is a contracted fold header line. Return -1 when no more lines.

    See Scintilla documentation for SCI_CONTRACTEDFOLDNEXT

    Editor.verticalCentreCaret()
    Centre current line in window.

    See Scintilla documentation for SCI_VERTICALCENTRECARET

    Editor.moveSelectedLinesUp()
    Move the selected lines up one line, shifting the line above after the selection

    See Scintilla documentation for SCI_MOVESELECTEDLINESUP

    Editor.moveSelectedLinesDown()
    Move the selected lines down one line, shifting the line below before the selection

    See Scintilla documentation for SCI_MOVESELECTEDLINESDOWN

    Editor.setIdentifier(identifier)
    Set the identifier reported as idFrom in notification messages.

    See Scintilla documentation for SCI_SETIDENTIFIER

    Editor.getIdentifier() → int
    Get the identifier.

    See Scintilla documentation for SCI_GETIDENTIFIER

    Editor.rGBAImageSetWidth(width)
    Set the width for future RGBA image data.

    See Scintilla documentation for SCI_RGBAIMAGESETWIDTH

    Editor.rGBAImageSetHeight(height)
    Set the height for future RGBA image data.

    See Scintilla documentation for SCI_RGBAIMAGESETHEIGHT

    Editor.rGBAImageSetScale(scalePercent)
    Set the scale factor in percent for future RGBA image data.

    See Scintilla documentation for SCI_RGBAIMAGESETSCALE

    Editor.markerDefineRGBAImage(markerNumber, pixels)
    Define a marker from RGBA data. It has the width and height from RGBAImageSetWidth/Height

    See Scintilla documentation for SCI_MARKERDEFINERGBAIMAGE

    Editor.registerRGBAImage(type, pixels)
    Register an RGBA image for use in autocompletion lists. It has the width and height from RGBAImageSetWidth/Height

    See Scintilla documentation for SCI_REGISTERRGBAIMAGE

    Editor.scrollToStart()
    Scroll to start of document.

    See Scintilla documentation for SCI_SCROLLTOSTART

    Editor.scrollToEnd()
    Scroll to end of document.

    See Scintilla documentation for SCI_SCROLLTOEND

    Editor.setTechnology(technology)
    Set the technology used.

    See Scintilla documentation for SCI_SETTECHNOLOGY

    Editor.getTechnology() → int
    Get the tech.

    See Scintilla documentation for SCI_GETTECHNOLOGY

    Editor.createLoader(bytes) → int
    Create an ILoader*.

    See Scintilla documentation for SCI_CREATELOADER

    Editor.findIndicatorShow(start, end)
    On OS X, show a find indicator.

    See Scintilla documentation for SCI_FINDINDICATORSHOW

    Editor.findIndicatorFlash(start, end)
    On OS X, flash a find indicator, then fade out.

    See Scintilla documentation for SCI_FINDINDICATORFLASH

    Editor.findIndicatorHide()
    On OS X, hide the find indicator.

    See Scintilla documentation for SCI_FINDINDICATORHIDE

    Editor.vCHomeDisplay()
    Move caret to before first visible character on display line. If already there move to first character on display line.

    See Scintilla documentation for SCI_VCHOMEDISPLAY

    Editor.vCHomeDisplayExtend()
    Like VCHomeDisplay but extending selection to new caret position.

    See Scintilla documentation for SCI_VCHOMEDISPLAYEXTEND

    Editor.getCaretLineVisibleAlways() → bool
    Is the caret line always visible?

    See Scintilla documentation for SCI_GETCARETLINEVISIBLEALWAYS

    Editor.setCaretLineVisibleAlways(alwaysVisible)
    Sets the caret line to always visible.

    See Scintilla documentation for SCI_SETCARETLINEVISIBLEALWAYS

    Editor.setRepresentation(encodedCharacter, representation)
    Set the way a character is drawn.

    See Scintilla documentation for SCI_SETREPRESENTATION

    Editor.getRepresentation() → str
    Set the way a character is drawn.

    See Scintilla documentation for SCI_GETREPRESENTATION

    Editor.clearRepresentation(encodedCharacter)
    Remove a character representation.

    See Scintilla documentation for SCI_CLEARREPRESENTATION

    Editor.startRecord()
    Start notifying the container of all key presses and commands.

    See Scintilla documentation for SCI_STARTRECORD

    Editor.stopRecord()
    Stop notifying the container of all key presses and commands.

    See Scintilla documentation for SCI_STOPRECORD

    Editor.setLexer(lexer)
    Set the lexing language of the document.

    See Scintilla documentation for SCI_SETLEXER

    Editor.getLexer() → int
    Retrieve the lexing language of the document.

    See Scintilla documentation for SCI_GETLEXER

    Editor.colourise(start, end)
    Colourise a segment of the document using the current lexing language.

    See Scintilla documentation for SCI_COLOURISE

    Editor.setProperty(key, value)
    Set up a value that may be used by a lexer for some optional feature.

    See Scintilla documentation for SCI_SETPROPERTY

    Editor.setKeyWords(keywordSet, keyWords)
    Set up the key words used by the lexer.

    See Scintilla documentation for SCI_SETKEYWORDS

    Editor.setLexerLanguage(language)
    Set the lexing language of the document based on string name.

    See Scintilla documentation for SCI_SETLEXERLANGUAGE

    Editor.loadLexerLibrary(path)
    Load a lexer library (dll / so).

    See Scintilla documentation for SCI_LOADLEXERLIBRARY

    Editor.getProperty(key) → str
    Retrieve a “property” value previously set with SetProperty.

    See Scintilla documentation for SCI_GETPROPERTY

    Editor.getPropertyExpanded(key) → str
    Retrieve a “property” value previously set with SetProperty, with “$()” variable replacement on returned buffer.

    See Scintilla documentation for SCI_GETPROPERTYEXPANDED

    Editor.getPropertyInt(key) → int
    Retrieve a “property” value previously set with SetProperty, interpreted as an int AFTER any “$()” variable replacement.

    See Scintilla documentation for SCI_GETPROPERTYINT

    Editor.getStyleBitsNeeded() → int
    Retrieve the number of bits the current lexer needs for styling.

    See Scintilla documentation for SCI_GETSTYLEBITSNEEDED

    Editor.getLexerLanguage() → str
    Retrieve the name of the lexer. Return the length of the text.

    See Scintilla documentation for SCI_GETLEXERLANGUAGE

    Editor.privateLexerCall(operation, pointer) → int
    For private communication between an application and a known lexer.

    See Scintilla documentation for SCI_PRIVATELEXERCALL

    Editor.propertyNames() → str
    Retrieve a ‘\n’ separated list of properties understood by the current lexer.

    See Scintilla documentation for SCI_PROPERTYNAMES

    Editor.propertyType(name) → int
    Retrieve the type of a property.

    See Scintilla documentation for SCI_PROPERTYTYPE

    Editor.describeProperty() → str
    Describe a property.

    See Scintilla documentation for SCI_DESCRIBEPROPERTY

    Editor.describeKeyWordSets() → str
    Retrieve a ‘\n’ separated list of descriptions of the keyword sets understood by the current lexer.

    See Scintilla documentation for SCI_DESCRIBEKEYWORDSETS

    Editor.setLineEndTypesAllowed(lineEndBitSet)
    Set the line end types that the application wants to use. May not be used if incompatible with lexer or encoding.

    See Scintilla documentation for SCI_SETLINEENDTYPESALLOWED

    Editor.getLineEndTypesAllowed() → int
    Get the line end types currently allowed.

    See Scintilla documentation for SCI_GETLINEENDTYPESALLOWED

    Editor.getLineEndTypesActive() → int
    Get the line end types currently recognised. May be a subset of the allowed types due to lexer limitation.

    See Scintilla documentation for SCI_GETLINEENDTYPESACTIVE

    Editor.getLineEndTypesSupported() → int
    Bit set of LineEndType enumertion for which line ends beyond the standard LF, CR, and CRLF are supported by the lexer.

    See Scintilla documentation for SCI_GETLINEENDTYPESSUPPORTED

    Editor.allocateSubStyles(styleBase, numberStyles) → int
    Allocate a set of sub styles for a particular base style, returning start of range

    See Scintilla documentation for SCI_ALLOCATESUBSTYLES

    Editor.getSubStylesStart(styleBase) → int
    The starting style number for the sub styles associated with a base style

    See Scintilla documentation for SCI_GETSUBSTYLESSTART

    Editor.getSubStylesLength(styleBase) → int
    The number of sub styles associated with a base style

    See Scintilla documentation for SCI_GETSUBSTYLESLENGTH

    Editor.getStyleFromSubStyle(subStyle) → int
    For a sub style, return the base style, else return the argument.

    See Scintilla documentation for SCI_GETSTYLEFROMSUBSTYLE

    Editor.getPrimaryStyleFromStyle(style) → int
    For a secondary style, return the primary style, else return the argument.

    See Scintilla documentation for SCI_GETPRIMARYSTYLEFROMSTYLE

    Editor.freeSubStyles()
    Free allocated sub styles

    See Scintilla documentation for SCI_FREESUBSTYLES

    Editor.setIdentifiers(style, identifiers)
    Set the identifiers that are shown in a particular style

    See Scintilla documentation for SCI_SETIDENTIFIERS

    Editor.distanceToSecondaryStyles() → int
    Where styles are duplicated by a feature such as active/inactive code return the distance between the two types.

    See Scintilla documentation for SCI_DISTANCETOSECONDARYSTYLES

    Editor.getSubStyleBases() → str
    Get the set of base styles that can be extended with sub styles

    See Scintilla documentation for SCI_GETSUBSTYLEBASES

    Helper Methods
    Editor.forEachLine(function)
    Runs the function passed for each line in the current document. The function gets passed 3 arguments, the contents of the line, the line number (starting from zero), and the total number of lines. If the function returns a number, that number is added to the current line number for the next iteration.

    That way, if you delete the current line, you should return 0, so as to stay on the current physical line.

    Under normal circumstances, you do not need to return anything from the function (i.e. None)

    e.g.:

    def testContents(contents, lineNumber, totalLines):
            if contents.strip() == "rubbish":
                    editor.deleteLine(lineNumber)
                    # As we've deleted the line, the "next" line to process
                    # is actually the current line, so we return 0 to advance zero lines
                    # and hence stay on the same line
                    return 0

            elif contents.strip() == "something old":
                    editor.replaceLine(lineNumber, "something new")

            elif contents.strip() == "little something":
                    editor.replaceLine(lineNumber, "BIG\nSOMETHING"
                    # Here we return 2, as we've inserted a newline,
                    # and we don't want to test the "SOMETHING" line again
                    return 2

            # if you wanted, you could optionally return 1 here, to move the next line
            # but that's the default, so you don't need to bother.


    editor.forEachLine(testContents)
    Editor.deleteLine(line)
    Deletes the given (zero indexed) line number.

    Editor.replaceLine(line, newContents)
    Replaces the given (zero indexed) line number with the given contents. e.g.:

    editor.replaceLine(3, "New contents")
    Editor.replaceWholeLine(line, newContents)
    Replaces the given (zero indexed) line number with the given contents, including the line break (ie. the line break from the old line is removed, no line break on the replacement will result in joining lines).

    e.g.:

    editor.replaceWholeLine(3, "New contents")
    Editor.setTarget(start, end)
    Sets the target start and end in one call. See Editor.setTargetStart() and Editor.setTargetEnd()

    Editor.getUserLineSelection() -> (startLine, endLine)
    Gets the start and end (zero indexed) line numbers of the user selection, or the whole document if nothing is selected.

    Useful if you want to run your script over a number of lines - using this allows the user to select nothing, and have the script run for the whole document, or select just the section they want to run the script over.

    Editor.getUserCharSelection() -> (startByte, endByte)
    Gets the start and end (zero indexed) byte numbers of the user selection, or the whole document if nothing is selected.

    Editor.clearCallbacks()
    Clears all callbacks

    Editor.clearCallbacks(function)
    Clears all callbacks for a given function

    Editor.clearCallbacks(eventsList)
    Clears all callbacks for the given list of events

    Editor.clearCallbacks(function, eventsList)
    Clears the callback for the given callback function for the list of events

    Editor.callback(function, eventsList)
    Adds a handler for an Editor (Scintilla) event. The events list is a list of events to respond to, from the SCINTILLANOTIFICATION enum. Documentation on notifications from Scintilla can be found here: http://www.scintilla.org/ScintillaDoc.html#Notifications

    For a simple example, here’s a script that automatically saves the document as soon as a change is made:

    def saveCurrentDoc(args):
        notepad.save()

    editor.callback(saveCurrentDoc, [SCINTILLANOTIFICATION.SAVEPOINTLEFT])
    This script is not really sensible in real life, as for large files, it will take some time to save the file, and it will be saved after every key press.

    Note that Editor callbacks are processed asynchronously by default. What this means in practice is that your event handler function (saveCurrentDoc in the previous example) is called just after the event has fired. If the callback handler is slow, and the callbacks occur quickly, you could get “behind”. Callbacks are placed in a queue and processed in the order they arrived. If you need to do something before letting the user continue, you can use Editor.callbackSync(), which adds a synchronous callback.

    Editor.callbackSync(function, eventsList)
    Adds a synchronous handler for an Editor (Scintilla) event. The events list is a list of events to respond to, from the SCINTILLANOTIFICATION enum.

    What this means is that the handler function is called, and must complete, before control is returned to the user. If you perform a slow operation in your handler function, this will have an effect on the speed of Notepad++ for the user (i.e. Notepad++ may appear to have “locked up”, whilst your event processes).

    Synchronous callbacks are mostly used for calling Editor.autoCCancel() in response to SCINTILLANOTIFICATION.AUTOCSELECTION, but could be used for anything where the timing of the handler function is critical.

    Editor.replace(search, replace[, flags[, startPosition[, endPosition[, maxCount]]]])
    See Editor.rereplace(), as this method is identical, with the exception that the search string is treated literally, and not as a regular expression.

    If you use a function as the replace argument, the function will still receive a re.MatchObject like object as the parameter, group(0) will therefore always contain the string searched for (possibly in a different case if re.IGNORECASE was passed in the flags)

    For example:

    counter = 0

    def get_counter(m):
        global counter
        counter += 1
        return 'C' + str(counter)

    editor.replace('(x)', get_counter, re.IGNORECASE)

    # Replacing:
    #
    #     This (x) is some (X) text.  The bracketed X's will (x) get numerical replacements
    #
    # results in
    #
    #     This C1 is some C2 text.  The bracketed X's will C3 get numerical replacements
    Editor.rereplace(search, replace[, flags[, startPosition[, endPosition[, maxCount]]]])
    The main search and replace method, using regular expressions. The regular expression syntax in use is that from Notepad++, which is actually the Boost::Regex implementation (specifically the Perl regular expression syntax).

    flags are from the re module (e.g. re.IGNORECASE), so import re if you use the flags.

    The re.MULTILINE flag is automatically set, so ^ matches the start of each line of the document, and $ the end of each line. If you want to ^ and $ to match the start and end of the whole document, you can override the behaviour by adding in the editor.WHOLEDOC flag.

    Note that line endings are now handled automatically.

    search can be a string, a unicode string, or an object. An object will be converted to a string using it’s __str__ method. For a unicode string, the current document encoding is checked, and an attempt is made at a conversion. If the conversion cannot be successfully performed, an error occurs. When a standard Python string is used, no conversion takes place. If you need to replace strings in documents in both UTF-8 and ANSI (or other single byte encodings), then it’s best to pass unicode strings.

    replace follows the same conversion rules as search. However, you can also pass a function or lambda expression as the replace parameter. This function receives a single parameter, which is an object resembling a re.MatchObject instance. It only resembles an re.MatchObject because it doesn’t support all the methods. Specifically, groupdict(), pos, endpos, re and string methods and properties are not supported. expand(), group() and groups() (for example) all work identically. The function should return the string to use as the replacement.

    A simple function replacement:

    def add_1(m):
        return 'Y' + str(number(m.group(1)) + 1)

    # replace X followed by numbers by an incremented number
    # e.g.   X56 X39 X999
    #          becomes
    #        Y57 Y40 Y1000

    editor.rereplace('X([0-9]+)', add_1);
    startPosition is the binary position to start the search. Use Editor.positionFromLine() to get the binary position from the (zero indexed) line number.

    endPosition is the binary position to end the search. Use Editor.positionFromLine() to get the binary position from the (zero indexed) line number.

    A maximum of count replacements are made, if zero or None, then all replacements are made.

    An small point to note, is that the replacements are first searched, and then all replacements are made. This is done for performance and reliability reasons. Generally this will have no side effects, however there may be cases where it makes a difference. (Author’s note: If you have such a case, please post a note on the forums such that it can be added to the documentation, or corrected).

    Editor.research(search, matchFunction[, flags[, startPosition[, endPosition[, maxCount]]]])
    The main search method, using regular expressions. The regular expression syntax in use is that from Notepad++, which is actually the Boost::Regex implementation (specifically the Perl regular expression syntax).

    flags are from the re module (e.g. re.IGNORECASE), so import re if you use the flags.

    The re.MULTILINE flag is automatically set, so ^ matches the start of each line of the document, and $ the end of each line. If you want to ^ and $ to match the start and end of the whole document, you can override the behaviour by adding in the editor.WHOLEDOC flag.

    Note that line endings are now handled automatically.

    search can be a string, a unicode string, or an object. An object will be converted to a string using it’s __str__ method. For a unicode string, the current document encoding is checked, and an attempt is made at a conversion. If the conversion cannot be successfully performed, an error occurs. When a standard Python string is used, no conversion takes place. If you need to replace strings in documents in both UTF-8 and ANSI (or other single byte encodings), then it’s best to pass unicode strings.

    matchFunction is a function that gets callled with each match. This function receives a single parameter, which is an object resembling a re.MatchObject instance. It only resembles an re.MatchObject because it doesn’t support all the methods. Specifically, groupdict(), pos, endpos, re and string methods and properties are not supported. expand(), group() and groups() (for example) all work identically. The function should return the string to use as the replacement.

    A simple function replacement:

    matches = []
    def match_found(m):
        # append the match (start, end) positions to the matches array
        matches.append(m.span(0))

    # find X followed by numbers
    # e.g.   X56 X39 X999

    editor.research('X([0-9]+)', match_found)
    You can do the same thing with a lambda expression:

    matches = []

    editor.research('X([0-9]+)', lambda m: matches.append(m.span(0)))
    startPosition is the binary position to start the search. Use Editor.positionFromLine() to get the binary position from the (zero indexed) line number.

    endPosition is the binary position to end the search. Use Editor.positionFromLine() to get the binary position from the (zero indexed) line number.

    If maxCount is not zero or None, then the search stops as soon as maxCount matches have been found.

    Editor.pyreplace(search, replace[, count[, flags[, startLine[, endLine]]]])
    This method has been removed from version 1.0. It was last present in version 0.9.2.0

    You should use Editor.rereplace().

    Editor.pymlreplace(search, replace[, count[, flags[, startPosition[, endPosition]]]])
    This method has been removed from version 1.0. It was last present in version 0.9.2.0

    You should use Editor.rereplace().

    Editor.pysearch(expression, function[, flags[, startLine[, endLine]]])
    This method has been removed from version 1.0. It was last present in version 0.9.2.0

    You should use Editor.research().

    Editor.pymlsearch(expression, function[, flags[, startPosition[, endPosition]]])
    This method has been removed from version 1.0. It was last present in version 0.9.2.0

    You should use Editor.research().

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