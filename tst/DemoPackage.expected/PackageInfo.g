#
# DemoPackage: Regression fixture for PackageWizardGenerate
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "DemoPackage",
Subtitle := "Regression fixture for PackageWizardGenerate",
Version := "0.1",
Date := "16/03/2026", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    FirstNames := "Demo",
    LastName := "Maintainer",
    WWWHome := "https://example.invalid/~demo",
    Email := "demo@example.invalid",
    IsAuthor := true,
    IsMaintainer := true,
    PostalAddress := "123 Test Street\n12345 Test City",
    Place := "Test City",
    Institution := "PackageMaker Test Suite",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/demo-user/DemoPackage",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://demo-user.github.io/DemoPackage/",
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "DemoPackage",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Regression fixture for PackageWizardGenerate",
),

Dependencies := rec(
  GAP := ">= 4.13",
  NeededOtherPackages := [ ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));
