gap> START_TEST( "PackageMaker: generation.tst" );

#
gap> PKGMKR_CheckExpected( "DemoPackage", PKGMKR_DemoPackageAnswers() );;
gap> customAnswers := ShallowCopy( PKGMKR_DemoPackageAnswers() );;
gap> customAnswers.PackageName := "CustomLicensePackage";;
gap> customAnswers.GitHub_reponame := "CustomLicensePackage";;
gap> customAnswers.PackageWWWHome := "https://demo-user.github.io/CustomLicensePackage";;
gap> customAnswers.License := "custom";;
gap> generated := PKGMKR_GenerateFixture( "custom-license", customAnswers );;
gap> PositionSublist( StringFile( Filename( Directory( generated.actualdir ), "PackageInfo.g" ) ),
>                    "License := \"custom\"" ) <> fail;
true
gap> PositionSublist( StringFile( Filename( Directory( generated.actualdir ), "LICENSE" ) ),
>                    "replace this placeholder with the full text of your chosen license" ) <> fail;
true
gap> RemoveDirectoryRecursively( generated.tempdir );;

#
gap> STOP_TEST( "PackageMaker: generation.tst", 1 );
