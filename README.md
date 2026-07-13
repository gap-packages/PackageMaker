[![CI](https://github.com/gap-packages/PackageMaker/actions/workflows/CI.yml/badge.svg)](https://github.com/gap-packages/PackageMaker/actions/workflows/CI.yml)
[![Code Coverage](https://codecov.io/github/gap-packages/PackageMaker/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-packages/PackageMaker)

# PackageMaker

PackageMaker is a [GAP](https://www.gap-system.org/) package that makes
it easy and convenient to create new GAP packages.

It provides an interactive wizard that creates a usable package
skeleton and, depending on your choices, can also set up a git
repository, GitHub workflows, code coverage configuration, and a simple
kernel extension build system.

You can use it as follows:

1. Download PackageMaker and extract it into a GAP `pkg` directory. Or
   just clone its git repository inside the `pkg` directory:

        git clone https://github.com/gap-packages/PackageMaker

   Alternatively you could install PackageMaker using the
   [PackageManager](https://github.com/gap-packages/PackageManager)
   GAP package by entering these commands in GAP:

        LoadPackage("PackageManager");
        InstallPackage("https://github.com/gap-packages/PackageMaker");

2. Start GAP, load the PackageMaker package:

        LoadPackage("PackageMaker");

3. Run the package wizard:

        PackageWizard();

4. Answer the questions about your new package. Afterwards, PackageMaker
   creates a new directory for the new package and populates it with the
   files needed for a basic package skeleton.

   If you also ask PackageMaker to create a git repository, make sure git has
   `user.name` and `user.email` configured. If they are missing, PackageMaker
   will show the commands to run, let you retry, or keep the generated package
   directory without creating a git repository.

5. Edit the generated files, especially `README.md` and `PackageInfo.g`,
   then move the newly created package directory to a suitable place.

> Note: `PackageWizard()` creates the new package in the current directory.
> The recommended long-term location is usually `~/.gap/pkg` (which you may
> have to create first). For quick testing on GAP 4.15 or newer, `gap
> --packagedirs .` can also be useful. See the manual section “Where should
> the generated package go?” for the details and the older-GAP alternatives.

## Manual and next steps

The package manual contains a fuller walkthrough of the wizard, including a
worked transcript, an explanation of the important wizard choices, a tour of
the generated files, and a checklist of what to edit next.

Two practical points are easy to miss:

- `PackageWizard()` creates the new package in the current directory.
- The generated package is only a starting point: it still contains TODO
  text and placeholder values that you should replace before publishing
  or releasing the package.

If you want more background on the purpose of the generated files and on
the meaning of the entries in `PackageInfo.g`, these references are also
useful:

- the GAP manual chapter on ["Using and Developing GAP Packages"](https://docs.gap-system.org/doc/ref/chap76_mj.html).
- the [manual of the `Example`](https://gap-packages.github.io/example/doc/chap0_mj.html)
- the comments in the [`PackageInfo.g` file](https://github.com/gap-packages/example/blob/master/PackageInfo.g)
  of the `Example` package.

## Contact

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/gap-packages/PackageMaker/issues).

You can also contact me directly via [email](mhorn@rptu.de).

## License

PackageMaker is free software you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option) any
later version. For details, see the file `COPYING` distributed as part of
this package or see the FSF's own site.

As a special exception to the terms of the GNU General Public License, you
are granted permission to distribute a package you generated using
PackageMaker under any open source license recognized as such by the
[Open Source Initiative (OSI)](https://opensource.org).
