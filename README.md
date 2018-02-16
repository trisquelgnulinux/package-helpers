## Introduction

This set of scripts are helpers that modify and create the source packages coming
from the Ubuntu upstream which need it. It might be because they contain
non-free stuff, references to Ubuntu that need to be changed, or because we
want the package to work our way.

This helpers are similar to some of those in the [gNewSense](http://www.gnewsense.org/Builder/HowToCreateYourOwnGNULinuxDistribution) builder, we took
some ideas and even some lines from them. If you plan to build an Ubuntu
derivative of your own, we suggest you to use Builder instead of this helpers.

Once a new package is added, it takes priority over the original one from Ubuntu,
so they never enter into the repo from upstream and need to be
compiled with this helpers and pushed into reprepro. 

To add a package to the list, follow the [CONTRIBUTING](https://devel.trisquel.info/trisquel/package-helpers/blob/belenos/CONTRIBUTING.md) guidelines.

## Steps

Those are the steps done by the helpers:

1. Create local apt configuration, so you don't need to be root to run the helpers
2. Get the ubuntu and trisquel gpg keys
3. Get the source packages from their original repo
4. Uncompress them
5. Apply the changes described in the helper
6. Re-package it, adding "triquel$VERSION" version string

## Recommendations

* You don't need to use sudo in order to run those scripts, but some extra packages are needed:

     `sudo apt-get install dpkg-dev sed git rpl devscripts quilt patch cdbs`

* Take care to use the right sourcePackageName, many source packages produce
several binary packages. `apt-cache showsrc binary-package` can help you.
* If possible, use sed to replace chains in the upstream source without the
need of external files or patches. If you really need to include a file, place
it at the `DATA/sourcePackageName` directory
* Do not replace *all* references to Ubuntu in the package, just those that
would actually be shown to the user. Avoid replacing copyright statements!
* Try to write your replacements in a way they might work in future versions
of the upstream package. Well written regexps and sed will help with that.
* You can test your changes by doing them inside the _PACKAGES/sourcePackageName/source/_ directory, 
and running `dpkg-source -b .`, before being added to the helper script

## Netinstall

Included are the set of scipts used to generate the network installer images
found in Trisquel GNU/Linux LTS (version 2.0, 4.0, 6.0... and up). The scripts
may not be available for all versions.

To generate the images, we run the following scripts:

* `make-apt-setup`
* `make-base-installer`
* `make-choose-mirror`
* `make-main-menu`
* `make-netcfg`
* `make-net-retriever`
* `make-pkgsel`

Then we push the results into the Trisquel repository and run the script
`make-debian-installer` to build the final images.

