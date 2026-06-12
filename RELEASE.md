[![](https://img.shields.io/cpan/v/Win32-Mechanize-NotepadPlusPlus.svg?colorB=00CC00 "metacpan")](https://metacpan.org/pod/Win32::Mechanize::NotepadPlusPlus)
[![](http://cpants.cpanauthors.org/dist/Win32-Mechanize-NotepadPlusPlus.png "cpan testers")](http://matrix.cpantesters.org/?dist=Win32-Mechanize-NotepadPlusPlus)
[![](https://img.shields.io/github/release/pryrt/Win32-Mechanize-NotepadPlusPlus.svg "github release")](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/releases)
[![](https://img.shields.io/github/issues/pryrt/Win32-Mechanize-NotepadPlusPlus.svg "issues")](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues)
[![](https://ci.appveyor.com/api/projects/status/6gv0lnwj1t6yaykp/branch/master?svg=true "build status")](https://ci.appveyor.com/project/pryrt/win32-mechanize-notepadplusplus)

# Releasing Win32::Mechanize::NotepadPlusPlus

This describes some of my methodology for releasing a distribution.  Long ago switched from AppVeyor to GitHub Actions for CI testing.

## My Methodology

- **Development:**

    - **GitHub:** create a branch

    - `prove -l t` for normal tests, `prove -l xt` for author tests
    - every `git push` to the GitHub repo should trigger AppVeyor build suite

- **Release:**

    - Verify dos8.3-style shortnames:               # shortname cannot be auto-tested (easily?) in appveyor
        - dir .. /X                                 # list the shortname for parent directory
        - cd ..\short8.3                            # force cmd.exe to use shortname notation
        - `prove -l t`                              # ensure it still works in shortname mode

    - **Verify Documentation:**
        - make sure versioning is correct
        - verify README.md and other auto-generated docs are up-to-date
            - `gmake docs`
        - verify CHANGES (history)

    - **Build Distribution**

            set AUTOMATED_CI_TESTING=               # cannot have it set, otherwise nppPath.inc messes up manifest
            set PATH=...\safe\notepad++\;%PATH%     # need a "safe" notepad++ path, to avoid my customizations/plugins getting in the way
            gmake veryclean                         # clear out all the extra junk
            perl Makefile.PL                        # create a new makefile
            gmake                                   # copy the library to ./blib/lib...
            gmake distcheck                         # check for new or removed files
            gmake manifest                          # if this steps adds or deletes incorrectly, please fix MANIFEST.SKIP ; MANIFEST is auto-generated
            gmake disttest                          # optional, if you want to verify that make test will work for the CPAN audience
            set MODULE_SIGNATURE_AUTHOR=XXXXXXXX    # choose the correct gpg signing key
            set MM_SIGN_DIST=1                      # enable signatures for build
            set TEST_SIGNATURE=1                    # verify signatures during `disttest`
            perl Makefile.PL && gmake distauthtest  # recreate Makefile and re-run distribution test with signing & test-signature turned on
            set TEST_SIGNATURE=                     # clear signature verification during `disttest`
            gmake dist                              # actually make the tarball
            gmake veryclean                         # clean out this directory
            set MM_SIGN_DIST=                       # clear signatures after build

    - **git:** final push of the development branch

    - **git:** switch back to trunk (master) repo

    - **GitHub:** make a pull request to bring the branch back into the trunk
        - This should trigger AppVeyor approval for the pull request
        - Once AppVeyor approves, need to approve the pull request, then the branch will be merged back into the trunk
        - If that branch is truly done, delete the branch using the pull-request page (wait until AFTER `git checkout main`, otherwise the switch will fail)

    - **GitHub:** [create a new release](https://help.github.com/articles/creating-releases/):
        - Releases > Releases > Draft a New Release
        - tag name = `v#.###`
        - release title = `v#.###`

    - **PAUSE:** [upload distribution tarball to CPAN/PAUSE](https://pause.perl.org/pause/authenquery?ACTION=add_uri) by browsing to the file on my computer.
        - Watch <https://metacpan.org/author/PETERCJ> and <http://search.cpan.org/~petercj/> for when it updates
        - Watch CPAN Testers

    - **GitHub:** Clear out any [issues](https://github.com/pryrt/Win32-Mechanize-NotepadPlusPlus/issues/) that were resolved by this release

