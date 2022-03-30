#!/usr/bin/python3


# nice apt-get -s -o Debug::NoLocking=true upgrade | grep ^Inst

import apt
import apt_pkg
import os
import sys
from optparse import OptionParser
import re
import gettext
import distro_info
import subprocess


SYNAPTIC_PINFILE = "/var/lib/synaptic/preferences"
OS_RELEASE_PATH = "/etc/os-release"


def _get_info_from_os_release(key):
    " get info directly from os-release file "
    if os.path.exists(OS_RELEASE_PATH):
        with open(OS_RELEASE_PATH) as f:
            search_res = re.search(
                r"{}=(?P<name>.*)".format(key),
                f.read()
            )
            if search_res:
                return search_res.group("name")
            else:
                raise Exception(
                    "Could not find {} in {}".format(
                        key, OS_RELEASE_PATH
                    )
                )
    else:
        raise Exception(
            "File {} was not found on the system".format(
                OS_RELEASE_PATH
            )
        )


def _get_output_from_lsb_release(lsb_option):
    " get info from lsb_release output "
    return subprocess.check_output(
        ["lsb_release", lsb_option, "-s"], universal_newlines=True
    ).strip()


def get_distro():
    " get distro name "
    try:
        return _get_info_from_os_release(key="UBUNTU_CODENAME")
    except Exception:
        # If the system does not have os-release file or does not have the
        # required entry in it, we will get the distro name from lsb_release
        # command
        return _get_output_from_lsb_release("-c")


DISTRO = get_distro()

def _(msg):
    return gettext.dgettext("update-notifier", msg)


def _handleException(type, value, tb):
    sys.stderr.write("E: " + _("Unknown Error: '%s' (%s)") % (type, value))
    sys.exit(-1)


def get_distro_version():
    " get distro version "
    try:
        return _get_info_from_os_release(key="VERSION_ID").replace('"', "")
    except Exception:
        # If the system does not have os-release file or does not have the
        # required entry in it, we will get the distro name from lsb_release
        # command
        return _get_output_from_lsb_release("-r")


def clean(cache, depcache):
    " unmark (clean) all changes from the given depcache "
    # mvo: looping is too inefficient with the new auto-mark code
    # for pkg in cache.Packages:
    #     depcache.MarkKeep(pkg)
    depcache.init()


def saveDistUpgrade(cache, depcache):
    """ this function mimics a upgrade but will never remove anything """
    depcache.upgrade(True)
    if depcache.del_count > 0:
        clean(cache, depcache)
    depcache.upgrade()


def isSecurityUpgrade(ver):
    " check if the given version is a security update (or masks one) "
    security_pockets = [("Ubuntu", "%s-security" % DISTRO),
                        ("gNewSense", "%s-security" % DISTRO),
                        ("Debian", "%s-updates" % DISTRO)]
    for (file, index) in ver.file_list:
        for origin, archive in security_pockets:
            if (file.archive == archive and file.origin == origin):
                return True
    return False

def write_package_names(outstream, cache, depcache):
    " write out package names that change to outstream "
    pkgs = [pkg for pkg in cache.packages if depcache.marked_install(pkg)
            or depcache.marked_upgrade(pkg)]
    outstream.write("\n".join([p.name for p in pkgs]))


def is_lts_distro():
    " check if the current distro is LTS or not"
    return distro_info.TrisquelDistroInfo().is_lts(DISTRO)


def write_human_readable_summary(outstream, upgrades, security_updates):
    " write out human summary to outstream "
    lts_distro = is_lts_distro()

    outstream.write(
        gettext.dngettext("update-notifier",
                          "%i update can be applied immediately.",
                          "%i updates can be applied immediately.",
                          upgrades) % upgrades
    )

    if security_updates > 0:
        outstream.write("\n")
        outstream.write(gettext.dngettext("update-notifier",
                                          "%i of these updates is a "
                                          "standard security update.",
                                          "%i of these updates are "
                                          "standard security updates.",
                                          security_updates) %
                        security_updates)


