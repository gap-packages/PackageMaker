#
# PackageMaker - a GAP script for creating GAP packages
#
# Copyright (c) 2013-2019 Max Horn
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

BindGlobal( "DISABLED_ENTRY", MakeImmutable("DISABLED_ENTRY") );

BindGlobal( "CopyTemplate", function (template, outfile, subst)
    local out_stream, in_stream, line, pos, end_pos, key, val, i, tmp, c;

    tmp := DirectoriesPackageLibrary( "PackageMaker", "templates" );
    if template = fail then
        template := Filename( tmp, outfile );
    else
        template := Filename( tmp, template );
    fi;
    outfile := Concatenation( subst.PackageName, "/", outfile );

    in_stream := InputTextFile( template );
    out_stream := OutputTextFile( outfile, false );
    SetPrintFormattingStatus( out_stream, false );

    while not IsEndOfStream( in_stream ) do
        line := ReadLine( in_stream );
        if line = fail then
            break;
        fi;
        WriteAll( out_stream, line );
    od;

    CloseStream(out_stream);
    CloseStream(in_stream);
end);

BindGlobal( "TranslateTemplate", function (template, outfile, subst)
    local out_stream, in_stream, line, pos, end_pos, key, val, i, tmp, c;

    tmp := DirectoriesPackageLibrary( "PackageMaker", "templates" );
    if template = fail then
        template := Filename( tmp, outfile );
    else
        template := Filename( tmp, template );
    fi;
    outfile := Concatenation( subst.PackageName, "/", outfile );

    in_stream := InputTextFile( template );
    out_stream := OutputTextFile( outfile, false );
    SetPrintFormattingStatus( out_stream, false );

    while not IsEndOfStream( in_stream ) do
        line := ReadLine( in_stream );
        if line = fail then
            break;
        fi;

        # Substitute {{ }} blocks
        pos := -1;
        while true do
            pos := PositionSublist( line, "{{", pos + 1 );
            if pos = fail then
                break;
            fi;

            end_pos := PositionSublist( line, "}}", pos + 1 );
            if end_pos = fail then
                continue;
            fi;

            key := line{[pos+2..end_pos-1]};
            if not IsBound(subst.(key)) then
                Error("Unknown substitution key '",key,"'\n");
            else
                val := subst.(key);
                if not IsString(val) and IsList(val) and IsRecord(val[1]) then
                    WriteAll( out_stream, line{[1..pos-1]} );
                    PrintTo( out_stream, "[\n" );
                    for i in [1..Length(val)] do
                        PrintTo( out_stream, "  rec(\n" );
                        for key in RecNames(val[i]) do
                            tmp := val[i].(key);
                            if tmp = DISABLED_ENTRY then
                                PrintTo( out_stream, "    #", key, " := TODO,\n");
                                continue;
                            fi;
                            PrintTo( out_stream, "    ", key, " := ");
                            if IsString(tmp) then
                                if '\n' in tmp then
                                    PrintTo( out_stream, "Concatenation(\n" );
                                    tmp := SplitString(tmp,"\n");
                                    for c in [1..Length(tmp)-1] do
                                        PrintTo( out_stream, "               \"",tmp[c],"\\n\",\n");
                                    od;
                                    PrintTo( out_stream, "               \"",tmp[Length(tmp)],"\" )");
                                else
                                    PrintTo( out_stream, "\"" );
                                    for c in tmp do
                                        if c = '\n' then
                                            WriteByte( out_stream, IntChar('\\') );
                                            WriteByte( out_stream, IntChar('n') );
                                        else
                                            WriteByte( out_stream, IntChar(c) );
                                        fi;
                                    od;
                                    PrintTo( out_stream, "\"");
                                fi;
                            else
                                PrintTo( out_stream, tmp );
                            fi;
                            PrintTo( out_stream, ",\n" );
                        od;
                        PrintTo( out_stream, "  ),\n" );
                    od;
                    PrintTo( out_stream, "]" );
                    WriteAll( out_stream, line{[end_pos+2..Length(line)]} );
                    line := "";
                else
                    line := Concatenation( line{[1..pos-1]}, val, line{[end_pos+2..Length(line)]} );
                fi;
            fi;

#            Print("Found at pos ", [pos,from], " string '", line{[pos..end_pos+1]}, "'\n");
#            Print("Found at pos ", [pos,from], " string '", line{[pos+2..end_pos-1]}, "'\n");

        od;

        WriteAll( out_stream, line );

    od;

    CloseStream(out_stream);
    CloseStream(in_stream);
end );

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

