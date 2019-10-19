#!/usr/bin/env perl

# can I figure out how to auto-generate a correct sub using AUTOLOAD
BEGIN { select STDERR; $\ = "\n"; }

my %ok = map { __PACKAGE__.'::'.$_ => rand } qw/george rex/;

sub grandpa { 'I am grandpa' }
sub AUTOLOAD {
    (my $cmd = our $AUTOLOAD);# =~ s/.*:://;  # it comes in with __PACKAGE__::commandname, so either strip the package here, or include the package in the %ok key
    print qq|Trying to AUTOLOAD "$cmd"|;
    if( exists $ok{$cmd} ) {
        no strict 'refs';
        *$cmd = sub { sprintf 'I was created as "%s" with "%s"', $cmd, $ok{$cmd}; };
        goto &$cmd;
    }
    die qq|Undefined subroutine $cmd called at [program] line [#]."|;
}

eval { print grandpa('args'); 1; } or warn "grandpa() had problems: $@\n";
eval { print george('args'); 1; } or warn "george() had problems: $@\n";
eval { print rex('args'); 1; } or warn "rex() had problems: $@\n";
eval { print tyrranus('args'); 1; } or warn "tyrranus() had problems: $@\n";

=begin comment
Since that works, my idea for Editor.pm (or a big portion):

Map the PythonScript-based method name to the https://www.scintilla.org/ScintillaDoc.html nomenclature
    For example,
        %ok = (
            getText => "SCI_GETTEXT(position length, char *text) → position"
        );

In autoload,
    1. check if the key exists
    2. if it does, parse the value $ok{$cmd} to create a wrapper sub
        1. make sure that $message exists in %scimsg
        2. write the wrapper and define `*$cmd = sub ...`
        3. `goto &$cmd`
        4. since we defined that sub, in future calls, it will just call that sub
    3. else die with the undefined-subroutine error


=cut
1;