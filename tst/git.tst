gap> START_TEST( "PackageMaker: git.tst" );

#
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-git-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> Assert( 0,
>   PKGMKR_CommandOutput( Directory( tmpdir ), "git", [ "init", "-b", "main" ] ) <> fail );;
gap> Assert( 0,
>   PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.name", "PackageMaker Tests" ] ) <> fail );;
gap> Assert( 0,
>   PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.email", "tests@example.invalid" ] ) <> fail );;
gap> PrintTo( Filename( Directory( tmpdir ), "README.md" ), "probe\n" );;
gap> CreateGitRepository(
>   Directory( tmpdir ),
>   rec( username := "u", reponame := "r" ) );
Creating the git repository...
Done creating git repository.
Create <https://github.com/u/r> via <https://github.com/new> and then run:
  git push -u origin main
gap> IsDirectoryPath( Filename( Directory( tmpdir ), ".git" ) );
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "rev-parse", "--abbrev-ref", "HEAD" ] ) = "main\n";
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "log", "--format=%s", "-1" ] ) = "initial import\n";
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "remote", "get-url", "origin" ] ) = "https://github.com/u/r.git\n";
true
gap> RemoveDirectoryRecursively( tmpdir );;

#
gap> STOP_TEST( "PackageMaker: git.tst", 1 );
