gap> START_TEST( "PackageMaker: git.tst" );

#
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-git-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git", [ "init", "-b", "main" ] ) <> fail;
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.name", "PackageMaker Tests" ] ) <> fail;
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.email", "tests@example.invalid" ] ) <> fail;
true
gap> PrintTo( Filename( Directory( tmpdir ), "README.md" ), "probe\n" );;
gap> CreateGitRepository(
>   Directory( tmpdir ),
>   rec( username := "u", reponame := "r" ) );
Creating the git repository...
Done creating git repository.
Create <https://github.com/u/r> via <https://github.com/new> and then run:
  git push -u origin main
true
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
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-git-missing-user-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> PrintTo( Filename( Directory( tmpdir ), "README.md" ), "probe\n" );;
gap> CreateGitRepository(
>   Directory( tmpdir ),
>   rec( username := "u", reponame := "r" )
>   : gitIdentityChecker := function( dir )
>         return false;
>     end,
>     askRetry := function( question )
>         return false;
>     end );
Creating the git repository...
Git needs user.name and user.email configured before it can create the initial commit.
Please run these commands, then answer Y to retry:
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
Skipping git repository setup. The generated package directory has been kept.
false
gap> IsDirectoryPath( Filename( Directory( tmpdir ), ".git" ) );
false
gap> IsExistingFile( Filename( Directory( tmpdir ), "README.md" ) );
true
gap> RemoveDirectoryRecursively( tmpdir );;

#
gap> tmpdir := Filename( DirectoryTemporary(), "packagemaker-git-retry-tst" );;
gap> if IsDirectoryPath( tmpdir ) then RemoveDirectoryRecursively( tmpdir ); fi;
gap> AUTODOC_CreateDirIfMissing( tmpdir );
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git", [ "init", "-b", "main" ] ) <> fail;
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.name", "PackageMaker Tests" ] ) <> fail;
true
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "config", "user.email", "tests@example.invalid" ] ) <> fail;
true
gap> PrintTo( Filename( Directory( tmpdir ), "README.md" ), "probe\n" );;
gap> attempt := 0;;
gap> CreateGitRepository(
>   Directory( tmpdir ),
>   rec( username := "u", reponame := "r" )
>   : gitIdentityChecker := function( dir )
>         attempt := attempt + 1;
>         return attempt > 1;
>     end,
>     askRetry := function( question )
>         return true;
>     end );
Creating the git repository...
Git needs user.name and user.email configured before it can create the initial commit.
Please run these commands, then answer Y to retry:
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
Done creating git repository.
Create <https://github.com/u/r> via <https://github.com/new> and then run:
  git push -u origin main
true
gap> attempt;
2
gap> PKGMKR_CommandOutput( Directory( tmpdir ), "git",
>                         [ "log", "--format=%s", "-1" ] ) = "initial import\n";
true
gap> RemoveDirectoryRecursively( tmpdir );;

#
gap> STOP_TEST( "PackageMaker: git.tst", 1 );
