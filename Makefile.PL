use ExtUtils::MakeMaker;
use 5.010;
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
        'Win32::GuiTest'    => 1.64,    # version needed for 64-bit ::SendMessage retval
        'Win32::API'        => 0.71,    # version needed for WINAPI calling convention
        'Win32::GUI'        => 0,       # for now, needed for notepad()->prompt; need to look for alternative
        'Win32'             => 0,
        'File::Which'       => 0,
        'Config'            => 0,       # needed in Notepad.pm::getFiles for $Config{ptrsize}
    },
    'realclean'     => {
        FILES => 'cover_db LICENSE.pod README.pod MYMETA.json.lock t\nppPath.inc ' . $ENV{TEMP} . "\\notepad++",
    }
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
        };
        # automatically determine the versions for 'provides'; MM->parse_version exists as of MM v6.31, so not a problem with >= 6.46
        #   => this comes out right when printed... but MYMETA.* shows values that look wrong
        my $v = MM->parse_version( $mm_args{VERSION_FROM} );
        $mm_args{META_MERGE}{provides} = {
            'Win32::Mechanize::NotepadPlusPlus' => {
                file => 'lib/Win32/Mechanize/NotepadPlusPlus.pm',
                version => $v,
            },
            'Win32::Mechanize::NotepadPlusPlus::Notepad' => {
                file => 'lib/Win32/Mechanize/NotepadPlusPlus/Notepad.pm',
                version => $v,
            },
            'Win32::Mechanize::NotepadPlusPlus::Editor' => {
                file => 'lib/Win32/Mechanize/NotepadPlusPlus/Editor.pm',
                version => $v,
            }
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.31' ) {
        $mm_args{LICENSE} = 'perl_5';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.48' ) {
        $mm_args{MIN_PERL_VERSION} = '5.10.0';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.52' ) {
        $mm_args{CONFIGURE_REQUIRES} = {
            'ExtUtils::MakeMaker' => '6.52',
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'Test::Exception' => 0,
            'constant' => 0,
            'Config' => 0,
            'Win32' => 0,
            'FindBin' => 1.49, # the version released with perl v5.10
            'File::Which' => 0,
            'File::Spec' => 0,
            'File::Fetch' => 0,
            'Archive::Extract' => 0,
            'Archive::Zip' => 0,
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.64' ) {
        $mm_args{TEST_REQUIRES} = {
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'Test::Exception' => 0,
            'constant' => 0,
            'Config' => 0,
            'Path::Tiny' => 0.058,          # 0.018 needed for rootdir and cwd; 0.058 needed for sibling
            'Win32' => 0,
            'Win32::API' => 0,
            'Win32::GuiTest'    => 1.64,    # version needed for 64-bit ::SendMessage retval
            'Encode' => 0,
            'FindBin' => 1.49,              # the version released with perl v5.10
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.18' ) {
        $mm_args{SIGN} = 1 if MM->can('signature_target') && $ENV{MM_SIGN_DIST};
    }
}

use FindBin;
use lib $FindBin::Bin . '/helpbuild';
use myMakeHelper;
my %helper = myMakeHelper();
use Data::Dumper; print Dumper \%helper;
if(exists $helper{npp_folder} and exists $helper{zip}) {
    print "creating include-file for updating PATH=$helper{npp_folder};%PATH%\n";
    open my $inc, '>', "${FindBin::Bin}/t/nppPath.inc";
    print {$inc} "BEGIN { \$ENV{PATH} = '$helper{npp_folder};' . \$ENV{PATH} };\n\n1;\n";
}

sub MY::postamble {
    my (undef,%h) = @_;
    #require Data::Dumper;
    #print STDERR Data::Dumper->Dump([\%h], [qw(mm_args{postamble})]);
    my $POSTAMBLE =<<'POSTAMBLE';
# TEST_D is used to test for the existence of a directory
TEST_D = $(ABSPERLRUN) -MExtUtils::Command -e test_d --

# run a test coverage report
testcover ::
	$(NOECHO) cover -test -report html

# run author-tests on the original
authtest ::
	$(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

# run normal tests and author-tests on the distribution
distauthtest :: disttest
	cd $(DISTVNAME) && $(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

# veryclean: runs realclean, then deletes .bak, .old, .orig, and similar
# addition to realclean: also delete coverage database, if testcover was run
#replace the realclean :: with realclean => {FILES => 'space sep list of files and dirs'} in the hash

# auto-populate the VERSION in the submodules from $(VERSION), which comes from main module
populateversion :: lib/Win32/Mechanize/NotepadPlusPlus.pm
	$(NOECHO) $(ECHO) want to auto-populate VERSION in all sub-modules: $(VERSION)
	$(PERL) -pi -e "s/^(\s*our\s+.VERSION\s*=).*?;.*?$$/\1 '$(VERSION)'; # auto-populated from W::M::NPP/" lib/Win32/Mechanize/NotepadPlusPlus/Notepad.pm lib/Win32/Mechanize/NotepadPlusPlus/Editor.pm

#config :: populateversion
#	$(NOECHO) $(NOOP)

# auto-generate the README from the lib/Win32/Mechanize/NotepadPlusPlus.pm
README.md :: lib/Win32/Mechanize/NotepadPlusPlus.pm Makefile.PL
	$(PERL) -MPod::Simple::Select -e 'my $$p = Pod::Simple::Select->new();$$p->output_file(qq(README.pod));$$p->select({head1 => [qq(NAME),qq(SYNOPSIS),qq(DESCRIPTION),qq(LIMITATIONS),qq(INSTALLATION),qq(TODO),qq(AUTHOR),qq(COPYRIGHT),qq(LICENSE)]});$$p->parse_file(qq(lib/Win32/Mechanize/NotepadPlusPlus.pm));'
	pod2markdown README.pod README.md
	$(RM_F) README.pod

# auto-generate the LICENSE file from the lib/Win32/Mechanize/NotepadPlusPlus.pm
LICENSE :: lib/Win32/Mechanize/NotepadPlusPlus.pm Makefile.PL
	$(PERL) -MPod::Simple::Select -e 'my $$p = Pod::Simple::Select->new();$$p->output_file(qq(LICENSE.pod));$$p->select({head1 => [qw/AUTHOR COPYRIGHT LICENSE/]});$$p->parse_file(qq(lib/Win32/Mechanize/NotepadPlusPlus.pm));'
	pod2text LICENSE.pod LICENSE
	$(RM_F) LICENSE.pod

docs :: README.md LICENSE manifest populateversion

# auto-generate the messages-modules for Notepad++ GUI and Scintilla Editor -- this is run by developer, not during the install suite

all_msgs ::
	$(TOUCH) src/*.h
	$(MAKE) msgs

msgs :: generate__npp_msgs generate__npp_idm generate__sci_msgs

generate__npp_msgs :: src/__npp_msgs.pm

generate__npp_idm :: src/__npp_idm.pm

generate__sci_msgs :: src/__sci_msgs.pm

# change in direction: I used to directly generate the __sci_msgs.pm and similar; now I'll generate an intermediary in the src directory, but manually incorporate those changes into the real library
src/__npp_msgs.pm :: src/Notepad_plus_msgs.h
	$(NOECHO) $(ECHO) # svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
	$(NOECHO) $(ABSPERLRUN) src/convertHeaders.pl "$<" "$@" "Win32::Mechanize::NotepadPlusPlus::Notepad::Messages" "nppm_dummyhash"

src/__npp_idm.pm :: src/menuCmdID.h
	$(NOECHO) $(ECHO) # svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/menuCmdID.h
	$(NOECHO) $(ABSPERLRUN) src/convertHeaders.pl "$<" "$@" "Win32::Mechanize::NotepadPlusPlus::__npp_idm" "nppidm_dummyhash"

src/__sci_msgs.pm :: src/Scintilla.h
	$(NOECHO) $(ECHO) # svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/scintilla/include/Scintilla.h
	$(NOECHO) $(ABSPERLRUN) src/convertHeaders.pl "$<" "$@" "Win32::Mechanize::NotepadPlusPlus::Editor::Messages" "scimsg_dummyhash"

src_export ::
	$(NOECHO) svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h src/
	$(NOECHO) svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/PowerEditor/src/menuCmdID.h src/
	$(NOECHO) svn export --force https://github.com/notepad-plus-plus/notepad-plus-plus/trunk/scintilla/include/Scintilla.h src/

POSTAMBLE

    return $POSTAMBLE;

}

if($ENV{W32MNPP_FORCE_WRONG_OS}) {
    $^O = 'WrongOS';
}

if($^O !~ /MSWin32|cygwin/ and !$ENV{W32MNPP_FORCE_NONWIN_TEST} ) {
    warn sprintf "I don't know whether it will work with Notepad++.exe in OS '%s'\n", $^O;
    warn << "EOW";

########################################
# However, it might work, so I don't want to FAIL on matrix.cpantesters.org.
#   Instead, don't create the Makefile by default, so it will show up as UNKNOWN
#
# If you'd like to try to make it work, please set the environment variable
#   W32MNPP_FORCE_NONWIN_TEST to a true value,
# then re-run perl Makefile.PL, and continue the standard test suite and
# installation procedure from there.
#
# If it works, feel free to create an issue explaining how to make it work:
#   https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues
########################################

EOW
    exit 0; # exit 0 without Makefile existing will cause UNKNOWN
}


WriteMakefile( %mm_args )
