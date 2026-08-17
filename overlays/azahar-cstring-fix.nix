final: prev: {
  azahar = prev.azahar.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i '1i #include <cstring>' src/audio_core/cubeb_sink.cpp
      sed -i '1i #include <cstring>' src/audio_core/cubeb_input.cpp
    '';
  });
}
