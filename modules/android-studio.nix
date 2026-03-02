{ pkgs, ... }:

let
  # Compose an Android SDK with the SDK tools you want
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # required SDK versions:
    platformVersions = [ "36" ];       # Android API level 36
    abiVersions = [ "x86_64" "arm64-v8a" ];
    buildToolsVersions = [ "36.1.0" ];
  };

  # The actual SDK package
  androidSdk = androidComposition.androidsdk;
in

{
  nixpkgs.config.android_sdk.accept_license = true;
  # Install Android Studio itself
  home.packages = with pkgs; [
    (android-studio.withSdk androidSdk)
  ];

  # Set environment variables so IDEs & tools can find it
  home.sessionVariables = {
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME     = "${androidSdk}/libexec/android-sdk";
  };

  # (optional) if you want adb available directly
  home.sessionPath = [
    "${pkgs.androidenv.androidPkgs.platform-tools}/bin"
  ];
}
