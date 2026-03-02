{ pkgs, ... }:

let
  # Compose an Android SDK with the SDK tools you want
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" ];  # required SDK versions
    buildToolsVersions = [ "36.0.0" ];
    abiVersions = [ "x86_64" "armeabi-v7a" "arm64-v8a" ];
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
    # ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  };

  # (optional) if you want adb available directly
  home.sessionPath = [
    "${pkgs.androidenv.androidPkgs.platform-tools}/bin"
  ];
}
