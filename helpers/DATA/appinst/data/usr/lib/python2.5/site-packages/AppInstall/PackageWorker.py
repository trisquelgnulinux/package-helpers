# (c) 2005-2007 Canonical, GPL

import apt_pkg
import subprocess
import gtk
import gtk.gdk
import thread
import time
import os
import tempfile
from gettext import gettext as _

class PackageWorker:
    """
    A class which does the actual package installing/removing.
    """

    # synaptic actions
    (INSTALL, UPDATE) = range(2)

    def __init__(self, addon_cd=None):
        self.addon_cd=addon_cd
    
    def run_synaptic(self, id, lock, to_add=None,to_rm=None, action=INSTALL):
        #apt_pkg.PkgSystemUnLock()
        #print "run_synaptic(%s,%s,%s)" % (id, lock, selections)
        cmd = []
        if os.getuid() != 0:
            cmd = ["/usr/bin/gksu",
                   "--desktop", "/usr/share/applications/synaptic.desktop",
                   "--"]
        cmd += ["/usr/sbin/synaptic",
                "--hide-main-window",
                "--non-interactive",
                "-o", "Synaptic::closeZvt=true",
                "--parent-window-id", "%s" % (id) ]

        # create tempfile for install (here because it must survive
        # durng the synaptic call
        f = tempfile.NamedTemporaryFile()
        if action == self.INSTALL:
            # setup the cdrom 
            if self.addon_cd:
                cmd += ["-o","Acquire::cdrom::mount=%s" % self.addon_cd]
            # install the stuff
            for item in to_add:
                f.write("%s\tinstall\n" % item)
                #print item.pkgname
            for item in to_rm:
                f.write("%s\tuninstall\n" % item)
            cmd.append("--set-selections-file")
            cmd.append("%s" % f.name)
            f.flush()
        elif action == self.UPDATE:
            #print "Updating..."
            cmd.append("--update-at-startup")
        self.return_code = subprocess.call(cmd)
        lock.release()
        f.close()

    def plug_removed(self, w, (win,socket)):
        # plug was removed, but we don't want to get it removed, only hiden
        # unti we get more
        win.hide()
        return True

    def plug_added(self, sock, win):
        while gtk.events_pending():
            win.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
            win.show()
            #print "huhu"
            gtk.main_iteration()

    def get_plugged_win(self, window_main):
        win = gtk.Window()
        win.realize()
        win.window.set_functions(gtk.gdk.FUNC_MOVE)
        win.set_border_width(6)
        win.set_transient_for(window_main)
        win.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
        win.set_title("")
        win.set_resizable(False)
        win.set_property("skip-taskbar-hint", True)
        win.set_property("skip-taskbar-hint", True)
        # prevent the window from closing with the delete button (there is
        # a cancel button in the window)
        win.connect("delete_event", lambda e,w: True);
    
        # create the socket
        socket = gtk.Socket()
        socket.show()
        win.add(socket)
        
        socket.connect("plug-added", self.plug_added, win)
        socket.connect("plug-removed", self.plug_removed, (win,socket))

        
        return win, socket
    
    def perform_action(self, window_main, cache, to_add=None, to_rm=None, action=INSTALL):
        window_main.set_sensitive(False)
        window_main.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.WATCH))
        lock = thread.allocate_lock()
        lock.acquire()
        t = thread.start_new_thread(self.run_synaptic,(window_main.window.xid,lock,to_add, to_rm, action))
        while lock.locked():
            while gtk.events_pending():
                gtk.main_iteration()
            time.sleep(0.05)
        window_main.set_sensitive(True)
        window_main.window.set_cursor(None)
        return self.return_code
