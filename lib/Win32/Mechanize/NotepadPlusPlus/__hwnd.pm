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

my $MAX_PATH = 1024;

# $obj->SendMessage_getUcs2le( $message_id, $wparam ):
#   issues a SendMessage, and grabs a string up to 1024 bytes, and
#   converts them from UCS-2 LE into up to 512 perl characters
#   RETURN: the Perl string
sub SendMessage_getUcs2le {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift;
    my $wparam = shift;
    my $args = shift || {};
    $args->{charlength} = 2 unless exists $args->{charlength};          # since it's ucs2-le, trim 2 bytes per character
    my $rbuf = $self->SendMessage_getRawString($msgid, $wparam, $args);
    my $text = Encode::decode('ucs2-le',$rbuf);
    return $text;
}

# $obj->SendMessage_getRawString( $message_id, $wparam ):
#   issues a SendMessage, and grabs a string up to 1024 bytes;
#   does not change encoding
#   (includes the memory allocation necessary for cross-application communication)
#   RETURN: the raw string
# want { trim => $value }, where $value can be 'wparam', 'retval', or undef
# want { charlength => $number }
sub SendMessage_getRawString {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam = shift || 0;

    # process args: determine length of strings, in bytes
    my $args = shift || { };
    my $trim = exists $args->{trim} ? $args->{trim} : undef;
    my $charlength = exists $args->{charlength} ? $args->{charlength}//1 : 1;
    my $wlength = exists $args->{wlength} ? $args->{wlength} : 0;

    my $wrv = $wlength ? 0 : $wparam;

    my $length =    $trim eq 'wparam'       ? $wparam :                                   # wparam => characters in string
                    $trim eq 'retval'       ? $self->SendMessage( $msgid, $wrv, 0) :      # SendMessage result => characters
                    !defined($trim)         ? $MAX_PATH :                                 # no length limit, so use MAX_PATH
                    1*$trim eq $trim        ? 0+$trim :                                   # numeric
                    die "unknown trim $trim";

    $length = 1 unless $length>0; # make sure it's always at least one character
    $length *= $charlength;

    $wparam = 1+$length if $wlength;

    # prepare virtual buffer
    my $buf_uc2le = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1+$length );
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
    my $buf_str = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1+length($lparam_string) );
    Win32::GuiTest::WriteToVirtualBuffer( $buf_str, $lparam_string );

    # send the message with the string ptr as the lparam
    my $rslt = Win32::GuiTest::SendMessage($self->hwnd, $msgid, $wparam, $buf_str->{ptr});

    # clear virtual buffer
    Win32::GuiTest::FreeVirtualBuffer( $buf_str );

    # return
    return $rslt;

}

# $obj->SendMessage_sendRawStringAsWparam( $message_id, $wparam_string ):
sub SendMessage_sendRawStringAsWparam {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wparam_string = shift; croak "no wparam string sent" unless defined $wparam_string;
    my $lparam = shift || 0;


    # copy string into virtual buffer
    my $buf_str = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1+length($wparam_string) );
    Win32::GuiTest::WriteToVirtualBuffer( $buf_str, $wparam_string );

    # send the message with the string ptr as the lparam
    my $rslt = Win32::GuiTest::SendMessage($self->hwnd, $msgid, $buf_str->{ptr}, $lparam);

    # clear virtual buffer
    Win32::GuiTest::FreeVirtualBuffer( $buf_str );

    # return
    return $rslt;

}

# $obj->SendMessage_sendRawString_getRawString( $message_id, $send_string, $args ):
sub SendMessage_sendRawString_getRawString {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $send_string = shift; croak "no wparam string sent" unless defined $send_string;
    my $args = shift // { trim => 'retval', wlength => 1 };

    # copy send_string into virtual buffer
    my $send_buf = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1+length($send_string) );
    Win32::GuiTest::WriteToVirtualBuffer( $send_buf, $send_string );

    # allocate empty receive buffer; shouldn't be more than twice the length of the send_string
    my $recv_buf = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd , 1+2*length($send_string) );

    # send the message with the string ptr as the wparam
    my $ret = $self->SendMessage( $msgid, $send_buf->{ptr}, $recv_buf->{ptr} );

    # read it back
    my $rslt = Win32::GuiTest::ReadFromVirtualBuffer( $recv_buf, $ret );

    # clear virtual buffers
    Win32::GuiTest::FreeVirtualBuffer( $send_buf );
    Win32::GuiTest::FreeVirtualBuffer( $recv_buf );

    # return
    return $rslt;

}

# $obj->SendMessage_sendTwoRawStrings( $message_id, $wstring, $lstring, $args ):
sub SendMessage_sendTwoRawStrings {
    my $self = shift; croak "no object sent" unless defined $self;
    my $msgid = shift; croak "no message id sent" unless defined $msgid;
    my $wstring = shift; croak "no wparam string sent" unless defined $wstring;
    my $lstring = shift; croak "no lparam string sent" unless defined $lstring;
    my $args = shift // { trim => 'retval', wlength => 1 };

    # copy wstring into virtual buffer
    my $wbuf = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd, 1+length($wstring) );
    Win32::GuiTest::WriteToVirtualBuffer( $wbuf, $wstring );

    # copy lstring into virtual buffer
    my $lbuf = Win32::GuiTest::AllocateVirtualBuffer( $self->hwnd , 1+length($lstring) );
    Win32::GuiTest::WriteToVirtualBuffer( $lbuf, $lstring );

    # send the message with the string pointers as wparam and lparam
    my $ret = $self->SendMessage( $msgid, $wbuf->{ptr}, $lbuf->{ptr} );

    # clear virtual buffers
    Win32::GuiTest::FreeVirtualBuffer( $wbuf );
    Win32::GuiTest::FreeVirtualBuffer( $lbuf );

    # return
    return $ret;

}

1;