def init():
    " init the system, be nice "
    # FIXME: do a ionice here too?
    os.nice(19)
    apt_pkg.init()


def run(options=None):

    # we are run in "are security updates installed automatically?"
    # question mode
    if options.security_updates_unattended:
        res = apt_pkg.config.find_i("APT::Periodic::Unattended-Upgrade", 0)
        # print(res)
        sys.exit(res)

    # get caches
    try:
        cache = apt_pkg.Cache(apt.progress.base.OpProgress())
    except SystemError as e:
        sys.stderr.write("E: " + _("Error: Opening the cache (%s)") % e)
        sys.exit(-1)
    depcache = apt_pkg.DepCache(cache)

    # read the synaptic pins too
    if os.path.exists(SYNAPTIC_PINFILE):
        depcache.read_pinfile(SYNAPTIC_PINFILE)
        depcache.init()

    if depcache.broken_count > 0:
        sys.stderr.write("E: " + _("Error: BrokenCount > 0"))
        sys.exit(-1)

    # do the upgrade (not dist-upgrade!)
    try:
        saveDistUpgrade(cache, depcache)
    except SystemError as e:
        sys.stderr.write("E: " + _("Error: Marking the upgrade (%s)") % e)
        sys.exit(-1)


    # analyze the ugprade
    upgrades = 0
    security_updates = 0

    # we need another cache that has more pkg details
    with apt.Cache() as aptcache:
        for pkg in cache.packages:

            # skip packages that are not marked upgraded/installed
            if not (depcache.marked_install(pkg)
                    or depcache.marked_upgrade(pkg)):
                continue
            # check if this is really a upgrade or a false positive
            # (workaround for ubuntu #7907)
            inst_ver = pkg.current_ver
            cand_ver = depcache.get_candidate_ver(pkg)
            if cand_ver == inst_ver:
                continue
            # check for security upgrades
            if isSecurityUpgrade(cand_ver):
                security_updates += 1

                upgrades += 1
                continue

            # check to see if the update is a phased one
            try:
                from UpdateManager.Core.UpdateList import UpdateList
                ul = UpdateList(None)
                ignored = ul._is_ignored_phased_update(
                    aptcache[pkg.get_fullname()])
                if ignored:
                    depcache.mark_keep(pkg)
                    continue
            except ImportError:
                pass

            upgrades = upgrades + 1

            # now check for security updates that are masked by a
            # candidate version from another repo (-proposed or -updates)
            for ver in pkg.version_list:
                if (inst_ver
                        and apt_pkg.version_compare(ver.ver_str,
                                                    inst_ver.ver_str) <= 0):
                    continue
                if isSecurityUpgrade(ver):
                    security_updates += 1
                    break

    # print the number of upgrades
    if options and options.show_package_names:
        write_package_names(sys.stderr, cache, depcache)
    elif options and options.readable_output:
        write_human_readable_summary(sys.stdout, upgrades, security_updates)
    else:
        # print the number of regular upgrades and the number of
        # security upgrades
        sys.stderr.write("%s;%s" % (upgrades, security_updates))

    # return the number of upgrades (if its used as a module)
    return(upgrades, security_updates)


if __name__ == "__main__":
    # setup a exception handler to make sure that uncaught stuff goes
    # to the notifier
    sys.excepthook = _handleException

    # gettext
    APP = "update-notifier"
    DIR = "/usr/share/locale"
    gettext.bindtextdomain(APP, DIR)
    gettext.textdomain(APP)

    # check arguments
    parser = OptionParser()
    parser.add_option("-p",
                      "--package-names",
                      action="store_true",
                      dest="show_package_names",
                      help=_("Show the packages that are "
                             "going to be installed/upgraded"))
    parser.add_option("",
                      "--human-readable",
                      action="store_true",
                      dest="readable_output",
                      help=_("Show human readable output on stdout"))
    parser.add_option("",
                      "--security-updates-unattended",
                      action="store_true",
                      help=_("Return the time in days when security updates "
                             "are installed unattended (0 means disabled)"))
    (options, args) = parser.parse_args()

    # run it
    init()
    run(options)

