{ pkgs, ... }:

let
  macTahoeCursor = pkgs.stdenv.mkDerivation {
    name = "MacTahoeCursor";
    src = ../config/cursor;  # copies the whole cursor/ dir to the store

    buildInputs = with pkgs; [ hyprcursor xcursorgen ];

    buildPhase = ''
      bash $src/scripts/build-hyprcursor.sh $src/src/MacTahoeCursor $out/share/icons
      bash $src/scripts/build-xcursor.sh $src/src/MacTahoeXCursor $out/share/icons/MacTahoeCursor
    '';

    installPhase = "true";
  };
in

{
  home.pointerCursor = {
    name = "MacTahoeCursor";
    size = 36;
    package = macTahoeCursor;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor = {
      enable = true;
      size = 36;
    };
  };
}
