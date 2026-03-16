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

BindGlobal( "NormalizePackageWizardAnswers", function( answers )
    local pkginfo, create_repo, github, alphanum, kernel, package_www_home;

    if not IsRecord( answers ) then
        Error( "PackageWizardGenerate expects a record as input" );
    fi;

    if not IsBound( answers.PackageName )
       or not IsString( answers.PackageName )
       or not IsValidIdentifier( answers.PackageName ) then
        Error( "PackageName must be a valid identifier" );
    fi;
    if IsExistingFile( answers.PackageName ) then
        Error( "A file or directory with this name already exists: ",
               answers.PackageName );
    fi;

    pkginfo := rec();
    pkginfo.PackageName := answers.PackageName;

    if IsBound( answers.Subtitle ) then
        pkginfo.Subtitle := answers.Subtitle;
    else
        pkginfo.Subtitle := "";
    fi;

    if IsBound( answers.Version ) then
        pkginfo.Version := answers.Version;
    else
        pkginfo.Version := "0.1";
    fi;

    if IsBound( answers.Date ) then
        pkginfo.Date := answers.Date;
    else
        pkginfo.Date := Today();
    fi;

    if IsBound( answers.Persons ) then
        pkginfo.Persons := answers.Persons;
    else
        pkginfo.Persons := [];
    fi;

    create_repo := IsBound( answers.GitHub ) and answers.GitHub = true;
    github := rec();

    if create_repo then
        alphanum :=
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        if not IsBound( answers.GitHub_username )
           or not IsString( answers.GitHub_username )
           or Length( answers.GitHub_username ) = 0
           or answers.GitHub_username[1] = '-'
           or not ForAll( answers.GitHub_username,
                           c -> c = '-' or c in alphanum ) then
            Error( "GitHub_username must be a valid GitHub user or organization name" );
        fi;
        if not IsBound( answers.GitHub_reponame )
           or not IsString( answers.GitHub_reponame )
           or Length( answers.GitHub_reponame ) = 0
           or not ForAll( answers.GitHub_reponame,
                           c -> c in "-._" or c in alphanum ) then
            Error( "GitHub_reponame must be a valid GitHub repository name" );
        fi;

        github.username := answers.GitHub_username;
        github.reponame := answers.GitHub_reponame;
        github.ci := not IsBound( answers.GitHubPagesForGAP )
                     or answers.GitHubPagesForGAP = true;

        if IsBound( answers.PackageWWWHome ) and answers.PackageWWWHome <> "" then
            package_www_home := answers.PackageWWWHome;
        else
            package_www_home :=
              Concatenation( "https://", github.username,
                             ".github.io/", github.reponame );
        fi;
        if package_www_home[Length( package_www_home )] <> '/' then
            Add( package_www_home, '/' );
        fi;
        pkginfo.PackageWWWHome := package_www_home;

        pkginfo.PackageURLs := Concatenation("""
SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/""", github.username, "/", github.reponame, "\"", """,
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := """, "\"", pkginfo.PackageWWWHome, "\"", """,
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
""");

    else
        if IsBound( answers.PackageWWWHome ) and answers.PackageWWWHome <> "" then
            pkginfo.PackageWWWHome := answers.PackageWWWHome;
        else
            pkginfo.PackageWWWHome := "https://TODO";
        fi;

        if pkginfo.PackageWWWHome[Length( pkginfo.PackageWWWHome )] <> '/' then
            Add( pkginfo.PackageWWWHome, '/' );
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

    if not IsBound( answers.kernel_extension )
       or answers.kernel_extension = ""
       or answers.kernel_extension = fail then
        kernel := fail;
    elif answers.kernel_extension = "C"
         or answers.kernel_extension = "C++" then
        kernel := answers.kernel_extension;
    else
        Error( "kernel_extension must be one of \"\", \"C\", or \"C++\"" );
    fi;

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

    return rec(
        create_repo := create_repo,
        github := github,
        kernel := kernel,
        pkginfo := pkginfo );
end );

BindGlobal( "CreateGitRepository", function(dir, github)
    local path, stdin, stdout, cmd_full, RunGit, remote, tmp;

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

end );

InstallGlobalFunction( PackageWizardGenerate, function( answers )
    local data, pkginfo, create_repo, kernel, github, dir;

    data := NormalizePackageWizardAnswers( answers );
    pkginfo := data.pkginfo;
    create_repo := data.create_repo;
    kernel := data.kernel;
    github := data.github;

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
        CopyTemplate(fail, ".github/workflows/release.yml", pkginfo);
    fi;

    #
    # Phase 3 (optional): Setup a git repository
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
