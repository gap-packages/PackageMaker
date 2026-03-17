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

BindGlobal( "PKGMKR_SpecValue", function( spec, field, answers )
    local value;

    if not IsBound( spec.( field ) ) then
        return fail;
    fi;

    value := spec.( field );
    if IsFunction( value ) then
        return value( answers );
    fi;
    return value;
end );

BindGlobal( "PKGMKR_IsQuestionVisible", function( spec, answers )
    local visible;

    visible := PKGMKR_SpecValue( spec, "isVisible", answers );
    return visible in [ fail, true ];
end );

BindGlobal( "PKGMKR_AskQuestionWithUI", function( spec, ui, answers )
    local kind, default, choices;

    kind := spec.kind;
    default := PKGMKR_SpecValue( spec, "default", answers );

    if kind = "message" then
        return ui.message( spec, answers );
    elif kind = "computed" then
        return PKGMKR_SpecValue( spec, "value", answers );
    elif kind = "string" then
        return ui.string( spec, answers, default );
    elif kind = "yesno" then
        return ui.yesno( spec, answers, default );
    elif kind = "choice" then
        choices := PKGMKR_SpecValue( spec, "choices", answers );
        return ui.choice( spec, answers, choices, default );
    fi;

    Error( "Unknown question kind ", kind );
end );

BindGlobal( "PKGMKR_ValidateQuestionAnswer", function( spec, answers, value )
    local result;

    if not IsBound( spec.validate ) then
        return true;
    fi;

    result := spec.validate( answers, value );
    if result = true then
        return true;
    fi;

    Print( result, "\n" );
    return false;
end );

BindGlobal( "PKGMKR_NormalizeQuestionAnswer", function( spec, answers, value )
    if not IsBound( spec.normalize ) then
        return value;
    fi;

    return spec.normalize( answers, value );
end );

BindGlobal( "PKGMKR_AskQuestions", function( spec, ui, answers )
    local question, value;

    for question in spec do
        if not PKGMKR_IsQuestionVisible( question, answers ) then
            continue;
        fi;

        if question.kind = "message" then
            PKGMKR_AskQuestionWithUI( question, ui, answers );
            continue;
        fi;

        while true do
            value := PKGMKR_AskQuestionWithUI( question, ui, answers );
            if PKGMKR_ValidateQuestionAnswer( question, answers, value ) then
                value := PKGMKR_NormalizeQuestionAnswer( question, answers, value );
                answers.( question.key ) := value;
                break;
            fi;
        od;
    od;

    return answers;
end );

BindGlobal( "EXTRA_PERSON_KEYS", [ "Email", "WWWHome", "Institution", "Place", "PostalAddress"] );

BindGlobal( "PKGMKR_PrintMessage", function( prompt )
    local line;

    if IsString( prompt ) then
        Print( prompt, "\n" );
        return;
    fi;

    for line in prompt do
        Print( line, "\n" );
    od;
end );

BindGlobal( "PKGMKR_DefaultInputUI", function()
    return rec(
        message := function( spec, answers )
            PKGMKR_PrintMessage( spec.prompt );
            return fail;
        end,
        string := function( spec, answers, default )
            if default = fail then
                return AskQuestion( spec.prompt );
            fi;
            return AskQuestion( spec.prompt : default := default );
        end,
        yesno := function( spec, answers, default )
            if default = fail then
                return AskYesNoQuestion( spec.prompt );
            fi;
            return AskYesNoQuestion( spec.prompt : default := default );
        end,
        choice := function( spec, answers, choices, default )
            if default = fail then
                return AskAlternativesQuestion( spec.prompt, choices );
            fi;
            return AskAlternativesQuestion( spec.prompt, choices : default := default );
        end
    );
end );

BindGlobal( "PKGMKR_DefaultGitHubUsername", function( answers )
    local tmp;

    tmp := PKGMKR_CommandOutput( DirectoryCurrent(), "git",
                                 [ "config", "github.user" ] );
    if tmp <> fail then
        return Chomp( tmp );
    fi;
    return fail;
end );

BindGlobal( "PKGMKR_CheckPackageName", function( answers, value )
    if LowercaseString( value ) in RecNames( GAPInfo.PackagesInfo ) then
        return Concatenation( "A package with name '",
                              LowercaseString( value ),
                              "' exists already (see GAPInfo.PackagesInfo)." );
    fi;

    if not IsValidIdentifier( value ) or IsBoundGlobal( value ) then
        return Concatenation(
            "The package name must be a valid identifier ",
            "(non-empty, only letters and digits, not a number, ",
            "not a keyword) which is not the name of a global variable." );
    fi;

    if IsExistingFile( value ) then
        return Concatenation(
            "A file or directory with this name already exists. ",
            "Please move it away or choose another package name." );
    fi;

    return true;
end );

BindGlobal( "PKGMKR_ValidateSubtitle", function( answers, value )
    if Length( value ) < 80 then
        return true;
    fi;
    return "The description must be shorter than 80 characters.";
end );

