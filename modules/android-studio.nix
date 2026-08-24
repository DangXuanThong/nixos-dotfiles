{ lib, pkgs, ... }:

let
  # Compose an Android SDK with the SDK tools you want
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "37.1" "latest" ];  # required SDK versions
    buildToolsVersions = [ "37.0.0" ];
    includeSources = true;
    toolsVersion = null;

    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_ps16k" ];
    abiVersions = [ "x86_64" ];
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
    ANDROID_AVD_HOME = "$HOME/.config/.android/avd";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
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
