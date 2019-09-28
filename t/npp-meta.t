########################################################################
# Verifies Notepad object messages / methods work
#   subgroup: meta-information methods
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;
use Win32;

use Path::Tiny 0.018 qw/path tempfile/;

use Win32::Mechanize::NotepadPlusPlus ':main';

TODO: {
    local $TODO = 'unimplemented';

    my $ret;
    $ret = notepad()->getNppVersion;
    ok $ret, 'getNppVersion' or diag "\tgot: ", explain $ret;

    local $TODO;
    $ret = notepad()->getPluginVersion;
    like $ret, qr/v\d+\.[\._\d]+/, 'getPluginVersion' or diag "\tgot: ", explain $ret;

    $ret = notepad()->getPerlVersion;
    ok $ret, 'getPerlVersion' or diag "\tgot: ", explain $ret;
    $ret = notepad()->getPerlBits;
    ok $ret, 'getPerlBits' or diag "\tgot: ", explain $ret;

    local $TODO = 'unimplemented';
    $ret = notepad()->getCommandLine;
    ok $ret, 'getCommandLine' or diag "\tgot: ", explain $ret;
    $ret = notepad()->getNppDir;
    ok $ret, 'getNppDir' or diag "\tgot: ", explain $ret;
    $ret = notepad()->getPluginConfigDir;
    ok $ret, 'getPluginConfigDir' or diag "\tgot: ", explain $ret;
}

done_testing;