BindGlobal( "Command", function(cmd, args)
    local out, outstream, instream, path, cmd_full, res;

    out := "";
    outstream := OutputTextString(out, false);
    instream := InputTextString("");

    path := DirectoriesSystemPrograms();
    cmd_full := Filename( path, cmd );
    if cmd_full = fail then
        CloseStream(instream);
        CloseStream(outstream);
        #Error("Could not locate command '", cmd, "' in your PATH");
        return fail;
    fi;

    res := Process(DirectoryCurrent(), cmd_full, instream, outstream, args);

    CloseStream(instream);
    CloseStream(outstream);

    if res = 0 then
        return out;
    fi;
    return fail;
end );

BindGlobal( "CreateGitRepository", function(dir, github)
    local path, stdin, stdout, cmd_full, RunGit, remote, tmp, shell, maindir;

    path := DirectoriesSystemPrograms();
    cmd_full := Filename( path, "git" );
    if cmd_full = fail then
        Error("Could not locate 'git' in your PATH");
    fi;

    stdin := InputTextUser();
    stdout := OutputTextUser();

    RunGit := function(args, errorMsg)
        local res;
        res := Process(dir, cmd_full, stdin, stdout, args);
        if res <> 0 then
            Error(errorMsg);
        fi;
    end;

    Print("Creating the git repository...\n");

    RunGit(["init", "-b", "main"],
           "Failed to create git repository");
    RunGit(["add", "."],
           "Failed to add files to git repository");
    RunGit(["commit", "-m", "initial import"],
           "Failed to commit files to git repository");

    # TODO: ask whether to use SSH or https?
    remote := Concatenation("https://github.com/", github.username, "/", github.reponame, ".git");
    #remote := Concatenation("git@github.com:", github.username, "/", github.reponame, ".git");

    RunGit(["remote", "add", "origin", remote],
           "Failed to add GitHub remote to git repository");

#   The following command unfortunately does not work:
#     RunGit(["branch", "-u", "origin", "main"],
#            "Failed to set upstream remote for main branch");

    if github.gh_pages then
        # Setup everything for GitHubPagesForGAP, following the instructions
        # from its README.

        Print("\n");
        Print("Fetching GitHubPagesForGAP...\n");

        RunGit(["remote", "add", "gh-gap", "https://github.com/gap-system/GitHubPagesForGAP"],
               "Failed to add gh-gap remote to gh-pages");

        RunGit(["fetch", "gh-gap"],
               "Failed to fetch gh-gap remote");

        Print("Creating gh-pages branch...\n");

        RunGit(["branch", "gh-pages", "gh-gap/gh-pages", "--no-track"],
               "Failed to create gh-pages branch");

        # add a worktree (TODO: check that the git version is recent enough)
        RunGit(["worktree", "add", "gh-pages", "gh-pages"],
               "Failed to create gh-pages worktree");

        # cd gh-pages
        maindir := dir;
        dir := Directory(Filename(dir, "gh-pages"));
        if not IsDirectoryPath(dir) then
            Error(dir, " is not a directory");
        fi;

        # We use the shell for the next commands to get glob expansion
        shell := Filename(DirectoriesSystemPrograms(), "sh");

        # cp -f ../PackageInfo.g ../README .
        tmp := Process(dir, shell, stdin, stdout, ["-c", "cp -f ../PackageInfo.g ../README.md ."]);
        if tmp <> 0 then
            Error("Failed to copy files to gh-pages directory");
        fi;

        # cp -f ../doc/*.{css,html,js,txt} doc/
        # TODO: the above only makes sense if we run "makedoc.g" before that.
        # Which could fail (?) depending on the installed AutoDoc version...

        # gap update.g
        tmp := Process(dir, shell, stdin, stdout, ["-c", "gap -A -q update.g"]);
        if tmp <> 0 then
            Error("Failed to copy files to gh-pages directory");
        fi;

        # add and commit
        RunGit(["add", "-A"],
               "Failed adding files to gh-pages branch");

        RunGit(["commit", "-m", "Setup gh-pages based on GitHubPagesForGAP"],
               "Failed committing files to gh-pages branch");

        dir := maindir;
    fi;


    Print("Done creating git repository.\n");

    # push to remote, but only after the user said it was OK
    tmp := Concatenation("https://github.com/", github.username, "/", github.reponame);
    Print("I will now wait for you to create <", tmp, "> via <https://github.com/new>.\n");
    Print("Afterwards, I can push the new package repository to GitHub.\n");
    if AskYesNoQuestion("Shall I push the package repository to GitHub now?" : default := true) <> true then
        return;
    fi;

    RunGit(["push", "-u", "origin", "main"],
           "Failed to push main branch to GitHub");

    if github.gh_pages then

        dir := Directory(Filename(dir, "gh-pages"));

        RunGit(["push", "-u", "origin", "gh-pages"],
               "Failed to push gh-pages branch to GitHub");

    fi;
end );

