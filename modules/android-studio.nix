{ lib, pkgs, ... }:

let
  # Compose an Android SDK with the SDK tools you want
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" "latest" ];  # required SDK versions
    buildToolsVersions = [ "36.0.0" ];
    includeSources = true;
    toolsVersion = null;
  };

  # The actual SDK package
  androidSdk = androidComposition.androidsdk;
in

{
  nixpkgs.config.android_sdk.accept_license = true;
  home.packages = with pkgs; [
    androidSdk
  ];

  # Set environment variables so IDEs & tools can find it
  home.sessionVariables = {
    # ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME = "$HOME/AndroidSdk";
  };

  # (optional) if you want adb available directly
  home.sessionPath = [
    "${pkgs.androidenv.androidPkgs.platform-tools}/bin"
  ];

  home.activation.adbSymlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -rf $HOME/AndroidSdk
    ln -sfn ${androidSdk}/libexec/android-sdk $HOME/AndroidSdk
  '';
}
