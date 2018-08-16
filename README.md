# Flutter Showcase

Preview community-made content for [flutter](https://github.com/flutter/flutter).

## How to build?

Either:
* Download the latest build in the releases section //TODO: Add links to the latest version
* Build it yourself
    * Get it from git with `git clone https://github.com/flutter-showcase/flutter-showcase.git`
    * Get in the folder with a terminal, and run `flutter packages get`
    * Run the preprocessor script with `preprocess`
    * Connect your device or Start your emulator
    * run `flutter run --release`

## How can I showcase my content ?

A user showcase is supposed to be a collection of flutter apps, therefore, showcases are simple flutter apps with a few exceptions:
* Your showcase **MUST**
    * include the flutter-showcase section in it's pubspec.yaml
    * call a class in it's runApp, and this class **MUST**
        * accept a single positionned argument of type GlobalKey<NavigationState>
        * use this argument in the App widget (MaterialApp, CupertinoApp, WidgetsApp) as a navigatorkey

* Your showcase **MUST NOT**
    * interact with the platform, which include
        * Platform channels of any kind (MethodChannel or EventChannel)
        * Plugins who use these channels
    * attempt to break out of it's folder, or mess with the user's device
    * do any processing before the runApp()

## How can I contribute ?

TODO: Link to the contribution guidelines