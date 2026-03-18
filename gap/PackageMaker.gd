#
# PackageMaker - a GAP package for creating GAP packages
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

#! @Chapter PackageMaker

#! @Section What is &PackageMaker;?
#! &PackageMaker; is a &GAP; package that makes it easy to create
#! new &GAP; packages, by providing a <Q>wizard</Q> function that
#! asks a few questions about the new package, such as its name
#! and authors; and from that creates a complete usable skeleton
#! package. It optionally can set up several advanced features,
#! including:
#! - a git repository for use on GitHub;
#! - a simple C or C++ kernel extension, including a build system;
#! - continuous integration and release automation using GitHub Actions;
#! - code coverage tracking;
#! - ... and more.
#!
#! The generated package is meant as a starting point, not as a finished
#! package ready for release. In particular, you should expect to edit
#! <F>README.md</F>, <F>PackageInfo.g</F>, the generated tests and,
#! depending on your choices, the documentation, CI workflows or kernel
#! extension sources.

#! @Section Before you start
#! A typical session looks like this:
#! - start &GAP; in a directory where it is OK to create a new package
#!   directory;
#! - load &PackageMaker; and run <C>PackageWizard()</C>;
#! - answer the wizard questions;
#! - inspect and edit the generated files;
#! - move the package to a directory in which &GAP; looks for packages,
#!   or run &GAP; with <C>--packagedirs</C>.
#!
#! By default, the wizard creates the new package directory in the current
#! working directory of your &GAP; session. That is often convenient for
#! creating the package, but it does not automatically make the package
#! loadable. See the next section for the different ways to make &GAP; find
#! the generated package.
#!
#! If you ask &PackageMaker; to create a git repository, git should have
#! <C>user.name</C> and <C>user.email</C> configured. If they are missing,
#! &PackageMaker; explains how to set them up, lets you retry, or keeps the
#! generated package directory without creating a git repository.
#!
#! @Section Where should the generated package go?
#! The generated package directory must eventually live in a place where
#! &GAP; searches for packages.
#!
#! For normal day-to-day use, the best destination is usually
#! <F>~/.gap/pkg</F>. You may have to create that directory first. Keeping
#! personal packages there means they survive &GAP; upgrades and are separate
#! from the main &GAP; installation.
#!
#! Another natural choice is the <F>pkg</F> directory inside your main
#! &GAP; installation. This is common when you built &GAP; from source in a
#! directory that you control. The drawback is that when you later upgrade
#! or reinstall &GAP;, it is easy to forget to copy over packages that you
#! added there manually.
#!
#! For quick testing, &GAP; 4.15 or later can be started with
#! <C>gap --packagedirs .</C> to tell &GAP; to search the current directory
#! directly for packages.
#!
#! There are also more advanced alternatives:
#! - command line options such as <C>-l</C> (see <Ref Sect="Command Line Options" BookName="ref"/>)
#!   can change the configured &GAP; root directories (see <Ref Sect="GAP Root Directories" BookName="ref"/>)
#!   when starting &GAP;;
#! - <Ref Func="ExtendRootDirectories" BookName="ref"/> and
#!   <Ref Func="ExtendPackageDirectories" BookName="ref"/> can add
#!   package search locations after &GAP; has already started;
#! - <Ref Func="SetPackagePath" BookName="ref"/> can be useful when you want to force loading one
#!   particular package from a specific path for a session.
#!
#! These advanced options are useful to know about, but for most users the
#! practical advice is simple: keep the package in <F>~/.gap/pkg</F> for
#! normal use, and use <C>gap --packagedirs .</C> only as a quick-testing
#! convenience when running &GAP; 4.15 or newer.

#! @Section A worked example
#! The following transcript shows a complete example session. It uses
#! GitHub, enables the generated workflows, chooses the MIT license, creates
#! a C kernel extension, and enters one author / maintainer record.
#!
#! @Description
#! Interactively create a package skeleton. You can abort by either
#! answering <Q>quit</Q> or pressing <C>Ctrl-D</C>.
#!
#! @BeginLogSession
#! gap> PackageWizard();
#! Welcome to the GAP PackageMaker Wizard.
#! I will now guide you step-by-step through the package
#! creation process by asking you some questions.
#!
#! What is the name of the package? DemoPackage
#! Enter a short (one sentence) description of your package: A package used to demonstrate PackageMaker
#! Which license should the package use? MIT
#! Shall I prepare your new package for GitHub? [Y/n] y
#! Do you want to use GitHub Actions for automated tests and making releases? [Y/n] y
#! The release workflow updates the package website on GitHub Pages
#! whenever you make a package release.
#! I need to know the URL of the GitHub repository.
#! It is of the form https://github.com/USER/REPOS.
#! What is USER (typically your GitHub username)? demo-user
#! What is REPOS, the repository name? DemoPackage
#! Shall your package provide a GAP kernel extension? Yes, written in C
#!
#! Next I will ask you about the package authors and maintainers.
#!
#! Last name? Doe
#! First name(s)? Dana
#! Is this one of the package authors? [Y/n] y
#! Is this a package maintainer? [Y/n] y
#! Email? dana@example.invalid
#! WWWHome? https://example.invalid/~dana/
#! GitHubUsername? demo-user
#! PostalAddress? Example Institute\nDepartment of Algebra\nExample Street 1\n12345 Example City
#! Place? Example City, Country
#! Institution? Example Institute
#! Add another person? [y/N] n
#! Creating the git repository...
#! Initialized empty Git repository in .../DemoPackage/.git/
#! [main (root-commit) ...] initial import
#! Done creating git repository.
#! Create <https://github.com/demo-user/DemoPackage> via <https://github.com/new> and then run:
#!   git push -u origin main
#! @EndLogSession
#!
#! After this finishes, the new package lives in a directory named
#! <F>DemoPackage</F> below the current directory. You can now inspect and
#! edit the generated files, move the package into a package directory, and
#! try loading it in &GAP;.
DeclareGlobalFunction( "PackageWizardInput" );
DeclareGlobalFunction( "PackageWizardGenerate" );
DeclareGlobalFunction( "PackageWizard" );

