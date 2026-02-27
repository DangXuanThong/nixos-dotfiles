{ config, pkgs, lib, ... }:

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
  # Install Android Studio itself
  home.packages = with pkgs; [
    (android-studio.withSdk androidSdk)
    # androidSdk        # tell Home Manager to install the SDK too
  ];

  # Set environment variables so IDEs & tools can find it
  home.sessionVariables = {
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME     = "${androidSdk}/libexec/android-sdk";
    # (optional) put tools on PATH
    # PATH = "${androidSdk}/bin:${pkgs.androidenv.androidPkgs.platform-tools}/bin:${config.home.sessionVariables.PATH}";
  };

  # (optional) if you want adb available directly
  home.sessionPath = [
    "${pkgs.androidenv.androidPkgs.platform-tools}/bin"
  ];
}
