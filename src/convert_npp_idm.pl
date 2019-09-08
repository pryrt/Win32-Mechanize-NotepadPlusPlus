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

my $i = $ARGV[0] || './src/menuCmdID.h';
my $o = $ARGV[1] || './lib/Win32/Mechanize/NotepadPlusPlus/__npp_idm.pm';
my $m = $ARGV[2] || 'Win32::Mechanize::NotepadPlusPlus::__npp_idm';
my $v = $ARGV[3] || 'nppidm';

my %h = ConvertHeader::readIntoHash($i);
ConvertHeader::hash2pm($o, $m, $v, [qw/WM_USER IDM IDM_FILE IMD_EDIT IDM_FORMAT/], %h);
