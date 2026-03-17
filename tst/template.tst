gap> START_TEST( "PackageMaker: template.tst" );

#
gap> pkginfo := NormalizePackageWizardAnswers( PKGMKR_DemoPackageAnswers() );;
gap> pkginfo.GitHub;
true
gap> pkginfo.License;
"GPL-2.0-or-later"
gap> pkginfo.LicenseTemplate;
"LICENSE.GPL-2.0-or-later"
gap> pkginfo.PackageURLs = fail;
false
gap> pkginfo.AvailabilityTest;
"ReturnTrue"
gap> mitAnswers := ShallowCopy( PKGMKR_DemoPackageAnswers() );;
gap> mitAnswers.License := "MIT";;
gap> mitinfo := NormalizePackageWizardAnswers( mitAnswers );;
gap> mitinfo.LicenseTemplate;
"LICENSE.MIT"
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-template-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> olddir := AUTODOC_CurrentDirectory();;
gap> ChangeDirectoryCurrent( tmpdir );;
gap> AUTODOC_CreateDirIfMissing( pkginfo.PackageName );
true
gap> TranslateTemplate( fail, "README.md", pkginfo );;
gap> PositionSublist( StringFile( Filename( Directory( pkginfo.PackageName ), "README.md" ) ),
>                    "# The GAP package DemoPackage" ) = 1;
true
gap> TranslateTemplate( "README.md", "README.md", mitinfo );;
gap> PositionSublist( StringFile( Filename( Directory( mitinfo.PackageName ), "README.md" ) ),
>                    "This package is distributed under the terms of the MIT License." ) <> fail;
true
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/gap" ) );
true
gap> TranslateTemplate( "PackageInfo.g.in", "PackageInfo.g", mitinfo );;
gap> PositionSublist( StringFile( Filename( Directory( mitinfo.PackageName ), "PackageInfo.g" ) ),
>                    "License := \"MIT\"" ) <> fail;
true
gap> TranslateTemplate( mitinfo.LicenseTemplate, "LICENSE", mitinfo );;
gap> PositionSublist( StringFile( Filename( Directory( mitinfo.PackageName ), "LICENSE" ) ),
>                    "MIT License" ) <> fail;
true
gap> PositionSublist( StringFile( Filename( Directory( mitinfo.PackageName ), "LICENSE" ) ),
>                    "Copyright (c) 2026 Demo Maintainer" ) <> fail;
true
gap> TranslateTemplate( "gap/PKG.gd",
>                      Concatenation( "gap/", pkginfo.PackageName, ".gd" ),
>                      pkginfo );;
gap> PositionSublist(
>     StringFile( Filename( Directory( Concatenation( pkginfo.PackageName, "/gap" ) ),
>                           Concatenation( pkginfo.PackageName, ".gd" ) ) ),
>     "DeclareGlobalFunction( \"DemoPackage_Example\" );" ) <> fail;
true
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github" ) );
true
gap> AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github/workflows" ) );
true
gap> CopyTemplate( fail, ".github/workflows/CI.yml", pkginfo );;
gap> StringFile( Filename( Directory( Concatenation( pkginfo.PackageName, "/.github/workflows" ) ),
>                         "CI.yml" ) ) =
>   StringFile( Filename( PKGMKR_TEMPLATE_DIR, ".github/workflows/CI.yml" ) );
true
gap> ChangeDirectoryCurrent( olddir );;
gap> RemoveDirectoryRecursively( tmpdir );;

#
gap> STOP_TEST( "PackageMaker: template.tst", 1 );
