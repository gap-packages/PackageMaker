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
#! asks a few questions about the new packages, such as its name
#! and authors; and from that creates a complete usable skeleton
#! packages. It optionally can set up several advanced features,
#! including:
#! - a git repository for use on GitHub;
#! - a simple C or C++ kernel extension, including a build system;
#! - continuous integration and release automation using GitHub Actions;
#! - code coverage tracking;
#! - ... and more.
#!
#!

#! @Section How does one use &PackageMaker;?
#! Simply load it, then invoke <C>PackageWizard()</C> and follow
#! the instructions. If you ask &PackageMaker; to create a git
#! repository, git must have <C>user.name</C> and <C>user.email</C>
#! configured. If they are missing, &PackageMaker; explains how to
#! set them up, lets you retry, or keeps the generated package
#! directory without creating a git repository.

#! @Description
#! Interactively create a package skeleton. You can abort by either
#! answering <Q>quit</Q> or pressing <C>Ctrl-D</C>
#!
#! @BeginLogSession
#! gap> PackageWizard();
#! Welcome to the GAP PackageMaker Wizard.
#! I will now guide you step-by-step through the package
#! creation process by asking you some questions.
#!
#! What is the name of the package? SuperPackage
#! Enter a short (one sentence) description of your package: A super nice new package
#! Shall I prepare your new package for GitHub? [Y/n] y
#! Do you want to use GitHub Actions for automated tests and making releases? [Y/n] y
#! The release workflow updates the package website on GitHub Pages
#! whenever you make a package release.
#! I need to know the URL of the GitHub repository.
#! It is of the form https://github.com/USER/REPOS.
#! What is USER (typically your GitHub username)? [mhorn]
#! ...
#! @EndLogSession
DeclareGlobalFunction( "PackageWizardInput" );
DeclareGlobalFunction( "PackageWizardGenerate" );
DeclareGlobalFunction( "PackageWizard" );

#! @Section What next?
#! If you enabled the GitHub Actions workflows then package releases will
#! also update the package website on GitHub Pages. &PackageMaker; used to
#! create a local <C>gh-pages</C> checkout for this, but that is no longer
#! necessary.
#! 
#! Some suggestions for what to do next:
#! - edit the <F>README.md</F> file of your new package
#! - add some actual functionality to it
#! - if you asked for a kernel extension, try to compile it
#! - try loading your package
#! - add some `.tst` test files
#! - ...
