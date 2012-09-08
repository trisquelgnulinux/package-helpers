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
                        _("Show all applications including ones "
                          "which are possibly restricted by law or "
                          "copyright, unsupported by Trisquel or "
                          "not part of Trisquel")),
            SHOW_ONLY_FREE : (_("All Open Source applications"),
                              _("Show all Trisquel applications which can be "
                                "freely used, modified and distributed. This "
                                "includes a large variety of community "
                                "maintained applications"))
            }
        self.filters_secondary = {
            SHOW_ONLY_SUPPORTED : (_("Supported applications"),
                                   _("Show only applications which come with "
                                     "full technical and security support by "
                                     "Trisquel")),
            SHOW_ONLY_THIRD_PARTY :(_("Third party applications"),
                                    _("Show only applications that are "
                                      "provided by independent software vendors"
                                      " and are not part of Trisquel"))
            }
        # List of components whose applications should not be installed
        # before asking for a confirmation
        self.components_ask = ["universe", "multiverse"]
        # Dictonary that provides dialog messages that are shown,
        # before a component gets activated or when it requires to be confirmed
        self.components_activation = {
            # Fallback
            None : [_("Enable the installation of software from the %s "
                      "component of Trisquel?"),
                    # %s is the name of the component
                    _("%s is not officially supported with security "
                      "updates.")],
            "main" : [_("Enable the installaion of officially "
                        "supported Trisquel software?"),
                      # %s is the name of the application
                      _("%s is part of the Trisquel main distribution. "
                        "Trisquel provides support and security "
                        "updates, which will be enabled too.")],
            "universe" : [_("Enable the installation of community maintained "
                            "software?"),
                          # %s is the name of the application
                          _("%s is maintained by the Trisquel community. "
                            "The Trisquel community provides support and "
                            "security updates, which will be enabled too.")],
            "multiverse" : [_("Enable the installation of unsupported and "
                              "restricted software?"),
                            # %s is the name of the application
                            _("The use, modification and distribution of %s "
                              "is restricted by copyright or by legal terms in "
                              "some countries.")]
              }

        self.dependencies_map = [
            # KDE
            (("kdelibs4c2a","python-kde3","libqt3-mt"),
            # %s is the name of an application
             None,
             "application-kde"),
            # GNOME
            (("libgnome2-0","python-gnome2","libgtk2.0-0","python-gtk2"),
            # %s is the name of an application
             None, 
             "application-gnome"),
            # XUBUNTU
            # FIXME: get an icon from xubuntu
            (("libxfce4util4",),
            # %s is the name of an application
             None,
             None)]

        self.comp_depend_map = { "universe":["main"],
                                 "multiverse":["main", "universe"]}

    def get_app_emblems(self, app, cache):
        # A short statement about the freedom, legal status and level of
        # support of the application
        emblems = []
        icon_name = None
        tooltip = None
        if app.channel.endswith("-partner") and app.supported:
            tooltip = _("%s is provided by a third party vendor "
                        "from the Trisquel partner repository.") % app.name
            icon_name = "application-partner"
            emblems.append((icon_name, tooltip))
        elif app.component == "main" or app.supported:
            tooltip = _("Trisquel provides technical support and "
                        "security updates for %s") % app.name
            icon_name = "application-supported"
            emblems.append((icon_name, tooltip))
        elif app.thirdparty or app.channel:
            tooltip = ("%s is provided by a third party vendor "
                       "and is therefore not an official part "
                       "of Trisquel. The third party vendor is "
                       "responsible for support and security "
                       "updates.") % app.name
            icon_name = "application-proprietary"
            emblems.append((icon_name, tooltip))
        if app.component == "universe":
            tooltip =_("This application is provided by the "
                       "Trisquel community.")
            icon_name = "application-community"
            emblems.append((icon_name, tooltip))
        if app.component == "multiverse" or app.thirdparty:
            tooltip = _("The use, modification and distribution "
                        "of %s is restricted by copyright or by "
                        "legal terms in some countries.") % app.name
            icon_name = "application-proprietary"
            emblems.append((icon_name, tooltip))

        # Add an emblem corresponding to the dependencies of the app
        if cache.has_key(app.pkgname):
            for (deps, tooltip, icon_name) in self.dependencies_map:
                for dep in deps:
                    if cache.pkgDependsOn(app.pkgname, dep):
                        if type(tooltip) == str:
                            tooltip = tooltip % app.name
                        emblems.append((icon_name, tooltip))
                        break
        tooltip = None
        return emblems
