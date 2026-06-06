# Flutter Android Dev Shell

This template provides a Flutter Android development shell with a Nix-managed Android SDK.

Use it in a project with:

```bash
nix develop
flutter doctor -v
flutter pub get
flutter run
```

The Android SDK is provided by `androidenv.composeAndroidPackages`, not by Android Studio's mutable SDK manager state.

Android Studio can still be used as an IDE.
