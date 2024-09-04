# trisquel-wallpapers
This folder centralize on the package-helpers repo the final wallpaper for
the release.

The final artwork should come from trisquel-packages/$VERSION/trisquel-wallpapers
repository, make sure to review helper on the designed stage prior to
release, so it uses right artwork when released.

This should be copied with something like this:

```
cp $(find DATA/trisquel-wallpapers/ -name $CODENAME.*) \
    warty-final-ubuntukylin.jpg
```

Helpers using this image should be identified using the tag:

* `#STAGE-5-DESKTOP|ARTWORK`

To ease identification.

## Final wallpaper format
Please note that the final wallpaper artwork file could be in JPG or PNG
form (or any other format), make sure to make the necessary test to confirm
that the format specific file is not an issue on your desired package helper
use.
