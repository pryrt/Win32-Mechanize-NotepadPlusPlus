=head1 Cut from here

    Editor.getCharacterPointer() → str
    Gets a copy of the text of the document, without first allowing Scintilla to make it’s copy of it. In practice, that means it does exactly the same as Editor.getText, however, if you have the possibility of the user interfering with the document _whilst_ getCharacterPointer() is running, then it’s safer to use getText(). On larger documents, getCharacterPointer() could be noticable quicker.

    See Scintilla documentation for SCI_GETCHARACTERPOINTER

    Editor.markerLineFromHandle(handle) → int
    Retrieve the line number at which a particular marker is located.

    See Scintilla documentation for SCI_MARKERLINEFROMHANDLE

    Editor.markerDeleteHandle(handle)
    Delete a marker.

    See Scintilla documentation for SCI_MARKERDELETEHANDLE

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

    Editor.assignCmdKey(km, msg)
    When key+modifier combination km is pressed perform msg.

    See Scintilla documentation for SCI_ASSIGNCMDKEY

    Editor.clearCmdKey(km)
    When key+modifier combination km is pressed do nothing.

    See Scintilla documentation for SCI_CLEARCMDKEY

    Editor.clearAllCmdKeys()
    Drop all key mappings.

    See Scintilla documentation for SCI_CLEARALLCMDKEYS

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

    Editor.setStyleBits(bits)
    Divide each styling byte into lexical class bits (default: 5) and indicator bits (default: 3). If a lexer requires more than 32 lexical states, then this is used to expand the possible states.

    See Scintilla documentation for SCI_SETSTYLEBITS

    Editor.getStyleBits() → int
    Retrieve number of bits in style bytes used to hold the lexical state.

    See Scintilla documentation for SCI_GETSTYLEBITS

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

    Editor.getCodePage() → int
    Get the code page used to interpret the bytes of the document as characters.

    See Scintilla documentation for SCI_GETCODEPAGE

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

    Editor.null()
    Null operation.

    See Scintilla documentation for SCI_NULL

    Editor.getDirectFunction() → int
    Retrieve a pointer to a function that processes messages for this Scintilla.

    See Scintilla documentation for SCI_GETDIRECTFUNCTION

    Editor.getDirectPointer() → int
    Retrieve a pointer value to use as the first argument when calling the function returned by GetDirectFunction.

    See Scintilla documentation for SCI_GETDIRECTPOINTER

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

    Editor.linesJoin()
    Join the lines in the target.

    See Scintilla documentation for SCI_LINESJOIN

    Editor.linesSplit(pixelWidth)
    Split the lines in the target into lines that are less wide than pixelWidth where possible.

    See Scintilla documentation for SCI_LINESSPLIT

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

    Editor.usePopUp(allowPopUp)
    Set whether a pop up menu is displayed automatically when the user presses the wrong mouse button.

    See Scintilla documentation for SCI_USEPOPUP

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

    Editor.delLineLeft()
    Delete back from the current position to the start of the line.

    See Scintilla documentation for SCI_DELLINELEFT

    Editor.delLineRight()
    Delete forwards from the current position to the end of the line.

    See Scintilla documentation for SCI_DELLINERIGHT

    Editor.grabFocus()
    Set the focus to this Scintilla widget.

    See Scintilla documentation for SCI_GRABFOCUS

    Editor.setPrintWrapMode(mode)
    Set printing to line wrapped (SC_WRAP_WORD) or not line wrapped (SC_WRAP_NONE).

    See Scintilla documentation for SCI_SETPRINTWRAPMODE

    Editor.getPrintWrapMode() → int
    Is printing line wrapped?

    See Scintilla documentation for SCI_GETPRINTWRAPMODE

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

    Editor.selectionDuplicate()
    Duplicate the selection. If selection empty duplicate the line containing the caret.

    See Scintilla documentation for SCI_SELECTIONDUPLICATE

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

    Editor.markerSymbolDefined(markerNumber) → int
    Which symbol was defined for markerNumber with MarkerDefine

    See Scintilla documentation for SCI_MARKERSYMBOLDEFINED

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

    Editor.changeLexerState(start, end) → int
    Indicate that the internal state of a lexer has changed over a range and therefore there may be a need to redraw.

    See Scintilla documentation for SCI_CHANGELEXERSTATE

    Editor.contractedFoldNext(lineStart) → int
    Find the next line at or after lineStart that is a contracted fold header line. Return -1 when no more lines.

    See Scintilla documentation for SCI_CONTRACTEDFOLDNEXT

    Editor.verticalCentreCaret()
    Centre current line in window.

    See Scintilla documentation for SCI_VERTICALCENTRECARET

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
