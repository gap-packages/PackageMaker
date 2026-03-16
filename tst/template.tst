gap> START_TEST( "PackageMaker: template.tst" );

#
gap> pkginfo := NormalizePackageWizardAnswers( PKGMKR_DemoPackageAnswers() ).pkginfo;;
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-template-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> olddir := AUTODOC_CurrentDirectory();;
gap> ChangeDirectoryCurrent( tmpdir );;
gap> AUTODOC_CreateDirIfMissing( pkginfo.PackageName );
true
gap> TranslateTemplate( fail, "README.md", pkginfo );;
gap> Assert( 0,
>   PositionSublist( StringFile( Filename( Directory( pkginfo.PackageName ), "README.md" ) ),
>                    "# The GAP package DemoPackage" ) = 1 );;
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/gap" ) );
true
gap> TranslateTemplate( "gap/PKG.gd",
>                      Concatenation( "gap/", pkginfo.PackageName, ".gd" ),
>                      pkginfo );;
gap> Assert( 0,
>   PositionSublist(
>     StringFile( Filename( Directory( Concatenation( pkginfo.PackageName, "/gap" ) ),
>                           Concatenation( pkginfo.PackageName, ".gd" ) ) ),
>     "DeclareGlobalFunction( \"DemoPackage_Example\" );" ) <> fail );;
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github" ) );
true
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github/workflows" ) );
true
gap> CopyTemplate( fail, ".github/workflows/CI.yml", pkginfo );;
gap> Assert( 0,
>   StringFile( Filename( Directory( Concatenation( pkginfo.PackageName, "/.github/workflows" ) ),
>                         "CI.yml" ) ) =
>   StringFile( Filename( DirectoriesPackageLibrary( "PackageMaker", "templates" )[1],
>                         ".github/workflows/CI.yml" ) ) );;
gap> ChangeDirectoryCurrent( olddir );;
gap> RemoveDirectoryRecursively( tmpdir );;

#
gap> STOP_TEST( "PackageMaker: template.tst", 1 );
