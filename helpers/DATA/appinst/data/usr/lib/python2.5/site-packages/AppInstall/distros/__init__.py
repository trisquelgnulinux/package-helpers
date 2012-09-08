# DERIVATES: Please provide your own distro class and patch this statement
from Ubuntu import Distribution

def get_distro():
    """
    Returns a distribution class instance that contains information and methods
    corresponding to the used distribution
    """
    distro = Distribution()
    return distro

def get_lsb_info():
    """
    Returns the LSB information in a tuple:
     - ID
     - Codename
     - Description
     - Release
    """
    lsb_info = ()
    for lsb_option in ["-i", "-c", "-d", "-r"]:
        pipe = os.popen("lsb_release %s -s" % lsb_option)
        lsb_info.append(pipe.read().strip())
        del pipe
    return(lsb_info)

