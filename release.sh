#!/usr/bin/env bash

cd "$(dirname "$0")"
. common.inc.sh

if git describe --tags --exact-match >/dev/null 2>&1; then
    version="$(git describe --tags --abbrev=0)"
else
    version="$(git describe --tags || true)"
fi
if test -z "$version"; then
    echo "Unknown version - missing git tags?"
    exit 1
fi
echo "Version: $version"

rel_dir="bin/release/$version"
mkdir -p "$rel_dir"
echo "Build folder: $rel_dir"

echo "Generating assets..."
node consts-gen.js consts.json --output-go consts.go --output-js web/src/consts.js
yarn run --silent build --stats errors-only
cp README.md web/dist/

build_release() {
    if [ "$1" = "windows" ]; then
        build_dir="$rel_dir/$1-$2"
        exe_name="TBA-uploader.exe"
    else
        build_dir="$rel_dir/$1-$2/TBA-uploader-$version-$3"
        exe_name="TBA-uploader"
    fi
    echo "[$1/$2] Building $exe_name"
    mkdir -p "$build_dir"
    GOOS="$1" GOARCH="$2" go build -o "$build_dir/$exe_name" -ldflags "-X main.Version=$version"
    zip_name="TBA-uploader-$version-$3.zip"
    echo "[$1/$2] Generating $zip_name"
    pushd "$rel_dir/$1-$2" >/dev/null
    zip -r "$zip_name" TBA-uploader*
    mv "$zip_name" ../
    popd >/dev/null
    if [ "$1" != "windows" ]; then
        echo "[$1/$2] Removing intermediate folder"
        mv "$build_dir/$exe_name" "$build_dir/../"
        rmdir "$build_dir"
    fi
    echo "[$1/$2] Done"
}

build_release windows amd64 windows-x86_64
build_release darwin amd64 mac-x86_64
build_release darwin arm64 mac-arm64
build_release linux amd64 linux-x86_64
build_release linux arm64 linux-arm64
