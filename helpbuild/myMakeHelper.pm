package myMakeHelper;
use warnings;
use strict;
use 5.010;
use Exporter 5.57 qw(import);
use File::Which ();
use File::Spec ();
use File::Fetch;
use Archive::Extract;
use Config;

our %EXPORT_TAGS = (
    default => [qw/myMakeHelper/],
);
our @EXPORT = qw(myMakeHelper);
our @EXPORT_OK = (@EXPORT, map {@$_} values %EXPORT_TAGS);

sub myMakeHelper {
    my %ret = ();

    warn __PACKAGE__, "\tAUTOMATED_CI_TESTING = ", $ENV{AUTOMATED_CI_TESTING}//'<undef>', "\n";
    warn __PACKAGE__, "\tW32MNPP_FORCE_VER = ", $ENV{W32MNPP_FORCE_VER}//'<undef>', "\n";
    warn __PACKAGE__, "\tTEMP = ", $ENV{TEMP}//'<undef>', "\n";
    warn __PACKAGE__, "\tTMP = ", $ENV{TMP}//'<undef>', "\n";

    for(1) {
        is_windows() or last;                                                   # if not windows, don't need to download notepad++

        # need to know bitness _before_ checking for NPP existing
        $ret{bits} = determine_bitness() or last;                               # if your Perl isn't 32-bit or 64-bit, cannot determine the necessary Notepad++ to download

        unless($ENV{AUTOMATED_CI_TESTING}) {                                       # if not automated, then don't need to
            if( my $nppexe = npp_already_exists($ret{bits}) ) {                 # if notepad++ already found, don't need to download it; make sure I set the variables
                my ($vol, $dir, $fil) = File::Spec->splitpath($nppexe);
                $ret{npp_folder} = File::Spec->catpath($vol, $dir, '');
                $ret{npp_exe} = $nppexe;
            } else {                                                            # otherwise, warn user that they need to install Notepad++ for this test suite to work
                warn "Please install Notepad++, or set your PATH to include the existing Notepad++ executable directory.\n";
                warn "If you don't, the Win32::Mechanize::NotepadPlusPlus test suite will fail.\n";
            }
            last;
        }

        my $td = File::Spec->tmpdir;

        $ret{zip} = download_zip( $ret{bits}, $td ) or last;                    # stop if the download failed

        @ret{'npp_folder', 'npp_exe'} = unzip_npp( $ret{zip}, $td ) or last;    # stop if the unzip failed

        #TODO:
        if ($ENV{AUTOMATED_CI_TESTING} && $ENV{W32MNPP_FORCE_GEDCOM}) {
            # download https://sourceforge.net/projects/gedcomlexer/files/GedcomLexer-0.4.0-r140/GedcomLexer-0.4.0-r140-x64.zip/download
            # or https://sourceforge.net/projects/gedcomlexer/files/GedcomLexer-0.4.0-r140/GedcomLexer-0.4.0-r140-x86.zip/download
            # depending on bitness
            $ret{gedcom} = download_gedcom( $ENV{W32MNPP_FORCE_GEDCOM}, $td ) or last;              # stop if the download failed
            warn sprintf "%s\tTODO\tinstall_gedcom(%s,%s)\n", __PACKAGE__, $ret{gedcom}, $td;
            #   @ret{qw/gedcom_dll gedcom_cfg/} = install_gedcom($ret{gedcom}, $td} or last;       # stop if the unzip and install failed
        }
    }
    return %ret;
}

sub is_windows { $^O eq 'MSWin32' or $^O eq 'cygwin' or $ENV{AVTEST_FORCE_NON_WIN} }

sub PRETEND_IT_DOESNT { 0; } # set to 0

sub npp_already_exists {
    my $npp_exe;
    # priority to path, 64bit, default, then x86-specific locations
    my @try = ( File::Which::which('notepad++') );
    push @try, "$ENV{ProgramW6432}/Notepad++/notepad++.exe" if exists $ENV{ProgramW6432};
    push @try, "$ENV{ProgramFiles}/Notepad++/notepad++.exe" if exists $ENV{ProgramFiles};
    push @try, "$ENV{'ProgramFiles(x86)'}/Notepad++/notepad++.exe" if exists $ENV{'ProgramFiles(x86)'} and $_[0]==32; # only allow x86 folder for 32bit checks
    @try = () if PRETEND_IT_DOESNT;

    foreach my $try ( @try )
    {
        $npp_exe = $try if -x $try;
        last if defined $npp_exe;
    }

    warn sprintf "%s\tNPP = %s\n", __PACKAGE__, $npp_exe  if defined $npp_exe;
    return $npp_exe;
}

