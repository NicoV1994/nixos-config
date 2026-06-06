{ pkgs }:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "34"
      "35"
      "36"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
      "36.0.0"
    ];
    cmdLineToolsVersion = "13.0";
    includeEmulator = true;
    includeSystemImages = true;
    includeCmake = true;
    cmakeVersions = [ "3.22.1" ];
    includeNDK = true;
    ndkVersions = [ "28.2.13676358" ];
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
    extraLicenses = [
      "android-googletv-license"
      "android-googlexr-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;
in
pkgs.mkShell {
  packages = with pkgs; [
    androidSdk
    flutter
    jdk17
  ];

  ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
  JAVA_HOME = pkgs.jdk17.home;
  CHROME_EXECUTABLE = "${pkgs.brave}/bin/brave";

  shellHook = ''
    export ANDROID_USER_HOME="$HOME/.config/.android"
    export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:${androidSdk}/bin:$PATH"
    export QT_QPA_PLATFORM=xcb
  '';
}
