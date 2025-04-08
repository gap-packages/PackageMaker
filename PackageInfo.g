#
# PackageMaker: A GAP package for creating new GAP packages
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "PackageMaker",
Subtitle := "A GAP package for creating new GAP packages",
Version := "0.10.0",
Date := "20/11/2024", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Max",
    LastName := "Horn",
    Email := "mhorn@rptu.de",
    WWWHome := "https://www.quendi.de/math",
    PostalAddress := Concatenation(
               "Fachbereich Mathematik\n",
               "RPTU Kaiserslautern-Landau\n",
               "Gottlieb-Daimler-Straße 48\n",
               "67663 Kaiserslautern\n",
               "Germany" ),
    Place := "Kaiserslautern, Germany",
    Institution := "RPTU Kaiserslautern-Landau",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-system/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := Concatenation( "https://gap-system.github.io/", ~.PackageName ),
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
ArchiveFormats := ".tar.gz",

Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "PackageMaker",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A GAP package for creating new GAP packages",
),

Dependencies := rec(
  GAP := ">= 4.9",
  NeededOtherPackages := [
      [ "AutoDoc", ">= 2018.02.14" ],
      [ "io", ">= 3.0" ],       # for IO_gettimeofday
    ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

));
