#!/usr/bin/env perl
# Copyright (C) 2019 Peter C. Jones
#   see LICENSE file

# using this to replace h2ph script,
#   customized to convert into a hash in the resulting .pm, rather than the constant-subs that h2ph creates

use warnings;
use strict;

use FindBin;
use lib $FindBin::Bin;
use ConvertHeader;

my $i = $ARGV[0] || './src/Notepad_plus_msgs.h';
my $o = $ARGV[1] || './lib/Win32/Mechanize/NotepadPlusPlus/__npp_msgs.pm';
my $m = $ARGV[2] || 'Win32::Mechanize::NotepadPlusPlus::__npp_msgs';
my $v = $ARGV[3] || 'nppm';

my %h = ConvertHeader::readIntoHash($i);
ConvertHeader::hash2pm($o, $m, $v, [qw/WM_USER NPPMSG RUNCOMMAND_USER/], %h);