BindGlobal( "PKGMKR_CheckGitHubUsername", function( answers, value )
    if 0 < Length( value ) and value[1] <> '-'
       and ForAll( value, c -> IsAlphaChar( c ) or IsDigitChar( c ) or c = '-' ) then
        return true;
    fi;

    return Concatenation(
        "The name must be nonempty, consist of alphanumerical ",
        "characters or '-', and must not start with '-'." );
end );

BindGlobal( "PKGMKR_CheckRepositoryName", function( answers, value )
    if 0 < Length( value ) and value[1] <> '-'
       and ForAll( value,
                   c -> IsAlphaChar( c ) or IsDigitChar( c ) or c in "-._" ) then
        return true;
    fi;

    return Concatenation(
        "The name must be nonempty, consist of alphanumerical ",
        "characters or '-', '.', '_', and must not start with '-'." );
end );

BindGlobal( "PKGMKR_LicenseChoices", [
    [ "GPL 2 or later (default; used by GAP itself and many packages)",
      "GPL-2.0-or-later" ],
    [ "GPL 3 or later", "GPL-3.0-or-later" ],
    [ "MIT", "MIT" ],
    [ "BSD 3-Clause", "BSD-3-Clause" ],
    [ "custom (you will fill in the license text yourself)", "custom" ]
] );

BindGlobal( "PKGMKR_InputSpecification", [
    rec(
        key := "Welcome",
        kind := "message",
        prompt := [
            "Welcome to the GAP PackageMaker Wizard.",
            "I will now guide you step-by-step through the package",
            "creation process by asking you some questions.",
            ""
        ]
    ),
    rec(
        key := "PackageName",
        kind := "string",
        prompt := "What is the name of the package?",
        validate := PKGMKR_CheckPackageName
    ),
    rec(
        key := "Subtitle",
        kind := "string",
        prompt := "Enter a short (one sentence) description of your package:",
        validate := PKGMKR_ValidateSubtitle
    ),
    rec(
        key := "License",
        kind := "choice",
        prompt := [
            "Which license should the package use?",
            "GAP itself and many GAP packages use GPL-2.0-or-later,",
            "so that is the default."
        ],
        choices := PKGMKR_LicenseChoices,
        default := 1
    ),
    rec(
        key := "GitHub",
        kind := "yesno",
        prompt := "Shall I prepare your new package for GitHub?",
        default := true
    ),
    rec(
        key := "GitHubActions",
        kind := "yesno",
        prompt := "Do you want to use GitHub Actions for automated tests and making releases?",
        default := true,
        isVisible := answers -> answers.GitHub
    ),
    rec(
        key := "GitHubActions",
        kind := "computed",
        value := answers -> false,
        isVisible := answers -> not answers.GitHub
    ),
    rec(
        key := "GitHubUrlHelp",
        kind := "message",
        prompt := [
            "I need to know the URL of the GitHub repository.",
            "It is of the form https://github.com/USER/REPOS."
        ],
        isVisible := answers -> answers.GitHub
    ),
    rec(
        key := "GitHub_username",
        kind := "string",
        prompt := "What is USER (typically your GitHub username)?",
        default := PKGMKR_DefaultGitHubUsername,
        validate := PKGMKR_CheckGitHubUsername,
        isVisible := answers -> answers.GitHub
    ),
    rec(
        key := "GitHub_reponame",
        kind := "string",
        prompt := "What is REPOS, the repository name?",
        default := answers -> answers.PackageName,
        validate := PKGMKR_CheckRepositoryName,
        isVisible := answers -> answers.GitHub
    ),
    rec(
        key := "PackageWWWHome",
        kind := "computed",
        value := function( answers )
            return Concatenation( "https://", answers.GitHub_username,
                                  ".github.io/", answers.GitHub_reponame );
        end,
        isVisible := answers -> answers.GitHub
    ),
    rec(
        key := "PackageWWWHome",
        kind := "string",
        prompt := "URL of package homepage?",
        normalize := function( answers, value )
            if value = "" then
                return "https://TODO";
            fi;
            return value;
        end,
        isVisible := answers -> not answers.GitHub
    ),
    rec(
        key := "kernel_extension",
        kind := "choice",
        prompt := "Shall your package provide a GAP kernel extension?",
        choices := [ [ "No", "" ],
                     [ "Yes, written in C", "C" ],
                     [ "Yes, written in C++", "C++" ] ]
    )
] );

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

BindGlobal( "PKGMKR_AskPersons", function()
    local answers, pers, p, name, key, q, tmp;

    answers := [];
    #
    # Package authors and maintainers
    #
    pers := PkgAuthorRecs();
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

        Add( answers, p );
    until false = AskYesNoQuestion("Add another person?" : default := false);

    return answers;
end );

InstallGlobalFunction( PackageWizardInput, function()
    local answers;

    answers := rec(
        Version := "0.1",
        Date := Today()
    );

    PKGMKR_AskQuestions( PKGMKR_InputSpecification,
                         PKGMKR_DefaultInputUI(),
                         answers );
    answers.Persons := PKGMKR_AskPersons();

    return answers;
end );
