#!/bin/sh
# Copyright (C) 2026 Kalk — SPDX-License-Identifier: GPL-3.0-only
set -eu
cd "$(dirname "$0")"
APP="build/RadioMenu.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/module-cache
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp LICENSE "$APP/Contents/Resources/LICENSE"
swiftc -module-cache-path build/module-cache -parse-as-library -target "$(uname -m)-apple-macosx13.0" Sources/RadioMenu.swift -o "$APP/Contents/MacOS/RadioMenu"
codesign --force --sign - "$APP"
printf 'Built %s\n' "$APP"
