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
use Win32::Clipboard;
use Win32::GUI;
use Win32::GUI::Constants qw/CW_USEDEFAULT/;
use Encode;
use Win32::Mechanize::NotepadPlusPlus 0.004 qw/:main/;

our $VERSION = 1.0; # this works even with W32MNPP v0.004

BEGIN {
    binmode STDERR, ':utf8';
    binmode STDOUT, ':utf8';
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

my $CLIP = Win32::Clipboard;

my @f = $CLIP->EnumFormats();
#printf STDERR "Formats active in clipboard:\n";
foreach my $format (sort {$a <=> $b} @f) {
    $map{$format} //= $CLIP->GetFormatName($format) // '<unknown>';
    $rmap{ $map{$format} } = $format;
    #printf STDERR "%-8d => '%s'\n", $format, $map{$format};
}
if(0){
my $selection;
while(!defined $selection) {
    printf STDERR "choose one: ";
    $selection = 13;
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
#printf STDERR "got => '%s'\n", $get;
}

my $answer = runDialog(\@f, \%rmap);
#printf STDERR "answer => '%s'\n", $answer;
#printf STDERR "answer => '%s'\n", Encode::encode('UTF8', $answer);   # double-encoded (once by Encode, once by binmode :utf8)
editor->addText(Encode::encode("UTF8", $answer)) if defined $answer;

exit;

sub runDialog {
    my @formats = @{ shift() };
    my %rmap = %{ shift() };
    my %map; @map{ values %rmap } = keys %rmap;

    my $clipboard;

    my $dlg = Win32::GUI::Window->new(
        -title          => 'Notepad++ Paste Special',
        -left           => CW_USEDEFAULT,
        -top            => CW_USEDEFAULT,
        -size           => [580,300],
        -resizable      => 0,
        -maximizebox    => 0,
        -toolwindow     => 1,
    );

    my $lb = $dlg->AddListbox(
        -name           => 'LB',
        -pos            => [10,10],
        -size           => [230, $dlg->ScaleHeight()-10],
        -vscroll        => 1,
        -onSelChange    => sub {
                                my $self = shift;
                                my $value = $self->GetText($self->GetCurSel());
                                my $f=$rmap{$value};
                                #printf STDERR "%-15s => %d\n", $value, $f;
                                $clipboard = $CLIP->GetAs($f);
                                $clipboard = Encode::decode('UTF16-LE', $clipboard) if $f == CF_UNICODETEXT();
                                #printf STDERR "%-15s => '%s'\n", clipboard => $clipboard;
                                (my $preview = $clipboard) =~ s/([^\x20-\x7F\r\n])/sprintf '\x{%02X}', ord $1/ge;
                                $preview =~ s/\R/\r\n/g;
                                $self->GetParent()->PREVIEW->Text( $preview );
                                return 1;
                            },
    );
    $dlg->LB->Add( @map{ sort {$a<=>$b} @formats } );

    $dlg->AddButton(
        -name    => 'OK',
        -text    => 'Paste',
        -size    => [80,25],
        -left    => $dlg->ScaleWidth()-90-90,
        -top     => $dlg->LB->Top()+$dlg->LB->Height()-25,
        -onClick => sub{-1;},
    );

    $dlg->AddButton(
        -name    => 'CANCEL',
        -text    => 'Cancel',
        -size    => [80,25],
        -left    => $dlg->ScaleWidth()-90,
        -top     => $dlg->LB->Top()+$dlg->LB->Height()-25,
        -onClick => sub{ $clipboard=undef; -1; },
    );

    $dlg->AddGroupbox(
        -name  => 'GB',
        -title => 'Preview',
        -pos   => [250,10],
        -size  => [$dlg->ScaleWidth()-260, $dlg->OK->Top()-20],
    );

    $dlg->AddLabel(
        -name           => 'PREVIEW',
        -left           => $dlg->GB->Left()+10,
        -top            => $dlg->GB->Top()+20,
        -width          => $dlg->GB->ScaleWidth()-20,
        -height         => $dlg->GB->ScaleHeight()-40,
    );

    #$dlg->PREVIEW->Text("<Please choose a format>");

    $dlg->Show();
    Win32::GUI::Dialog();
    return $clipboard;
}

