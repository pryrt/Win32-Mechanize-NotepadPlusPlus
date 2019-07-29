use ExtUtils::MakeMaker;
use 5.006;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
%mm_args = (
    'NAME'          => 'Win32::Mechanize::NotepadPlusPlus',
    'AUTHOR'        => 'Peter C. jones <petercj AT cpan.org>',
    'VERSION_FROM'  => 'lib/Win32/Mechanize/NotepadPlusPlus.pm',
    'ABSTRACT_FROM' => 'lib/Win32/Mechanize/NotepadPlusPlus.pm',
    'PREREQ_PM'     => {
        'Exporter'          => 5.57,    # needed for `use Exporter qw(import);` notation
        'version'           => 0.77,
        'warnings'          => 0,
        'strict'            => 0,
        'constant'          => 0,
        'Carp'              => 0,
        'Encode'            => 0,
        'IPC::Open2'        => 0,
        'Win32::GuiTest'    => 0,
        'Win32::API'        => 0,
        'File::Which'       => 0,
    },
);

{
    no warnings;
    if( $ExtUtils::MakeMaker::VERSION >= '6.46' ) {
        $mm_args{META_MERGE} = {
            'meta-spec' => {
                version => '2',
                url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
            },
            resources => {
                bugtracker => {
                    mailto  => 'bug-Win32-Mechanize-NotepadPlusPlus@rt.cpan.org',
                    web     => 'https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues',
                },
                repository => {
                    url     => 'https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus.git',
                    web     => 'https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus',
                    type    => 'git',
                },
            },
            keywords => [ 'Notepad++', 'automation'],
            # don't directly use 'provides', because it's an extra step to maintain, and
            # can cause problems (getting a mismatch between the $VERSION string and the
            # provides->{version} will really make it hard to release a next version into CPAN
        },
        # automatically determine the versions for 'provides'; MM->parse_version exists as of MM v6.31, so not a problem with >= 6.46
        #   => this comes out right when printed... but MYMETA.* shows values that look wrong
            #my $vstr = MM->parse_version( $mm_args{VERSION_FROM} );
            #print STDERR $vstr, $/;
            #my $qstr = "'$vstr'";
            #print STDERR $qstr, $/;
            #(my $novstr = $qstr) =~ s/v//;
            #print STDERR $novstr, $/;
        $mm_args{META_MERGE}{provides} = {
            $mm_args{NAME} => {
                file => $mm_args{VERSION_FROM},
                version => MM->parse_version( $mm_args{VERSION_FROM} ),
            }
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.31' ) {
        $mm_args{LICENSE} = 'perl_5';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.48' ) {
        $mm_args{MIN_PERL_VERSION} = '5.6.0';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.52' ) {
        $mm_args{CONFIGURE_REQUIRES} = {
            'ExtUtils::MakeMaker' => '6.52',
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        },
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.64' ) {
        $mm_args{TEST_REQUIRES} = {
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.18' ) {
        $mm_args{SIGN} = 1 if MM->can('signature_target') && $ENV{MM_SIGN_DIST};
    }
}

sub MY::postamble {
    my (undef,%h) = @_;
    #require Data::Dumper;
    #print STDERR Data::Dumper->Dump([\%h], [qw(mm_args{postamble})]);
    return <<'POSTAMBLE';
# TEST_D is used to test for the existence of a directory
TEST_D = $(ABSPERLRUN) -MExtUtils::Command -e test_d --

# run a test coverage report
testcover ::
	$(NOECHO) cover -test -report html

# run author-tests on the original
authtest ::
	$(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

# run author-tests on the distribution
distauthtest :: disttest
	cd $(DISTVNAME) && $(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

# addition to realclean: also delete coverage database, if testcover was run
realclean ::
	$(NOECHO) ( $(TEST_D) cover_db && $(RM_RF) cover_db ) || $(ECHO) realclean:: skip "rm -rf cover_db"

# auto-generate the README from the lib/Win32/Mechanize/NotepadPlusPlus.pm
README.md :: lib/Win32/Mechanize/NotepadPlusPlus.pm
	podselect -section "NAME|SYNOPSIS|DESCRIPTION|INSTALLATION|AUTHOR|COPYRIGHT|LICENSE" lib/Win32/Mechanize/NotepadPlusPlus.pm > README.pod
	pod2markdown README.pod README.md
	$(RM_F) README.pod

# auto-generate the NppMessages -- this is run by developer, not during the install suite
__npp_msgs :: lib/Win32/Mechanize/NotepadPlusPlus/__npp_msgs.pm

lib/Win32/Mechanize/NotepadPlusPlus/__npp_msgs.pm ::
	$(NOECHO) $(ECHO) # svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
	$(NOECHO) cd src && h2ph -d . -e Notepad_plus_msgs.h
	$(NOECHO) $(ABSPERLRUN) -p -e "s/require 'windows.ph'/eval 'sub WM_USER () { 0x400; }' unless defined(\&WM_USER)/; s/^.*require 'tchar.ph'.*//;  s/^.*no warnings.*//; s/require '_h2ph.*/# auto-converted from Notepad_plus_msgs.h\npackage Win32::Mechanize::NotepadPlusPlus::__npp_msgs;/;" src/Notepad_plus_msgs.ph > $@
	$(NOECHO) $(RM) src/Notepad_plus_msgs.ph src/_h2ph_pre.ph
	$(NOECHO) $(ABSPERLRUN) -Ilib -e "use warnings; use strict; use Win32::Mechanize::NotepadPlusPlus::__npp_msgs; print STDERR qq(# WM_USER = ), Win32::Mechanize::NotepadPlusPlus::__npp_msgs::WM_USER;"


POSTAMBLE
}

WriteMakefile( %mm_args )
