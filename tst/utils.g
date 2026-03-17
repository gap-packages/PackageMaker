BindGlobal( "PKGMKR_DemoPackageAnswers", function()
    return rec(
        Date := "16/03/2026",
        GitHub := true,
        GitHubPagesForGAP := true,
        GitHub_reponame := "DemoPackage",
        GitHub_username := "demo-user",
        PackageName := "DemoPackage",
        PackageWWWHome := "https://demo-user.github.io/DemoPackage",
        Persons := [
            rec(
                Email := "demo@example.invalid",
                FirstNames := "Demo",
                Institution := "PackageMaker Test Suite",
                IsAuthor := true,
                IsMaintainer := true,
                LastName := "Maintainer",
                Place := "Test City",
                PostalAddress := "123 Test Street\\n12345 Test City",
                WWWHome := "https://example.invalid/~demo"
            )
        ],
        Subtitle := "Regression fixture for PackageWizardGenerate",
        Version := "0.1",
        kernel_extension := ""
    );
end );

BindGlobal( "PKGMKR_FixtureRoot", function()
    return DirectoriesPackageLibrary( "PackageMaker", "" )[1];
end );

BindGlobal( "PKGMKR_ExpectedDir", function( name )
    return Filename( PKGMKR_FixtureRoot(),
                     Concatenation( "tst/", name, ".expected" ) );
end );

BindGlobal( "PKGMKR_GenerateFixture", function( name, answers )
    local tempdir, olddir, actualdir;

    tempdir := Filename( DirectoryTemporary(),
                         Concatenation( "packagemaker-", name ) );
    if IsDirectoryPath( tempdir ) then
        RemoveDirectoryRecursively( tempdir );
    fi;
    AUTODOC_CreateDirIfMissing( tempdir );

    olddir := AUTODOC_CurrentDirectory();
    ChangeDirectoryCurrent( tempdir );
    PackageWizardGenerate( answers : skipGitRepositorySetup := true );
    ChangeDirectoryCurrent( olddir );

    actualdir := Filename( Directory( tempdir ), answers.PackageName );
    if not IsDirectoryPath( actualdir ) then
        Error( "Failed to generate fixture directory ", actualdir );
    fi;

    return rec( actualdir := actualdir, tempdir := tempdir );
end );

BindGlobal( "PKGMKR_RegenExpected", function( name, answers )
    local generated, expected, out, outstream;

    generated := PKGMKR_GenerateFixture( name, answers );
    expected := PKGMKR_ExpectedDir( name );

    if IsDirectoryPath( expected ) then
        RemoveDirectoryRecursively( expected );
    fi;
    AUTODOC_CreateDirIfMissing( expected );

    out := "";
    outstream := OutputTextString( out, false );
    if 0 <> PKGMKR_RunCommand( DirectoryCurrent(), "cp",
                               [ "-R",
                                 Concatenation( generated.actualdir, "/." ),
                                 expected ],
                               fail, outstream ) then
        CloseStream( outstream );
        Error( "Failed to copy generated fixture to ", expected );
    fi;
    CloseStream( outstream );

    RemoveDirectoryRecursively( generated.tempdir );
end );

BindGlobal( "PKGMKR_CheckExpected", function( name, answers )
    local generated, expected, res;

    generated := PKGMKR_GenerateFixture( name, answers );
    expected := PKGMKR_ExpectedDir( name );
    if not IsDirectoryPath( expected ) then
        RemoveDirectoryRecursively( generated.tempdir );
        Error( "Missing expected fixture directory ", expected );
    fi;

    res := PKGMKR_RunCommand( DirectoryCurrent(), "diff",
                              [ "-ur", expected, generated.actualdir ],
                              fail, OutputTextUser() );
    if res <> 0 then
        RemoveDirectoryRecursively( generated.tempdir );
        Error( "Generated package differed from expected output" );
    fi;

    RemoveDirectoryRecursively( generated.tempdir );
end );

BindGlobal( "PKGMKR_RegenAllExpected", function()
    PKGMKR_RegenExpected( "DemoPackage", PKGMKR_DemoPackageAnswers() );
end );

BindGlobal( "PKGMKR_RunGenerationTests", function()
    PKGMKR_CheckExpected( "DemoPackage", PKGMKR_DemoPackageAnswers() );
end );
