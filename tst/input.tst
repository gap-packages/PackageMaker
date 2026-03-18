gap> START_TEST( "PackageMaker: input.tst" );

#
gap> spec := [
>   rec( key := "Intro", kind := "message", prompt := "Welcome" ),
>   rec( key := "PackageName",
>        kind := "string",
>        prompt := "Package name?",
>        validate := function( answers, value )
>            if value = "bad" then
>                return "invalid package name";
>            fi;
>            return true;
>        end ),
>   rec( key := "GitHub",
>        kind := "yesno",
>        prompt := "Use GitHub?",
>        default := true ),
>   rec( key := "License",
>        kind := "choice",
>        prompt := "License?",
>        choices := [ [ "GPL-2.0-or-later", "GPL-2.0-or-later" ],
>                     [ "MIT", "MIT" ] ],
>        default := 1 ),
>   rec( key := "RepoName",
>        kind := "string",
>        prompt := "Repo name?",
>        default := function( answers )
>            return Concatenation( answers.PackageName, "-repo" );
>        end,
>        isVisible := function( answers )
>            return answers.GitHub;
>        end ),
>   rec( key := "Kernel",
>        kind := "choice",
>        prompt := "Kernel extension?",
>        choices := [ [ "No", "" ], [ "C", "C" ] ],
>        default := 1 )
> ];;
gap> ui := PKGMKR_TestFakeUI( [ "bad", "DemoPackage", true, "GPL-2.0-or-later", "DemoPackage-repo", "" ] );;
gap> answers := PKGMKR_AskQuestions( spec, ui, rec() );;
invalid package name
gap> answers.PackageName;
"DemoPackage"
gap> answers.GitHub;
true
gap> answers.License;
"GPL-2.0-or-later"
gap> answers.RepoName;
"DemoPackage-repo"
gap> answers.Kernel;
""
gap> ui.state.messages;
[ "Welcome" ]
gap> List( ui.state.calls, call -> call.key );
[ "Intro", "PackageName", "PackageName", "GitHub", "License", "RepoName", 
  "Kernel" ]
gap> ui.state.calls[4].default;
true
gap> ui.state.calls[5].default;
1
gap> ui.state.calls[5].choices;
[ [ "GPL-2.0-or-later", "GPL-2.0-or-later" ], [ "MIT", "MIT" ] ]
gap> ui.state.calls[6].default;
"DemoPackage-repo"
gap> ui.state.calls[7].choices;
[ [ "No", "" ], [ "C", "C" ] ]

#
gap> spec := [
>   rec( key := "PackageName", kind := "string", prompt := "Package name?" ),
>   rec( key := "GitHub", kind := "yesno", prompt := "Use GitHub?" ),
>   rec( key := "PackageWWWHome",
>        kind := "computed",
>        value := function( answers )
>            return Concatenation( "https://example.invalid/", answers.PackageName );
>        end,
>        isVisible := function( answers )
>            return answers.GitHub;
>        end )
> ];;
gap> ui := PKGMKR_TestFakeUI( [ "DemoPackage", true ] );;
gap> answers := PKGMKR_AskQuestions( spec, ui, rec() );;
gap> answers.PackageWWWHome;
"https://example.invalid/DemoPackage"
gap> List( ui.state.calls, call -> call.key );
[ "PackageName", "GitHub" ]

#
gap> spec := [
>   rec( key := "PackageWWWHome",
>        kind := "string",
>        prompt := "Homepage?",
>        normalize := function( answers, value )
>            if value = "" then
>                return "https://TODO";
>            fi;
>            return value;
>        end )
> ];;
gap> ui := PKGMKR_TestFakeUI( [ "" ] );;
gap> answers := PKGMKR_AskQuestions( spec, ui, rec() );;
gap> answers.PackageWWWHome;
"https://TODO"

#
gap> spec := PKGMKR_InputSpecification;;
gap> ui := PKGMKR_TestFakeUI(
>   [ "DemoPackage",
>     "Demo subtitle",
>     "GPL-2.0-or-later",
>     false,
>     "",
>     "" ] );;
gap> answers := PKGMKR_AskQuestions(
>   spec,
>   ui,
>   rec( Version := "0.1", Date := "17/03/2026" ) );;
gap> answers.License;
"GPL-2.0-or-later"
gap> answers.GitHub;
false
gap> answers.GitHubActions;
false
gap> answers.PackageWWWHome;
"https://TODO"
gap> answers.kernel_extension;
""
gap> IsBound( answers.GitHub_username );
false
gap> List( ui.state.calls, call -> call.key );
[ "Welcome", "PackageName", "Subtitle", "License", "GitHub", "PackageWWWHome",
  "kernel_extension" ]
gap> ui.state.calls[4].default;
1
gap> ui.state.calls[4].choices;
[ [ "GPL 2 or later (default; used by GAP itself and many packages)", 
      "GPL-2.0-or-later" ], [ "GPL 3 or later", "GPL-3.0-or-later" ],
  [ "MIT", "MIT" ],
  [ "BSD 3-Clause", "BSD-3-Clause" ],
  [ "custom (you will fill in the license text yourself)", "custom" ] ]

#
gap> PKGMKR_CheckGitHubUsername( rec(), "octo-cat" );
true
gap> PKGMKR_CheckGitHubUsername( rec(), "-octo-cat" ) =
> "The name must be nonempty, consist of alphanumerical characters or '-', and must not start with '-'.";
true
gap> PKGMKR_CheckRepositoryName( rec(), "demo.repo" );
true
gap> PKGMKR_CheckRepositoryName( rec(), "-demo" ) =
> "The name must be nonempty, consist of alphanumerical characters or '-', '.', '_', and must not start with '-'.";
true
gap> PKGMKR_CheckPackageName( rec(), "Print" ) =
> "The package name must be a valid identifier (non-empty, only letters and digits, not a number, not a keyword) which is not the name of a global variable.";
true
gap> STOP_TEST( "PackageMaker: input.tst", 1 );
