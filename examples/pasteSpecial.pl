#!/usr/bin/env perl
################################################
# PasteSpecial for Notepad++
#   List formats currently on the clipboard
#   Allows you to choose one of those formats
#   Will paste the selected type (UTF8-encoded)
#   at the current location in the active file
################################################

use 5.010;
use warnings;
use strict;
use Win32::API;
use Win32::Clipboard;
use Encode;

use Win32::Mechanize::NotepadPlusPlus qw/:main/;

BEGIN {
    binmode STDERR, ':utf8';
    binmode STDOUT, ':utf8';
    my $anon = Win32::API::More->new( 'user32', 'RegisterClipboardFormat', 'P', 'I' ) or die "hooking to user32.dll::RegisterClipboardFormat: $^E"; # [id://1197110]
    sub Win32::Clipboard::RegisterClipboardFormat {
        my $self = shift;
        my $format_string = shift;
        return $anon->Call($format_string);
    }
}
my %map = (
    CF_TEXT()           => 'CF_TEXT',
    CF_BITMAP()         => 'CF_BITMAP',
    CF_METAFILEPICT()   => 'CF_METAFILEPICT',
    CF_SYLK()           => 'CF_SYLK',
    CF_DIF()            => 'CF_DIF',
    CF_TIFF()           => 'CF_TIFF',
    CF_OEMTEXT()        => 'CF_OEMTEXT',
    CF_DIB()            => 'CF_DIB',
    CF_PALETTE()        => 'CF_PALETTE',
    CF_PENDATA()        => 'CF_PENDATA',
    CF_RIFF()           => 'CF_RIFF',
    CF_WAVE()           => 'CF_WAVE',
    CF_UNICODETEXT()    => 'CF_UNICODETEXT',
    CF_ENHMETAFILE()    => 'CF_ENHMETAFILE',
    CF_HDROP()          => 'CF_HDROP',
    CF_LOCALE()         => 'CF_LOCALE',
);
my %rmap; @rmap{values %map} = keys %map;
use Data::Dumper; $Data::Dumper::Useqq=1;


my $CLIP = Win32::Clipboard; # start with existing clipboard, I hope
#printf STDERR "register(%s) = %d\n", $_, $CLIP->RegisterClipboardFormat($_)   for 'HTML Format', 'MSDEVColumnSelect', 'Borland IDE Block Type';

my @f = $CLIP->EnumFormats();
printf STDERR "Formats active in clipboard:\n";
foreach my $format (sort {$a <=> $b} @f) {
    $map{$format} //= $CLIP->GetFormatName($format) // '<unknown>';
    $rmap{ $map{$format} } = $format;
    printf STDERR "%-8d => '%s'\n", $format, $map{$format};
}
my $selection;
while(!defined $selection) {
    printf STDERR "choose one: ";
    $selection = <STDIN>;
    chomp $selection;
    $selection = $rmap{$selection} if exists $rmap{$selection}; # selection was a format name; now converted to format number
    last if exists $map{$selection};    # selection is a valid format number
    undef $selection;
}
printf STDERR "final selection: %d => %s\n", $selection, $map{$selection};
my $get = $CLIP->GetAs($selection);
if($selection == CF_UNICODETEXT()) {
    $get = Encode::decode( "UTF16-LE", $get );
}
printf STDERR "got => '%s'\n", $get;
editor->addText(Encode::encode("UTF8", $get));