sub determine_bitness {
    my $bit;
    warn sprintf "%s\tBITS? \$Config{%s} = %s\n", __PACKAGE__, $_, $Config{$_} for qw/myuname archname ptrsize ivsize/;
    $bit //= 64 if $Config{archname} =~ /x64/;
    $bit //= 64 if $Config{ptrsize} >= 8;
    $bit //= 64 if $Config{ivsize} >= 8;
    $bit //= 32 if $Config{archname} =~ /x86/;  # this isn't enough to downgrade, so just use this to set initial 32-bit
    $bit = 32 if $Config{ptrsize} == 4;
    $bit = 32 if $Config{ivsize} == 4;
    warn sprintf "%s\tBITS = %d\n", __PACKAGE__, $bit//'<undef>';
    return $bit;
}

sub download_zip {
    my ($bits, $folder) = @_;
    if( !-w $folder ) {
        warn sprintf "%s\tZIP? folder '%s' not writeable\n", __PACKAGE__, $folder//'<undef>';
        return;
    }
    warn sprintf "%s\tZIP? '%s' folder ok\n", __PACKAGE__, $folder;

    my $nppv = $ENV{W32MNPP_FORCE_VER} || 'v8.5.2';
    warn sprintf "%s\tWanting to download zip %s\n", __PACKAGE__, $nppv;
    my %url = (
        'v8.1.4' => {
            64 => {
                https => 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.4/npp.8.1.4.portable.x64.zip',
                http  => 'http://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.4/npp.8.1.4.portable.x64.zip',
                name  => 'npp.8.1.4.portable.x64.zip',
            },
            32 => {
                https => 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.4/npp.8.1.4.portable.zip',
                http  => 'http://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.4/npp.8.1.4.portable.zip',
                name  => 'npp.8.1.4.portable.zip',
            },
        },
        'v8.3.3' => {
            64 => {
                #https => 'https://download.notepad-plus-plus.org/repository/8.x/8.3.3/npp.8.3.3.portable.x64.zip',
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.3.3/npp.8.3.3.portable.x64.zip',
                name  => 'npp.8.3.3.portable.x64.zip',
            },
            32 => {
                #https => 'https://download.notepad-plus-plus.org/repository/8.x/8.3.3/npp.8.3.3.portable.zip',
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.3.3/npp.8.3.3.portable.zip',
                name  => 'npp.8.3.3.portable.zip',
            },
        },
        'v8.4.8' => {
            64 => {
                #https => 'https://download.notepad-plus-plus.org/repository/8.x/8.4.8/npp.8.4.8.portable.x64.zip',
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.4.8/npp.8.4.8.portable.x64.zip',
                name  => 'npp.8.4.8.portable.x64.zip',
            },
            32 => {
                #https => 'https://download.notepad-plus-plus.org/repository/8.x/8.4.8/npp.8.4.8.portable.zip',
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.4.8/npp.8.4.8.portable.zip',
                name  => 'npp.8.4.8.portable.zip',
            },
        },
        'v8.5.2' => {
            64 => {
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.5.2/npp.8.5.2.portable.x64.zip',
                name  => 'npp.8.5.2.portable.x64.zip',
            },
            32 => {
                http  => 'http://download.notepad-plus-plus.org/repository/8.x/8.5.2/npp.8.5.2.portable.zip',
                name  => 'npp.8.5.2.portable.zip',
            },
        },
    );
    die "don't know the URL for ", ($nppv//'<undef>') unless exists $url{$nppv};

    my $zip = File::Spec->catfile( $folder, $url{$nppv}{$bits}{name});
    if(-f $zip) {   # already downloaded
        warn sprintf "%s\tZIP = '%s' previously downloaded\n", __PACKAGE__, $zip;
        return $zip;
    }

    undef $zip;
    for(qw/https http/) {
        warn sprintf "%s\tZIP: url = '%s'\n", __PACKAGE__, $url{$nppv}{$bits}{$_};
        my $ff = File::Fetch->new( uri => $url{$nppv}{$bits}{$_} );
        next unless $ff;

        $ff->fetch( to => $folder )
            and $zip = $ff->output_file()
            and last
            or warn sprintf "%s\tZIP? download error = '%s'\n", __PACKAGE__, $ff->error()//'<undef>';
    }
    if( defined $zip ) {
        warn sprintf "%s\tZIP? '%s' downloaded successfully\n", __PACKAGE__, $zip;
        $zip = File::Spec->catfile($folder, $zip) unless -f $zip;
        if( !-f $zip ) {
            warn sprintf "%s\tZIP? '%s' doesn't exist after download\n", __PACKAGE__, $zip;
            return;
        }
    }

    warn sprintf "%s\tZIP = %s\n", __PACKAGE__, $zip//'<undef>';
    return $zip;
}

sub unzip_npp {
    my ($zip, $folder) = @_;
    my $ae = Archive::Extract->new( archive => $zip );

    my $unzip = File::Spec->catdir( $folder, 'notepad++' );
    warn sprintf "%s\tUNZIP? to folder '%s'\n", __PACKAGE__, $unzip;

    my $ok = $ae->extract( to => $unzip );
    if(!$ok) {
        warn sprintf "%s\tUNZIP? extraction error '%s'\n", __PACKAGE__, $ae->error;
        return;
    }

    my $npp = File::Spec->catfile( $unzip, 'notepad++.exe' );
    warn sprintf "%s\tUNZIP? expect executable '%s'\n", __PACKAGE__, $npp;
    if(!-x $npp) {
        warn sprintf "%s\tNPP? no executable '%s'\n", __PACKAGE__, $npp;
        return;
    }

    warn sprintf "%s\tNPP = %s\n", __PACKAGE__, $npp//'<undef>';
    return $unzip, $npp;
}

sub download_gedcom {
    my ($url, $folder) = @_;
    if( !-w $folder ) {
        warn sprintf "%s\tGEDCOM ZIP? folder '%s' not writeable\n", __PACKAGE__, $folder//'<undef>';
        return;
    }
    warn sprintf "%s\tGEDCOM ZIP? '%s' folder ok\n", __PACKAGE__, $folder;

    warn sprintf "%s\tWanting to download GEDCOM zip %s\n", __PACKAGE__, $url;

    my ($zipname) = ($url =~ m{/([^/]*\.zip)});
    my $zip = File::Spec->catfile( $folder, $zipname );
    warn sprintf "%s\tGEDCOM ZIP = '%s' => '%s'\n", __PACKAGE__, $zip, $zipname;
    if(-f $zip) {   # already downloaded
        warn sprintf "%s\tGEDCOM ZIP = '%s' previously downloaded\n", __PACKAGE__, $zip;
        return $zip;
    }

    undef $zip;
    for(1) {
        warn sprintf "%s\tGEDCOM ZIP: url = '%s'\n", __PACKAGE__, $url;
        my $ff = File::Fetch->new( uri => $url );
        warn sprintf "%s\tGEDCOM ZIP: fetching '%s'\n", __PACKAGE__, $ff;
        next unless $ff;

        my $where = $ff->fetch( to => $folder );
        unless($where) {
            warn sprintf "%s\tGEDCOM ZIP? download error = '%s' where='%s'\n", __PACKAGE__, map {$_//'<undef>'} $ff->error(), $where;
        }
        $zip = $ff->output_file();
        unless($where and $zip) {
            warn sprintf "%s\tGEDCOM ZIP? download error = '%s' where='%s' zip='%s'\n", __PACKAGE__, map {$_//'<undef>'} $ff->error(), $where, $zip;
        }
        last;
    }
    for(<$folder/*.*>) {
        next unless -f $_;
        warn sprintf "\tDIR\t%s\t%d\n", $_, -s _  if m{\.zip} or m{\Q$zip\E} or m{download};
    }
    if( defined $zip ) {
        warn sprintf "%s\tGEDCOM ZIP? '%s' downloaded successfully\n", __PACKAGE__, $zip;

        if( $zip ne $zipname ) {
            my $oldname = File::Spec->catfile($folder, $zip);
            $zip = File::Spec->catfile($folder, $zipname);
            rename $oldname, $zip;
            warn sprintf "%s\tGEDCOM RENAME '%s' to '%s': %s\n", __PACKAGE__, $oldname, $zip, $!//'success';
            for(<$folder/*.*>) {
                next unless -f $_;
                warn sprintf "\tDIR\t%s\t%d\n", $_, -s _  if m{\.zip} or m{\Q$zip\E};
            }
        }

        $zip = File::Spec->catfile($folder, $zip) unless -f $zip;
        if( !-f $zip ) {
            warn sprintf "%s\tGEDCOM ZIP? '%s' doesn't exist after download\n", __PACKAGE__, $zip;
            return;
        }
    }

    warn sprintf "%s\tGEDCOM ZIP = %s\n", __PACKAGE__, $zip//'<undef>';
    return $zip;
}


1;
