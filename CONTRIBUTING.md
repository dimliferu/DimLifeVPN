Contributing

Every contribution to DimLifeVPN is welcome.

Reporting Issues

If you find a bug or have a suggestion:

1. Search existing GitHub Issues.
2. If no similar issue exists, create a new issue.
3. Include logs, screenshots, and steps to reproduce the problem.

Development

DimLifeVPN is based on Flutter and currently targets Android APK builds.

Requirements

- Flutter 3.38.5 or newer
- Dart SDK compatible with the project

Check your installation:

flutter --version

Setup

Install dependencies:

flutter pub get

Prepare the project:

make android-prepare

Run

flutter run

Build APK

make android-release

or

flutter build apk --release

Acknowledgements

DimLifeVPN is based on the open-source Hiddify project:

https://github.com/hiddify/hiddify-app

Original copyright belongs to the Hiddify authors.

DimLifeVPN modifications are distributed under GPL-3.0.
