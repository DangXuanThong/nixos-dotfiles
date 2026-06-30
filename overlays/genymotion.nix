final: prev: {
  genymotion = prev.genymotion.overrideAttrs (old: rec {
    version = "3.10.0";
    src = prev.fetchurl {
      url = "https://dl.genymotion.com/releases/genymotion-${version}/genymotion-${version}-linux_x64.run";
      sha256 = "sha256-y5kkAJpRt9EOYAmgos0+X6XFPgd2z2XEtCq76vAVt8c=";
    };
    nativeBuildInputs = 
      (builtins.filter (x: x.pname or "" != "patchelf") old.nativeBuildInputs)
      ++ [ final.patchelf ];
    libPath = prev.lib.makeLibraryPath (with final; [
      stdenv.cc.cc
      zlib
      glib
      libx11
      libxkbcommon
      libxmu
      libxi
      libxext
      libGL
      libxrender
      fontconfig
      freetype
      systemd
      libpulseaudio
      cairo
      gdk-pixbuf
      gtk3
      pixman
    ]);
    unpackPhase = ''
      mkdir -p phony-home $out/share/applications
      export HOME=$TMP/phony-home

      mkdir ${old.pname}
      echo "y" | sh $src -d ${old.pname}
      sourceRoot=${old.pname}

      substitute phony-home/.local/share/applications/genymotion-launchpad.desktop \
        $out/share/applications/genymotion-launchpad.desktop --replace "$TMP/${old.pname}" "$out/libexec"
    '';
    fixupPhase = ''
      patchInterpreter() {
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          "$out/libexec/genymotion/$1" || echo "WARNING: patchelf failed for $1, skipping"
      }
      
      patchExecutable() {
        patchInterpreter "$1"
        wrapProgram "$out/libexec/genymotion/$1" \
          --set "LD_LIBRARY_PATH" "${libPath}" \
          --unset "QML2_IMPORT_PATH" \
          --unset "QT_PLUGIN_PATH"
      }

      patchTool() {
        patchInterpreter "tools/$1"
        wrapProgram "$out/libexec/genymotion/tools/$1" \
          --set "LD_LIBRARY_PATH" "${libPath}"
      }

      patchExecutable genymotion
      patchExecutable player
      patchInterpreter qemu/x86_64/bin/qemu-img
      # remove the broken bundled binary and use system qemu instead
      rm $out/libexec/genymotion/qemu/x86_64/bin/qemu-system-x86_64
      ln -s ${final.qemu}/bin/qemu-system-x86_64 \
        $out/libexec/genymotion/qemu/x86_64/bin/qemu-system-x86_64
      patchInterpreter qemu/x86_64/bin/qemu-system-x86_64

      patchTool adb
      patchTool aapt
      patchTool glewinfo

      rm $out/libexec/genymotion/libxkbcommon*
    '';
    postFixup = ''
      echo "patchelf version: $(patchelf --version)"
    '';
  });
}
