package Win32::Mechanize::NotepadPlusPlus::__hwnd;
use 5.006;
use warnings;
use strict;
use Exporter 'import';
use Carp;
use Win32::GuiTest ();  # used to be ':FUNC', but that made SendMessage collide with ->SendMessage; use no imports, and always be explicit about
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
    my $wparam = shift || 0;
    my $lparam = shift || 0;
    Win32::GuiTest::SendMessage($self->hwnd, $msgid, $wparam, $lparam);
}

# $obj->SendMessage_sendLstr( $message_id, $wparam , $lparam_string ):
sub SendMessage_sendLstr {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;
    my $lparam_string = shift || "";

    # copy string into virtual buffer
    my $buf_str = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, length($lparam_string)+1 );
    Win32::GuiTest::WriteToVirtualBuffer( $buf_str, $lparam_string );

    # send the message with the string ptr as the lparam
    my $rslt = Win32::GuiTest::SendMessage($self->hwnd, $msgid, $wparam, $buf_str->{ptr});

    # clear virtual buffer
    Win32::GuiTest::FreeVirtualBuffer( $buf_str );

    # return
    return $rslt;
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

# $obj->SendMessage_getUcs2le( $message_id, $wparam ):
#   issues a SendMessage, and grabs a string up to 1024 bytes, and
#   converts them from UCS-2 LE into up to 512 perl characters
#   (includes the memory allocation necessary for cross-application communication)
#   RETURN: the Perl string
sub SendMessage_getUcs2le {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;

    my $buf_uc2le = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1024 );   # 1024 byte string maximum
    Win32::GuiTest::WriteToVirtualBuffer( $buf_uc2le, "\0"x1024 );                # pre-populate
    my $rslt = $self->SendMessage( $msgid, $wparam, $buf_uc2le->{ptr});
    #diag "SendMessage_getStr(@{[$self->hwnd]}, $msgid, $wparam, @{[explain $buf_uc2le]} ) = $rslt";
    my $rbuf = Win32::GuiTest::ReadFromVirtualBuffer( $buf_uc2le, 1024 );
    Win32::GuiTest::FreeVirtualBuffer( $buf_uc2le );
    return substr Encode::decode('ucs2-le', $rbuf), 0, $rslt;   # return the valid characters from the raw string
}


1;