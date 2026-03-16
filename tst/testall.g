#
# PackageMaker: A GAP package for creating new GAP packages
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "PackageMaker" );
ReadPackage( "PackageMaker", "tst/utils.g" );
PKGMKR_RunGenerationTests();
QUIT_GAP( 0 );
