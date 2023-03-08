# ReMarkable Unsplash

Simple script to update the suspended screen with a random image from
Unsplash[^unsplash].

[Demonstrational video](https://user-images.githubusercontent.com/807772/223706670-a83d7265-6cc8-46e1-b893-a0f2545a2f90.mp4)

## What does this do?

The script will first check if a backup of the suspended image exists, and if
not will create one.

Next, the script will download a random image from Unsplash and process it with
ImageMagick. By default, it will overlay an inverted version of the original
suspended image on top of the new one so it still says "ReMarkable is sleeping."
The resulting image is then installed as the new suspended image.

Many of the aspects are configurable, including the full source URL so you can
use any web server URL you want, whether and how it does the overlaying of the
original image, etc. Check the Configuration section for all configurable
values.

## Known caveats

The script takes a minute to run on default settings due to its use of
ImageMagick for processing. This is fine for the intended use-case of running
this in the background at a schedule. But you can choose to disable certain
processing features (see Configuration section, specifically
`SUSPENDED_COMPOSE`, `SUSPENDED_DITHER` and `SUSPENDED_REMAP_PALETTE`).

The script also currently prints a warning `RGB color space not permitted on
grayscale PNG` which can be ignored. This will be fixed later.

## Configuration

The script will check for a configuration file `config.env` which is loaded as a
shell script. It is expected to set values with the `KEY=VALUE` syntax.

The `config.env` file can be placed into the current working directory (usually
the path where you are executing the script). It will additionally search in
`../etc/remarkable-unsplash/config.env` relative to the script's location to
ease configuration in package manager-based installations such as Toltec.

The configuration file which can contain the following values:

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
| `SUSPENDED_COMPOSE`           | `1`                                                                         | Whether to overlay the original suspended image on top of the Unsplash one. You may prefer to reduce the CPU usage/runtime of this script by setting this to `0`.                                  |
| `SUSPENDED_COMPOSITE_METHOD`  | `lighten`                                                                   | Which compositing method to use for layering the original suspend image on top of the Unsplash one. See the ImageMagick documentation for more info.[^compose]                                     |

[^unsplash]: https://unsplash.com
[^compose]: https://imagemagick.org/script/command-line-options.php?#compose
