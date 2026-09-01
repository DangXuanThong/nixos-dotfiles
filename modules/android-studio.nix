{ lib, pkgs, ... }:

let
  # Compose an Android SDK with the SDK tools you want
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "37" "37.1" "latest" ];
    buildToolsVersions = [ "37.0.0" ];
    includeSources = true;
    toolsVersion = null;

    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_ps16k" ];
    abiVersions = [ "x86_64" ];

    includeCmake = false;
    cmdLineToolsVersion = "latest";
  };

  # The actual SDK package
  androidSdk = androidComposition.androidsdk;
in

{
  nixpkgs.config.android_sdk.accept_license = true;
  home.packages = with pkgs; [
    androidSdk
    flutter
  ];

  # Set environment variables so IDEs & tools can find it
  home.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    # ANDROID_HOME = "$HOME/AndroidSdk";
    ANDROID_AVD_HOME = "$HOME/.config/.android/avd";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/37.0.0/aapt2";
  };

  home.sessionPath = [
    "${pkgs.flutter}/bin"
    # (optional) if you want adb available directly
    "${pkgs.androidenv.androidPkgs.platform-tools}/bin"
  ];

  home.activation.linkSdks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/SDKs
    $DRY_RUN_CMD ln -sfn "${androidSdk}/libexec/android-sdk" $HOME/SDKs/Android
    $DRY_RUN_CMD ln -sfn "${pkgs.flutter}" $HOME/SDKs/Flutter
  '';
}
