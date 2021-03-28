########################################################################
# Scintilla multi-edge support
#   These are all auto-generated, so don't need to be tested for
#   true coverage.  Also, running in normal installation would wipe
#   out the user's multi-edge settings, which might upset the user
#   ... so only run as xt-style author test.
########################################################################
use 5.010;
use strict;
use warnings;
use Test::More;
use version;

use FindBin;
BEGIN { my $f = $FindBin::Bin . '/../t/nppPath.inc'; require $f if -f $f; }

use lib $FindBin::Bin;
use lib $FindBin::Bin . '/../t';
use myTestHelpers qw/:userSession dumper/;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus qw/:main :vars/;

#   if any unsaved buffers, HALT test and prompt user to save any critical
#       files, then re-run test suite.
my $EmergencySessionHash;
BEGIN { $EmergencySessionHash = saveUserSession(); }
END { restoreUserSession( $EmergencySessionHash ); }

BEGIN {
    notepad()->closeAll();
    notepad()->open( path($0)->absolute->canonpath() );
}

my $ver = version->parse(notepad()->getNppVersion());
if( $ver < version->parse('v7.9.4') ) {
    plan skip_all => "getMultiEdgeColumn not implemented in $ver";
}

my $got = editor->multiEdgeClearAll();
ok defined($got), 'editor->multiEdgeClearAll() ok';
    #note sprintf "\tgot = %s\n", explain($got//'<undef>');
my @set = (5,7,11);
for my $which ( 0 .. 2 ) {
    $got = editor->multiEdgeAddLine($set[$which]);
    ok defined($got), 'editor->multiEdgeAddLine(' . $set[$which] . ') ok';
    #note sprintf "\tgot = %s\n", explain($got//'<undef>');
    $got = editor->getMultiEdgeColumn($which);
    is $got, $set[$which], 'editor->getMultiEdgeColumn('.$which.') ok';
    #note sprintf "\tedge = %s\n", explain($got//'<undef>');
}
my $name = 'editor->getMultiEdgeColumn() always right';
for(0..1) {
    my @get = ();
    my $which = 0;
    while( ($got = editor->getMultiEdgeColumn($which)) > -1 ) {
        push @get, $got;
        ++$which;
    }
    is_deeply \@get, \@set, $name;
        note sprintf 'set = (%s)', join(',', map { $_//'<undef>' } @set);
        note sprintf 'get = (%s)', join(',', map { $_//'<undef>' } @get);
    editor->multiEdgeClearAll();
    $name = 'editor->getMultiEdgeColumn() right after multiEdgeClear()';
    @set = ();
}

done_testing(9);
