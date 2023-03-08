# ReMarkable Unsplash

Simple script to update the suspended screen with a random image from
Unsplash[^unsplash].

## Configuration

The script will check for a file `etc/remarkable-unsplash/config.env` which can contain the following values:

| Name                          | Default                                                                     | Description                                                                                                                                                                                        |
| ----------------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `UNSPLASH_KEYWORDS`           | `abstract,grayscale`                                                        | Tags to pass to Unsplash for random image download.                                                                                                                                                |
| `UNSPLASH_SIZE`               | `1404x1872`                                                                 | Preferred image size to pass to Unsplash.                                                                                                                                                          |
| `UNSPLASH_URL`                | `https://source.unsplash.com/random/${UNSPLASH_SIZE}/?${UNSPLASH_KEYWORDS}` | The full URL to the image to download. Override this if you consider an alternative source.                                                                                                        |
| `SUSPENDED_AUTO_BACKUP`       | `1`                                                                         | Whether to automatically back up the original suspended image if no backup exists.                                                                                                                 |
| `SUSPENDED_IMAGE_PATH`        | `/usr/share/remarkable/suspended.png`                                       | The path to the suspended image to replace.                                                                                                                                                        |
| `SUSPENDED_BACKUP_IMAGE_PATH` | `$(dirname "${SUSPENDED_IMAGE_PATH}")/suspended.backup.png`                 | The path where the original suspended image is backed up to or expected to be backed up to. The path is also used to overlay the original image on top of the new one.                             |
| `SUSPENDED_TEMP_IMAGE_PATH`   | `$(dirname "${SUSPENDED_IMAGE_PATH}")/suspended.new.png`                    | The path where the script will temporarily write the processed image to.                                                                                                                           |
| `SUSPENDED_DITHER`            | `1`                                                                         | Whether to apply dithering during image processing through ImageMagick. This is computationally expensive so if you prefer to reduce the CPU usage/runtime of this script you can set this to `0`. |
| `SUSPENDED_REMAP_PALETTE`     | `1`                                                                         | Whether to remap the image palette during image processing. You may prefer to reduce the CPU usage/runtime of this script by setting this to `0`.                                                  |
| `SUSPENDED_COMPOSITE_METHOD`  | `lighten`                                                                   | Which compositing method to use for layering the original suspend image on top of the Unsplash one. See the ImageMagick documentation for more info.[^compose]                                     |

[^unsplash]: https://unsplash.com
[^compose]: https://imagemagick.org/script/command-line-options.php?#compose
