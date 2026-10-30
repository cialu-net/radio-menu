# Radio Menu

A small native macOS menu bar app for listening to internet radio. Choose a station with a left click, or right-click the menu bar icon for Settings and Quit.

<img width="716" height="598" alt="image" src="https://github.com/user-attachments/assets/01702def-670f-4c32-a2ae-77f4cf78fb39" />


## Features

- Three preset stations and support for adding direct HTTP or HTTPS audio stream URLs.
- Play, stop, volume control and a persistent station list.
- Optional animated menu bar icon, launch at login, and playback of the last station at launch.
- English, Spanish, German, French, Italian and Simplified Chinese, or automatic system-language selection.

Internet streams are supplied by third parties and may change, be unavailable or have geographic restrictions. A radio station's webpage is not necessarily its direct audio stream URL.

## Build

Requires macOS 13 or later and Apple's command line developer tools (or Xcode). In Terminal, from the project directory:

```sh
./build.sh
open build/RadioMenu.app
```

The script builds for the current Mac architecture and signs the app locally with an ad hoc signature. A distribution outside your own Mac may require an Apple Developer ID signature and notarization.

## Credits

- Author: Kalk
- Website: https://cialu.net
- Code: https://github.com/cialu-net

## License

Copyright © 2026 cialu.net | Licensed under the GNU General Public License version 3 only (GPL-3.0-only). See [LICENSE](LICENSE). The application code license does not cover the radio broadcasts or third-party streams.
