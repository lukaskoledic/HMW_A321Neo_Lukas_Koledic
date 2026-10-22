# HMW A321neo Installer

macOS installer for the HoldMyWire A321neo aircraft for X-Plane 12.

## Design

The installer is a thin wrapper. The aircraft payload is **not** bundled - it is
downloaded from the GitHub repository at run time. This keeps the package small
(under 100 KB instead of ~1.8 GB) and means re-running the installer always
delivers the current `main` branch.

| Artifact | Purpose |
|----------|---------|
| `HMW_A321neo_Installer.pkg` | macOS package with a themed welcome screen and background. Installs the app to `/Applications`. |
| `HMW_A321neo_Installer.app` | The installer itself. Can be run standalone. |

## Download strategy

The installer tries three sources in order and uses the first that works:

1. **GitHub Release asset** (preferred) - a published `.zip` release. Smallest
   and fastest. Create a release with a zip of the aircraft tree to enable this.
2. **Branch source tarball** - `codeload.github.com/.../tar.gz/refs/heads/main`.
   A single HTTP request, but the tree is large (~1.8 GB) so it takes a while.
3. **Git clone** - `--depth 1` of the `main` branch. Slowest, but works when
   the archive endpoints are unavailable.

## Update behaviour

Re-running the installer replaces the installed aircraft with the latest
`main` commit. User-specific content is preserved across updates:

- `liveries/`
- `A321_prefs.txt`, aircraft icons
- `plugins/sasl/data/modules/Custom Module/saved_configs/`
- `plugins/sasl/data/modules/configuration/wprefs.ini`

## Requirements

- X-Plane 12 for macOS
- `git` command line tools
- `curl` and `rsync` (both ship with macOS)
- Network access to github.com

## Building

```sh
./installer/build_installer.sh
```

Outputs land in `installer/build/`.

To regenerate the background artwork and app icon:

```sh
python3 installer/tools/make_background.py installer/resources/background.png
```

The icon is produced by rendering a square variant and packaging it with
`iconutil`:

```sh
python3 installer/tools/make_background.py /tmp/icon_src.png   # then resize
iconutil -c icns HMW.iconset -o installer/resources/icon.icns
```

## Repository

`https://github.com/lukaskoledic/HMW_A321Neo_Lukas_Koledic.git` (branch `main`)
