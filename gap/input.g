BindGlobal( "AskYesNoQuestion", function( question )
    local stream, default, ans;

    stream := InputTextUser();

    Print(question);
    default := ValueOption( "default" );
    if default = true then
        Print(" [Y/n] \c");
    elif default = false then
        Print(" [y/N] \c");
    else
        default := fail;
        Print(" [y/n] \c");
    fi;

    while true do
        ans := ReadByte(stream);
        if ans = 3 or ans = 4 then
            Print("\nUser aborted\n"); # HACK since Ctrl-C does not work
            JUMP_TO_CATCH("abort"); # HACK, undocumented command
        fi;
        ans := CharInt(ans);
        if ans in "yYnN" then
            Print([ans,'\n']);
            ans := ans in "yY";
            break;
        elif ans in "\n\r" and default <> fail then
            Print("\n");
            ans := default;
            break;
        fi;
    od;

    CloseStream(stream);
    return ans;
end );

BindGlobal( "AskQuestion", function( question )
    local stream, default, ans, history_bak;

    default := ValueOption( "default" );

    # Print the question prompt
    Print(question, " ");
    if default <> fail then
        Print("[", default, "] ");
    fi;
    Print("\c");

    # Read user input
    stream := InputTextUser();
    history_bak := GAPInfo.History;
    GAPInfo.History := rec( Last := 0, Lines := [ ], Pos := 1 );
    ans := ReadLine(stream);    # FIXME: this disables Ctrl-C !!!!
    GAPInfo.History := history_bak;
    CloseStream(stream);

    # Catch Ctrl-D
    if ans = fail then
        Print("\nUser aborted\n");
        JUMP_TO_CATCH("abort");
    fi;

    # Clean it up
    if ans = "\n" and default <> fail then
        ans := default;
    else
        ans := Chomp(ans);
    fi;
    NormalizeWhitespace("ans");

    # HACK since Ctrl-C does not work
    if ans = "quit" then
        Print("\nUser aborted\n");
        JUMP_TO_CATCH("abort");
    fi;

    return ans;
end );

BindGlobal( "AskAlternativesQuestion", function( question, answers )
    local stream, default, i, ans;

    Assert(0, IsList(answers) and Length(answers) >= 2);

    default := ValueOption( "default" );
    if default = fail then
        default := 1;
    else
        Assert(0, default in [1..Length(answers)]);
    fi;

    for i in [1..Length(answers)] do
        ans := answers[i][1];
        # HACK to get multi line answers printed more nicely
        ans := ReplacedString(ans, "\n", "\n       ");
        Print(" (",i,")   ", ans, "\n");
    od;

    while true do
        ans := AskQuestion(question : default := default);

        if Int(ans) in [1..Length(answers)] then
            ans := answers[Int(ans)][2];
            break;
        fi;

        question := "Invalid choice. Please try again";
    od;

    return ans;
end );

BindGlobal( "EXTRA_PERSON_KEYS", [ "Email", "WWWHome", "Institution", "Place", "PostalAddress"] );

BindGlobal( "PkgAuthorRecs", function()
    local pers, pkgname, pkg, u, p, k, name;
    pers:=[];
    for pkgname in RecNames(GAPInfo.PackagesInfo) do
        for pkg in GAPInfo.PackagesInfo.(pkgname) do
            if IsBound(pkg.Persons) then
                Append(pers, pkg.Persons);
            fi;
        od;
    od;

    # Assume that entries with identical Firstname + Lastname
    # correspond to same person. Aggregate their person records
    # accordingly.
    u := rec();
    for p in pers do
        name := Concatenation(p.LastName, ", ", p.FirstNames);

        if not IsBound(u.(name)) then
            u.(name) := rec();
            for k in EXTRA_PERSON_KEYS do
                u.(name).(k) := [];
            od;
        fi;

        for k in EXTRA_PERSON_KEYS do
            if IsBound(p.(k)) then
                Add(u.(name).(k), p.(k));
            fi;
        od;
    od;

    # We now may have many duplicate entries for e.g. emails.
    # Remove the duplicates and sort the remaining unique
    # keys by how often they occurred before.
    for name in RecNames(u) do
        p := u.(name);
        for k in EXTRA_PERSON_KEYS do
            p.(k) := Collected(p.(k));
            SortBy(p.(k), x -> -x[2]);
            p.(k) := List(p.(k), x -> x[1]);
        od;
    od;

    return u;
end );

