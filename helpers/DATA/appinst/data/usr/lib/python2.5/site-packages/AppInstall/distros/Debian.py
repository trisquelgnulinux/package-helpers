import Default

from AppInstall.Menu import SHOW_ALL, SHOW_ONLY_SUPPORTED, SHOW_ONLY_FREE, SHOW_ONLY_MAIN, SHOW_ONLY_PROPRIETARY, SHOW_ONLY_THIRD_PARTY, SHOW_ONLY_INSTALLED

from gettext import gettext as _

class Distribution(Default.Distribution):
    def __init__(self):
        Default.Distribution.__init__(self)
        # Dictonary of all available filters with corresponding choser name
        # and tooltip
        # The installed filter will be automatically added in non-installer mode
        # The primary and secondary filters are separated
        self.filters_primary = {
            SHOW_ALL : (_("All available applications"),
                        _("Show all applications including ones which are "
                          "possibly restricted by law or copyright")),
            SHOW_ONLY_FREE :(_("All Open Source applications"),
                             _("Show all Debian applications which can be "
                               "freely used, modified and distributed. This "
                               "includes a large variety of community "
                               "maintained applications")),
            }
        self.filters_secondary = {
            SHOW_ONLY_THIRD_PARTY : (_("Third party applications"),
                                     _("Show only applications that are "
                                       "provided by independent software "
                                       "vendors and are not part of Debian"))
            } 
        # List of components whose applications should not be installed
        # before asking for a confirmation
        self.components_ask = ["contrib", "non-free"]
        # Dictonary that provides dialog messages that are shown,
        # before a component gets activated or when it requires to be confirmed
        self.components_activation = {
            # Fallback
            None : [_("Enable the installation of software from the %s "
                      "component of Debian?"),
                    # %s is the name of the component
                    _("%s is not officially supported with security "
                      "updates.")],
            "main" : [_("Enable the installaion of officially "
                        "supported Debian software?"),
                      # %s is the name of the application
                      _("%s is part of the Debian main distribution. "
                        "Debian provides support and security "
                        "updates, which will be enabled too.")],
            "contrib" : [_("Enable the installation of partial free software?"),
                          # %s is the name of the application
                          _("%s is not part of the Debian main distribution "
                            "and requires non-free software to work. "
                            "Debian provides support and security "
                            "updates, which will be enabled too.")],
            "non-free" : [_("Enable the installation of non-free software?"),
                          # %s is the name of the application
                          _("The use, modification and distribution of %s "
                            "is restricted by copyright or by legal terms in "
                            "some countries.")]
              }

        self.dependencies_map = [
            # KDE
            (("kdelibs4c2a","python-kde3","libqt3-mt"),
            # %s is the name of an application
             _("%s integrates well into the KDE desktop"), 
             "application-kde"),
            # GNOME
            (("libgnome2-0","python-gnome2","libgtk2.0-0","python-gtk2"),
            # %s is the name of an application
             _("%s integrates well into the GNOME desktop"), 
             "application-gnome"),
            # GNUSTEP
            (("libgnustep-base1.11"),
            # %s is the name of an application
             _("%s integrates well into the Gnustep desktop"), 
             None),
            # XUBUNTU
            (("libxfce4util4",),
            # %s is the name of an application
             _("%s integrates well into the XFCE desktop"),
             None)]

        self.comp_depend_map = { "contrib":["main", "non-free"],
                                 "non-free":["main"]}

    def get_app_emblems(self, app, cache):
        # A short statement about the freedom, legal status and level of
        # support of the application
        emblems = []
        icon_name = None
        tooltip = None

        if app.thirdparty or app.channel:
            tooltip = ("%s is provided by a third party vendor "
                       "and is therefore not an official part "
                       "of Debian. The third party vendor is "
                       "responsible for support and security "
                       "updates.") % app.name

            icon_name = "application-proprietary"
            emblems.append((icon_name, tooltip))
        elif app.component == "main":
            tooltip = _("Debian provides support and "
                        "security updates for %s") % app.name
            icon_name = "application-debian-main"
            emblems.append((icon_name, tooltip))
        elif app.component == "contrib":
            tooltip =_("%s requires non-free software to work."
                        "Debian provides support and "
                        "security updates.") % app.name
            icon_name = "application-debian-contrib"
            emblems.append((icon_name, tooltip))
        elif app.component == "non-free":
            tooltip = _("The use, modification and distribution "
                        "of %s is restricted by copyright or by "
                        "legal terms in some countries. "
                        "Debian provides support and "
                        "security updates.") % app.name
            icon_name = "application-debian-non-free"
            emblems.append((icon_name, tooltip))

        # Add an emblem corresponding to the dependencies of the app
        if cache.has_key(app.pkgname):
            for (deps, tooltip, icon_name) in self.dependencies_map:
                for dep in deps:
                    if cache.pkgDependsOn(app.pkgname, dep):
                        emblems.append((icon_name, tooltip % app.name))
                        break
        return emblems
