This file describes changes in the PackageMaker package.

## 1.0.2 (2026-07-13)
  - Update the GitHub workflows to latest versions
  - Stop suggesting to add `Keywords` in `PackageInfo.g` (nothing uses them)
  - Require GAP >= 4.13 to use this package

## 1.0.1 (2026-05-09)
  - Copy the `.github/workflows/docs.yml` template workflow
    in newly generated packages (it was there before but we
    forgot to copy it over)
  - Update GitHub workflows to latest versions
  - Change C++ kernel extension code to not set any module state
    related fields: these are mostly needed for HPC-GAP support,
    which is not something most package authors will be interested
    in at this point.

## 1.0.0 (2026-03-24)
  - First public release
