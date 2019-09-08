#!/usr/bin/env perl
# Copyright (C) 2019 Peter C. Jones
#   see LICENSE file

# derived from convert_npp_msgs.pl
#   customized for scintilla, rather than Notepad++
#   generates a %scimsg hash to contain the messages

use warnings;
use strict;

use FindBin;
use lib $FindBin::Bin;
use ConvertHeader;

my $i = $ARGV[0] || './src/Scintilla.h';
my $o = $ARGV[1] || './lib/Win32/Mechanize/NotepadPlusPlus/__sci_msgs.pm';
my $m = $ARGV[2] || 'Win32::Mechanize::NotepadPlusPlus::__sci_msgs';
my $v = $ARGV[3] || 'scimsg';

my %h = ConvertHeader::readIntoHash($i);
ConvertHeader::hash2pm($o, $m, $v, [], %h);
