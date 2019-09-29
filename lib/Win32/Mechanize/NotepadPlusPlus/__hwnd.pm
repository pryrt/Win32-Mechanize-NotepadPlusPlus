package Win32::Mechanize::NotepadPlusPlus::__hwnd;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use Carp;
use Win32::GuiTest 1.64 ();  # used to be ':FUNC', but that made SendMessage collide with ->SendMessage; use no imports, and always be explicit about
use Encode ();

=pod

=head1 NAME

Win32::Mechanize::NotepadPlusPlus::__hwnd - Background object for windows Win32 API communication

=head1 DESCRIPTION

Don't use directly.  This is for under-the-hood Win32 API communication with the Notepad++
window and subwindows.

Any functions and/or objects implemented will be described in comments, not in POD.

=head1 COPYRIGHT

Copyright (C) 2019 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

# CLASS->new( $hwnd ):
#   blesses an object with the hwnd
sub new {
    my($class,$hwnd) = @_;
    bless \$hwnd, $class;
}

# $obj->hwnd():
#   returns the hwnd value
sub hwnd {
    ${$_[0]}
}

# $obj->SendMessage( $message_id, $wparam , $lparam ):
#   wrapper equivalent of Wi32::GuiTest::SendMessage($obj->hwnd, $message_id, $wparam, $lparam)
sub SendMessage {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;    croak "wparam must be a scalar, not a ".ref($wparam) unless UNIVERSAL::isa(\$wparam, 'SCALAR');
    my $lparam = shift || 0;    croak "lparam must be a scalar, not a ".ref($lparam) unless UNIVERSAL::isa(\$lparam, 'SCALAR');
    Win32::GuiTest::SendMessage($self->hwnd, $msgid, $wparam, $lparam);
}

# $obj->SendMessage_get32u( $message_id, $wparam ):
#   issues a SendMessage, and grabs a 32-bit unsigned integer (ie, unsigned long) from the LPARAM
#   (includes the memory allocation necessary for cross-application communication)
#   RETURN: 32-bit unsigned integer
sub SendMessage_get32u {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;
    my $buf_32u = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 4 );  # 32bits is 4 bytes
    Win32::GuiTest::WriteToVirtualBuffer( $buf_32u , pack("L!",-1));             # pre-populate with -1, to easily recognize if the later Read doesn't work
    my $rslt = $self->SendMessage($msgid, $wparam, $buf_32u->{ptr});
    #diag "SendMessage_get32u(@{[$self->hwnd]}, $msgid, $wparam, @{[explain $buf_32u]} ) = $rslt";
    my $rbuf = Win32::GuiTest::ReadFromVirtualBuffer( $buf_32u, 4 );
    Win32::GuiTest::FreeVirtualBuffer( $buf_32u );
    return unpack('L!', $rbuf);     # returns the value, not the rslt
}

