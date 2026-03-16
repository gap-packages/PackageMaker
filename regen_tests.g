if fail = LoadPackage( "PackageMaker" ) then
    Error( "failed to load PackageMaker package" );
fi;

ReadPackage( "PackageMaker", "tst/utils.g" );
PKGMKR_RegenAllExpected();

QUIT_GAP( 0 );
