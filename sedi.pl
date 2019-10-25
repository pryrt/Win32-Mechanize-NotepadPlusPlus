#!perl -p
use strict;
use warnings;
use utf8;

our %keep;
BEGIN {
    #system("chcp", 65001);
    binmode STDOUT, ':unix:encoding(utf8):crlf';
    binmode STDERR, ':unix:encoding(utf8):crlf';
    print "arrow →\n";
}

binmode ARGV, ':unix:encoding(utf8):crlf';

/^=(begin|end) scintilla/ and do { $_ = '' };
/^(SCI_\w+)(.*?)$/ and do {
    $keep{$1} = $1.$2;
    $_ = '';
    print STDERR "=for comment found '$1' => '$1$2'\n\n";
};
/^(SCE?N_\w+)(.*?)$/ and do {
    $_ = "=for comment $1$2\n\n";
};
/^    sciProto => '(\w+)',/ and do {
    my $key = $1;
    if(exists $keep{$key}) {
        s/'$key'/'$keep{$key}'/;
    }
};
/^    subProto => '(SCI_(\w+))',/ and do {
    my $key = $1;
    my $w = $2;
    if(exists $keep{$key}) {
        s/'$key'/'todo_\L$w\E'/;
    }
};