#! @Section Important wizard choices
#! Some answers mainly affect metadata, while others determine which files
#! are generated.
#!
#! @Subsection Package name
#! The package name becomes the name of the top-level package directory and is
#! also used in file names such as <F>gap/YourPackage.gd</F>,
#! <F>gap/YourPackage.gi</F> and in many entries of <F>PackageInfo.g</F>.
#! It therefore should be chosen with care.
#!
#! @Subsection License
#! The license choice affects both the generated <F>LICENSE</F> file and the
#! guidance inserted into <F>README.md</F>. By default, the wizard uses
#! <C>GPL-2.0-or-later</C>, because that is the license of &GAP; itself and is
#! also used by many &GAP; packages. Other built-in choices are
#! <C>GPL-3.0-or-later</C>, <C>MIT</C> and <C>BSD-3-Clause</C>.
#!
#! If you are unsure which license to use, then the following sites may help:
#! - <URL>https://choosealicense.com/</URL>
#! - <URL>https://opensource.org/licenses/</URL>
#! - <URL>https://spdx.org/licenses/</URL>
#!
#! If you choose the custom option, then &PackageMaker; generates a
#! placeholder <F>LICENSE</F> file which you must replace with the full text
#! of your chosen license. You should also make sure that the
#! <C>License</C> field in <F>PackageInfo.g</F> and the package
#! <F>README.md</F> describe the same license.
#!
#! @Subsection GiHub setup
#! Saying yes to GitHub setup does two things:
#! - it fills in repository-related URLs in <F>PackageInfo.g</F>;
#! - it offers to create a local git repository with an initial commit and a
#!   GitHub remote named <C>origin</C>.
#!
#! If you also enable GitHub Actions, then &PackageMaker; adds CI and release
#! workflows below <F>.github/workflows/</F> and creates <F>.codecov.yml</F>.
#! The release workflow updates the package website on GitHub Pages when you
#! make a release.
#!
#! If you do not use GitHub setup, then <F>PackageInfo.g</F> contains
#! placeholder URL entries instead. They work as reminders, but you should
#! replace them before publishing your package.
#!
#! @Subsection Kernel extension
#! The kernel extension choice determines whether the package is purely
#! interpreted &GAP; code or also contains code in <C>C</C> or <C>C++</C>.
#! Choosing a kernel extension adds files such as <F>src/YourPackage.c</F> or
#! <F>src/YourPackage.cc</F>, together with <F>configure</F>,
#! <F>Makefile.in</F> and <F>Makefile.gappkg</F>.

#! @Section What gets generated?
#! Every generated package contains the basic files needed for a small but
#! usable package:
#! - <F>PackageInfo.g</F> with the package metadata;
#! - <F>README.md</F> with placeholder text to replace;
#! - <F>init.g</F> and <F>read.g</F>;
#! - <F>gap/YourPackage.gd</F> and <F>gap/YourPackage.gi</F>;
#! - <F>makedoc.g</F> for building the package manual;
#! - <F>tst/testall.g</F> as a starting point for tests;
#! - <F>LICENSE</F>.
#!
#! Depending on your choices, the wizard may also create:
#! - <F>.gitattributes</F> and <F>.gitignore</F> when GitHub setup is enabled;
#! - <F>.github/workflows/CI.yml</F>, <F>.github/workflows/release.yml</F>
#!   and <F>.codecov.yml</F> when GitHub Actions are enabled;
#! - <F>src/</F>, <F>configure</F>, <F>Makefile.in</F> and
#!   <F>Makefile.gappkg</F> when a kernel extension is requested.
#!
#! A few of these files deserve immediate attention:
#! - <F>README.md</F> still contains TODO text and should be rewritten;
#! - <F>PackageInfo.g</F> should be checked carefully, especially the package
#!   URLs, description, authors and maintainers;
#! - <F>tst/testall.g</F> is only the test driver, so you will usually want to
#!   add actual <C>.tst</C> files;
#! - the generated <F>gap/</F> and optional <F>src/</F> files are only a
#!   starting skeleton and should be adapted to your package.

#! @Section What next?
#! Once the wizard has finished, a typical next-step checklist is:
#! - decide where the package should live, as explained in
#!   <Ref Label="Chapter_PackageMaker_Section_Where_should_the_generated_package_go?"/>;
#! - edit <F>README.md</F> and replace the TODO sections;
#! - review <F>PackageInfo.g</F> and fix any remaining placeholder values;
#! - if you selected the custom license option, replace the placeholder
#!   <F>LICENSE</F> text with the full license text;
#! - add package code and tests;
#! - run the package inside &GAP; and make sure it loads;
#! - if you asked for a kernel extension, run <C>./configure</C> and build it;
#! - if you enabled GitHub setup, create the GitHub repository and push the
#!   generated initial commit.
#!
#! For broader guidance on package structure and release preparation, it is
#! worth reading the &GAP; manual chapter on
#! <Ref Chap="Using and Developing GAP Packages" BookName="ref"/> as well as
#! the manual and <F>PackageInfo.g</F> file of the
#! <URL>https://github.com/gap-packages/example</URL> package.