sub debug_log {
    my $name = shift;
    my $self = shift;
    my $hwnd = $self->hwnd;
    my ($msgid,$wparam,$lparam) = map { $_ // '<undef>' } shift, shift, shift;
    my @extra = map { $_ // '<undef>' } @_;
    if(ref($lparam) and UNIVERSAL::isa($lparam, 'HASH')) { unshift @extra , %$lparam; $lparam = '<undef>'; };
    open my $log, '>>', $ENV{TEMP}."/stringMessages.txt" or die "stringMessages.txt: $!";
    local $"=', ';
    printf {$log} "%s(h:%s, m:%s, w:%s, l:%s)\n", $name, $hwnd, $msgid, $wparam, $lparam;
    print {$log} "\textra = (@extra)\n" if @extra;
    printf {$log} "\tcaller(%d) = (%s)\n", 0, join(",", map {$_//'<undef>'} (caller(0))[1..3]);
    printf {$log} "\tcaller(%d) = (%s)\n", 1, join(",", map {$_//'<undef>'} (caller(1))[1..3]);
}

my $MAX_PATH = 1024;

# $obj->SendMessage_getUcs2le( $message_id, $wparam ):
#   issues a SendMessage, and grabs a string up to 1024 bytes, and
#   converts them from UCS-2 LE into up to 512 perl characters
#   RETURN: the Perl string
sub SendMessage_getUcs2le {
#debug_log('SendMessage_getUcs2le', @_);
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift;
    my $wparam = shift;
    my $args = shift || {};
    $args->{charlength} = 2 unless exists $args->{charlength};          # since it's ucs2-le, trim 2 bytes per character
    my $rbuf = $self->SendMessage_getRawString($msgid, $wparam, $args);
    my $text = Encode::decode('ucs2-le',$rbuf);
    return $text;
}

# $obj->SendMessage_getUcs2le( $message_id, $wparam ):
#   issues a SendMessage, and grabs a string up to 1024 bytes;
#   does not change encoding
#   (includes the memory allocation necessary for cross-application communication)
#   RETURN: the raw string
# want { trim => $value }, where $value can be 'wparam', 'retval', or undef
sub SendMessage_getRawString {
#debug_log('SendMessage_getRawString',@_);
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;
    my $args = shift || { };
unless(ref $args) {
    warn sprintf "!! trimFactor is being replaced: %s !!\n", $args;
    for my $level (1..4) {
        my @c = caller($level);
        last unless @c;
        warn sprintf "!!\t%s,%s,%s\n", @c[1..3];
    }
    Carp::confess "!"x40, "\n";
}
    my $trim = exists $args->{trim} ? $args->{trim} : undef;
    my $charlength = exists $args->{charlength} ? $args->{charlength}//1 : 1;

    my $length =    $trim eq 'wparam'       ? $wparam :                                   # wparam => characters in string
                    $trim eq 'retval'       ? $self->SendMessage( $msgid, $wparam, 0) :   # SendMessage result => characters
                    !defined($trim)         ? $MAX_PATH :                                 # no length limit, so use MAX_PATH
                    1*$trim eq $trim        ? 0+$trim :                                   # numeric
                    die "unknown trim $trim";

    $length *= $charlength;

    # prepare virtual buffer
    my $buf_uc2le = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, $length );
    Win32::GuiTest::WriteToVirtualBuffer( $buf_uc2le, "\0"x$length );

    # grab the raw string from HWND
    my $rslt = $self->SendMessage( $msgid, $wparam, $buf_uc2le->{ptr});
    croak "SendMessage_getRawString(): $rslt NOT >= 0" if $rslt<0;
    #carp "SendMessage_getRawStr(@{[$self->hwnd]}, $msgid, $wparam, @{[$buf_uc2le]} ) = $rslt";

    # transfer from virtual buffer to perl
    my $rbuf = Win32::GuiTest::ReadFromVirtualBuffer( $buf_uc2le, $length );
    Win32::GuiTest::FreeVirtualBuffer( $buf_uc2le );
    #use Data::Dumper; $Data::Dumper::Useqq=1;
    #carp "raw before trim => ", Dumper $rbuf;

    # trim down to $length bytes (where $length already adjusted for $charlength bytes per char
    $rbuf = substr $rbuf, 0, $length if length($rbuf) > $length;
    #carp "raw after trim => ", Dumper $rbuf;

    return $rbuf;   # return the raw string
}

# $obj->SendMessage_sendStrAsUcs2le( $message_id, $wparam , $lparam_string ):
#   issues a SendMessage, sending a string (encoded as UCS-2 LE)
sub SendMessage_sendStrAsUcs2le {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift; croak "no wparam sent" unless defined $wparam;
    my $lparam_string = shift; croak "no lparam string sent" unless defined $lparam_string;

    # convert string to UCS-2 LE
    my $ucs2le = Encode::encode('ucs2-le', $lparam_string);

    # use the raw-string version of the SendMessage...
    return $self->SendMessage_sendRawString($msgid, $wparam, $ucs2le);
}

# $obj->SendMessage_sendRawString( $message_id, $wparam , $lparam_string ):
sub SendMessage_sendRawString {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift; croak "no wparam sent" unless defined $wparam;
    my $lparam_string = shift; croak "no lparam string sent" unless defined $lparam_string;

    # copy string into virtual buffer
    my $buf_str = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, length($lparam_string) );
    Win32::GuiTest::WriteToVirtualBuffer( $buf_str, $lparam_string );

    # send the message with the string ptr as the lparam
    my $rslt = Win32::GuiTest::SendMessage($self->hwnd, $msgid, $wparam, $buf_str->{ptr});

    # clear virtual buffer
    Win32::GuiTest::FreeVirtualBuffer( $buf_str );

    # return
    return $rslt;

}



1;