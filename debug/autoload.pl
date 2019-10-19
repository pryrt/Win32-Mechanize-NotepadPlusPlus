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
    die qq|Failed to AUTOLOAD "$cmd"|;
}

eval { print grandpa('args'); 1; } or warn "grandpa() had problems: $@\n";
eval { print george('args'); 1; } or warn "george() had problems: $@\n";
eval { print rex('args'); 1; } or warn "rex() had problems: $@\n";
eval { print tyrranus('args'); 1; } or warn "tyrranus() had problems: $@\n";