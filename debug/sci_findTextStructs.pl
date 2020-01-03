#!perl
use warnings;
use strict;
use 5.010;

use Win32::GuiTest 1.64 ();  # used to be ':FUNC', but that made SendMessage collide with ->SendMessage; use no imports, and always be explicit about
use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

# define the search string
my $regex = "#include";
my $nchars = length($regex) + 1;
printf STDERR qq(regex = "%s" [%d]\n), $regex, $nchars;

# memory for the packed string
my $vstr = Win32::GuiTest::AllocateVirtualBuffer( editor1->{_hwnd}, $nchars );
Win32::GuiTest::WriteToVirtualBuffer( $vstr , $regex );

# create the bytes for the structure
my $packed_struct = pack "L L Q L L", 0, 9999, $vstr->{ptr}, -1, -1;
print STDERR "packed_struct = 0x"; printf STDERR "%02x ", ord($_) for split //, $packed_struct; print STDERR "\n";
{
    my ($smin,$smax,$ptr,$tmin,$tmax) = unpack "L L Q L L", $packed_struct;
    printf STDERR "\t(%s,%s) 0x%08x (%s,%s)\n", $smin,$smax,$ptr,$tmin,$tmax;
}

# memory for the structure
my $vttf = Win32::GuiTest::AllocateVirtualBuffer( editor1->{_hwnd}, length($packed_struct) );
Win32::GuiTest::WriteToVirtualBuffer( $vttf , $packed_struct );

# send the message
eval {
    my $hwnd = editor1->{_hwnd};
    my $ret = Win32::GuiTest::SendMessage($hwnd, $scimsg{SCI_FINDTEXT}, $scimsg{SCFIND_WHOLEWORD}, $vttf->{ptr});
    printf STDERR "SendMessage(0x%08x, %16d, %16d, %16d) = %s\n", $hwnd, $scimsg{SCI_FINDTEXT}, $scimsg{SCFIND_WHOLEWORD}, $vttf->{ptr}, $ret;
    1;
} or do {
    warn "SendMessage error = '$@'";
};

# read back the virtual structure
my $new_struct = Win32::GuiTest::ReadFromVirtualBuffer( $vttf , length($packed_struct) );
print STDERR "new_struct    = 0x"; printf STDERR "%02x ", ord($_) for split //, $new_struct; print STDERR "\n";

# grab the values from the structure:
{
    my ($smin,$smax,$ptr,$tmin,$tmax) = unpack "L L Q L L", $new_struct;
    printf STDERR "\t(%s,%s) 0x%08x (%s,%s)\n", $smin,$smax,$ptr,$tmin,$tmax;
}

# free virtual memories at the end
Win32::GuiTest::FreeVirtualBuffer( $vttf );
Win32::GuiTest::FreeVirtualBuffer( $vstr );