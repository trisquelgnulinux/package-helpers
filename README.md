## Introduction

This set of scripts are helpers that modify and compile those packages coming
from the Ubuntu upstream which need it. It might be because they contain
non-free stuff, references to Ubuntu that need to be changed, or because we
want the package to work our way.

This helpers are similar to some of those in the [gNewSense](http://www.gnewsense.org/Builder/HowToCreateourOwnGNULinuxDistribution) builder, we took
some ideas and even some lines from them. If you plan to build an Ubuntu
derivative of your own, we suggest you to use Builder instead of this helpers.

All packages in this list are in the appropriate blacklist in the repository
updater, so they never enter into the repo from upstream and need to be
compiled with this helpers and pushed into reprepro. This helpers also need
to be run by hand - and the results tested - any time the repo watchdog warns
about pending updates from upstream.

To add a package to the list, just copy one - `make-apache2` is a good template -
and rename it to `make-sourcePackageName`. To send the file back to us, or to
include any modification into the current scripts, use `bzr diff` and send
the output as an attachment to trisquel-devel@listas.trisquel.info. You need
to join the mailing list to send messages to it.

## Recommendations

* Take care to use the right sourcePackageName, many source packages produce
several binary packages. `apt-cache showsrc binary-package` can help you.
* If possible, use sed to replace chains in the upstream source without the
need of external files or patches. If you really need to include a file, place
it at the `DATA/sourcePackageName` directory
* Do not replace *all* references to Ubuntu in the package, just those that
would actually be shown to the user. Avoid replacing copyright statements!
* Try to write your replacements in a way they might work in future versions
of the upstream package. Well written regexps and sed will help with that.
* Some of this packages require the lsb to match Trisquel values. Edit the
`/etc/lsb_release` accordingly, or run the helpers in a Trisquel box.
* You can - and maybe should - run this scripts inside a chroot.

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
