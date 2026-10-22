#!/bin/zsh
set -euo pipefail

xplane_root="${XPLANE_ROOT:-/Users/lukas/X-Plane 12}"
xplane_binary="${XPLANE_BINARY:-$xplane_root/X-Plane.app/Contents/MacOS/X-Plane}"
compat_path="$xplane_root/Resources/default scenery/default apt dat/Earth nav data/apt.dat"
compat_target="$xplane_root/Global Scenery/Global Airports/Earth nav data/apt.dat"

if [[ ! -x "$xplane_binary" ]]; then
    print -u2 "X-Plane executable not found or not executable: $xplane_binary"
    print -u2 "Set XPLANE_ROOT to the installation directory and try again."
    exit 1
fi

# A forced simulator stop can leave the aircraft's runtime-only navdata link
# behind. Remove only the link created for the known X-Plane 12 target; refuse
# to touch a regular file or an unexpected symlink at that path.
if [[ -L "$compat_path" ]]; then
    actual_target=$(readlink "$compat_path")
    normalized_actual=$(print -r -- "$actual_target" | sed 's#//*#/#g')
    normalized_expected=$(print -r -- "$compat_target" | sed 's#//*#/#g')
    if [[ "$normalized_actual" != "$normalized_expected" ]]; then
        print -u2 "Refusing to remove unexpected navdata symlink: $compat_path -> $actual_target"
        exit 1
    fi
    unlink "$compat_path"
    print "Removed stale aircraft navdata compatibility link."
elif [[ -e "$compat_path" ]]; then
    print -u2 "Refusing to replace regular navdata file: $compat_path"
    exit 1
fi

if [[ "$(uname -m)" == "arm64" ]]; then
    print "Launching the complete X-Plane process under Rosetta 2 (x86_64)."
else
    print "Launching X-Plane as x86_64."
fi
print "Aircraft package must be installed in: $xplane_root/Aircraft/"

cd "$xplane_root"
exec /usr/bin/arch -x86_64 "$xplane_binary" "$@"