# Return current date as a string with format DD/MM/YYYY.
BindGlobal( "Today", function()
    local secs, tmp, date;
    tmp := IO_gettimeofday();
    secs := tmp.tv_sec;

    date := DMYDay(Int(secs / 86400));
    date := date + [100, 100, 0];
    date := List( date, String );
    date := Concatenation( date[1]{[2,3]}, "/", date[2]{[2,3]}, "/", date[3] );

    return date;
end );

InstallGlobalFunction( PackageWizard, function()
    local pkginfo, create_repo, date, p, github, alphanum, kernel,
        pers, name, key, q, tmp, dir;

    Print("Welcome to the GAP PackageMaker Wizard.\n",
          "I will now guide you step-by-step through the package\n",
          "creation process by asking you some questions.\n\n");

    #
    # Phase 1: Ask lots of questions.
    #

    pkginfo := rec();

    while true do
        pkginfo.PackageName := AskQuestion("What is the name of the package?" : isValid := IsValidIdentifier);
        if IsValidIdentifier(pkginfo.PackageName) then
            break;
        fi;
        Print("Sorry, the package name must be a valid identifier (non-empty, only letters and digits, not a number, not a keyword)\n");
    od;
    if IsExistingFile(pkginfo.PackageName) then
        Print("ERROR: A file or directory with this name already exists.\n");
        Print("Please move it away or choose another package name.");
        return;
    fi;

    pkginfo.Subtitle := AskQuestion("Enter a short (one sentence) description of your package:"
                : isValid := g -> Length(g) < 80);

    #
    # Package version: Just default to some value. We could ask the user
    # for a version, but they only need to change one spot for it, and
    # when creating a new package, this is not so important.
    #
    pkginfo.Version := "0.1";
    #pkginfo.Version := AskQuestion("What is the version of your package?" : default := "0.1" );

    #
    # Package release date: just pick the current date. Similarly to the
    # package version, we don't allow customizing this in the wizard.
    #
    pkginfo.Date := Today();
    #pkginfo.Date := AskQuestion("What is the release date of your package?" : default := Today() );

    github := rec();
    create_repo := AskYesNoQuestion("Shall I prepare your new package for GitHub?" : default := true);

    if create_repo then
        alphanum := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        # Try to get github username from git config
        tmp := Command("git", ["config", "github.user"]);
        if tmp <> fail then
            tmp := Chomp(tmp);
        fi;

        # TODO: just always do this??
        github.gh_pages := AskYesNoQuestion("Do you want to use GitHubPagesForGAP?" : default := true);

        # TODO: just always do this??
        github.ci := AskYesNoQuestion("Do you want to use GitHubActions and Codecov?" : default := true);

        Print("I need to know the URL of the GitHub repository.\n");
        Print("It is of the form https://github.com/USER/REPOS.\n");
        github.username := AskQuestion("What is USER (typically your GitHub username)?"
                            : isValid := n -> Length(n) > 0 and n[1] <> '-' and
                                    ForAll(n, c -> c = '-' or c in alphanum),
                              default := tmp);
        github.reponame := AskQuestion("What is REPOS, the repository name?"
                            : default := pkginfo.PackageName,
                              isValid := n -> Length(n) > 0 and
                                    ForAll(n, c -> c in "-._" or c in alphanum));

        pkginfo.PackageURLs := Concatenation("""
SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/""", github.username, "/", github.reponame, "\"", """,
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://""", github.username, ".github.io/", github.reponame, "/\"", """,
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
""");

    else
        pkginfo.PackageWWWHome := AskQuestion("URL of package homepage?");
        if pkginfo.PackageWWWHome = "" then
            pkginfo.PackageWWWHome := "https://TODO";
        fi;

        # Ensure the URL ends with a trailing slash.
        if Length(pkginfo.PackageWWWHome) > 0 and pkginfo.PackageWWWHome[Length(pkginfo.PackageWWWHome)] <> '/' then
            Add(pkginfo.PackageWWWHome, '/');
        fi;

        pkginfo.PackageURLs := Concatenation("""
#SourceRepository := rec( Type := "TODO", URL := "URL" ),
#IssueTrackerURL := "TODO",
PackageWWWHome := """, "\"", pkginfo.PackageWWWHome, "\"", """,
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL     := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL     := Concatenation( ~.PackageWWWHome,
                                 "/", ~.PackageName, "-", ~.Version ),
""");
    fi;

    kernel := AskAlternativesQuestion("Shall your package provide a GAP kernel extension?",
                    [
                      [ "No", fail ],
                      [ "Yes, written in C", "C" ],
                      [ "Yes, written in C++", "C++" ],
                    ] );

    if kernel <> fail then

        pkginfo.KERNEL_EXT_INIT_G := StripBeginEnd("""
if not LoadKernelExtension("{{PackageName}}") then
  Error("failed to load kernel module of package {{PackageName}}");
fi;
""", "\n");

        if kernel = "C++" then
            pkginfo.KERNEL_EXT_LANG_EXT := "cc";
        else
            pkginfo.KERNEL_EXT_LANG_EXT := "c";
        fi;

        pkginfo.AvailabilityTest := StripBeginEnd("""
function()
  if not IsKernelExtensionAvailable("{{PackageName}}") then
    LogPackageLoadingMessage(PACKAGE_WARNING,
                             "failed to load kernel module of package {{PackageName}}");
    return false;
  fi;
  return true;
end
""", "\n");

    else
        pkginfo.KERNEL_EXT_INIT_G := "";
        pkginfo.KERNEL_EXT_LANG_EXT := "";
        pkginfo.AvailabilityTest := "ReturnTrue";
    fi;

    #
    # Package authors and maintainers
    #
    pers := PkgAuthorRecs();
    pkginfo.Persons := [];
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

        Add(pkginfo.Persons, p);
    until false = AskYesNoQuestion("Add another person?" : default := false);

    #
    # Phase 2: Create the package directory structure
    #

    if not AUTODOC_CreateDirIfMissing( pkginfo.PackageName ) then
        Error("Failed to create package directory");
    fi;

    TranslateTemplate(fail, "README.md", pkginfo );
    TranslateTemplate(fail, "LICENSE", pkginfo );
    TranslateTemplate("PackageInfo.g.in", "PackageInfo.g", pkginfo );
    TranslateTemplate(fail, "init.g", pkginfo );
    TranslateTemplate(fail, "read.g", pkginfo );
    TranslateTemplate(fail, "makedoc.g", pkginfo );

    if not AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/gap" ) ) then
        Error("Failed to create `gap' directory in package directory");
    fi;
    TranslateTemplate("gap/PKG.gi", Concatenation("gap/", pkginfo.PackageName, ".gi"), pkginfo );
    TranslateTemplate("gap/PKG.gd", Concatenation("gap/", pkginfo.PackageName, ".gd"), pkginfo );

    if not AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/tst" ) ) then
        Error("Failed to create `tst' directory in package directory");
    fi;
    TranslateTemplate(fail, "tst/testall.g", pkginfo );

    if kernel <> fail then
        # create a simple kernel extension with a build system

        TranslateTemplate(fail, "Makefile.in", pkginfo );
        TranslateTemplate(fail, "Makefile.gappkg", pkginfo );
        TranslateTemplate(fail, "configure", pkginfo );
        Exec(Concatenation("chmod a+x ", pkginfo.PackageName, "/configure")); # FIXME HACK

        if not AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/src" ) ) then
            Error("Failed to create `src' directory in package directory");
        fi;
        if kernel = "C++" then
            TranslateTemplate("src/PKG.cc", Concatenation("src/", pkginfo.PackageName, ".cc"), pkginfo );
        else
            TranslateTemplate("src/PKG.c", Concatenation("src/", pkginfo.PackageName, ".c"), pkginfo );
        fi;
    fi;

    if IsBound(github.ci) and github.ci then
        if not AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github" ) ) then
            Error("Failed to create `.github' directory in package directory");
        fi;
        if not AUTODOC_CreateDirIfMissing( Concatenation( pkginfo.PackageName, "/.github/workflows" ) ) then
            Error("Failed to create `.github/workflows' directory in package directory");
        fi;
        TranslateTemplate(fail, ".codecov.yml", pkginfo );
        CopyTemplate(fail, ".github/workflows/CI.yml", pkginfo);
    fi;

    #
    # Phase 3 (optional): Setup a git repository and gh-pages
    #
    if create_repo then

        TranslateTemplate(fail, ".gitattributes", pkginfo );
        TranslateTemplate(fail, ".gitignore", pkginfo );

        dir := Directory(pkginfo.PackageName);
        if not IsDirectoryPath(dir) then
            Error(dir, " is not a directory");
        fi;

        CreateGitRepository(dir, github);
    fi;
end );