InstallGlobalFunction( PackageWizardInput, function()
    local answers, create_repo, p, github, alphanum, kernel,
        pers, name, key, q, tmp;

    answers := rec();

    while true do
        answers.PackageName :=
          AskQuestion( "What is the name of the package?"
                       : isValid := IsValidIdentifier );
        if IsValidIdentifier( answers.PackageName ) then
            break;
        fi;
        Print("Sorry, the package name must be a valid identifier (non-empty, only letters and digits, not a number, not a keyword)\n");
    od;
    if IsExistingFile( answers.PackageName ) then
        Print("ERROR: A file or directory with this name already exists.\n");
        Print("Please move it away or choose another package name.");
        return fail;
    fi;

    answers.Subtitle :=
      AskQuestion( "Enter a short (one sentence) description of your package:"
                   : isValid := g -> Length( g ) < 80 );
    answers.Version := "0.1";
    answers.Date := Today();

    github := rec();
    create_repo :=
      AskYesNoQuestion( "Shall I prepare your new package for GitHub?"
                        : default := true );
    answers.GitHub := create_repo;

    if create_repo then
        alphanum := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        # Try to get github username from git config
        tmp := PKGMKR_CommandOutput( DirectoryCurrent(),
                                     "git",
                                     [ "config", "github.user" ] );
        if tmp <> fail then
            tmp := Chomp(tmp);
        fi;

        # TODO: just always do this??
        github.ci := AskYesNoQuestion(
            "Do you want to use GitHub Actions for automated tests and making releases?"
            : default := true);
        answers.GitHubPagesForGAP := github.ci;

        Print("I need to know the URL of the GitHub repository.\n");
        Print("It is of the form https://github.com/USER/REPOS.\n");
        github.username := AskQuestion("What is USER (typically your GitHub username)?"
                            : isValid := n -> Length(n) > 0 and n[1] <> '-' and
                                    ForAll(n, c -> c = '-' or c in alphanum),
                              default := tmp);
        github.reponame := AskQuestion("What is REPOS, the repository name?"
                            : default := answers.PackageName,
                              isValid := n -> Length(n) > 0 and
                                    ForAll(n, c -> c in "-._" or c in alphanum));
        answers.GitHub_username := github.username;
        answers.GitHub_reponame := github.reponame;
        answers.PackageWWWHome :=
          Concatenation( "https://", github.username,
                         ".github.io/", github.reponame );

    else
        answers.GitHubPagesForGAP := false;
        answers.PackageWWWHome := AskQuestion("URL of package homepage?");
        if answers.PackageWWWHome = "" then
            answers.PackageWWWHome := "https://TODO";
        fi;
    fi;

    kernel := AskAlternativesQuestion("Shall your package provide a GAP kernel extension?",
                    [
                      [ "No", fail ],
                      [ "Yes, written in C", "C" ],
                      [ "Yes, written in C++", "C++" ],
                    ] );
    if kernel = fail then
        answers.kernel_extension := "";
    else
        answers.kernel_extension := kernel;
    fi;

    #
    # Package authors and maintainers
    #
    pers := PkgAuthorRecs();
    answers.Persons := [];
    Print("\n");
    Print("Next I will ask you about the package authors and maintainers.\n\n");
    repeat
        p := rec();
        p.LastName := AskQuestion("Last name?");
        p.FirstNames := AskQuestion("First name(s)?");

        p.IsAuthor := AskYesNoQuestion("Is this one of the package authors?" : default := true);
        p.IsMaintainer := AskYesNoQuestion("Is this a package maintainer?" : default := true);

        name := Concatenation(p.LastName, ", ", p.FirstNames);
        for key in EXTRA_PERSON_KEYS do
            q := Concatenation(key, "?");
            if IsBound(pers.(name)) then
                tmp := pers.(name).(key);
            else
                tmp := [];
            fi;
            if Length(tmp) = 0 then
                p.(key) := AskQuestion(q);
            elif Length(tmp) = 1 then
                p.(key) := AskQuestion(q : default := tmp[1]);
            else
                tmp := List(tmp, x -> [x,x]);
                Add(tmp, ["other", fail]);
                p.(key) := AskAlternativesQuestion(q, tmp);
                if p.(key) = fail then
                    p.(key) := AskQuestion(q);
                fi;
            fi;
            if p.(key) = "" then
                p.(key) := DISABLED_ENTRY;
            else
                # small hack to allow interactive input of multi-line postal addresses
                p.(key) := ReplacedString(p.(key), "\\n", "\n");
            fi;
        od;

        Add(answers.Persons, p);
    until false = AskYesNoQuestion("Add another person?" : default := false);

    return answers;
end );
