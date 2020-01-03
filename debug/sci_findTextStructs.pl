#!perl
use warnings;
use strict;
use 5.010;

use Win32::GuiTest 1.64 ();  # used to be ':FUNC', but that made SendMessage collide with ->SendMessage; use no imports, and always be explicit about
use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

my $regex = "#include";
my $nchars = length($regex) + 1;
printf STDERR qq(regex = "%s" [%d]\n), $regex, $nchars;

my $vstr = Win32::GuiTest::AllocateVirtualBuffer( notepad->{_hwnd}, $nchars );

my $packed_struct = pack "LLQLL", 0, 9999, $vstr->{ptr}, -1, -1;

print STDERR "packed_struct = 0x"; printf STDERR "%02x ", ord($_) for split //, $packed_struct; print STDERR "\n";

Win32::GuiTest::FreeVirtualBuffer( $vstr );