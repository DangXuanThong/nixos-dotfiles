{ pkgs, ... }:

let
  cursorName = "MacTahoeCursor";
  macTahoeCursor = pkgs.stdenv.mkDerivation {
    name = "MacTahoeCursor";
    src = ../config/cursor;  # copies the whole cursor/ dir to the store

    buildInputs = with pkgs; [ hyprcursor xcursorgen ];

    buildPhase = ''
      bash $src/scripts/build-hyprcursor.sh $src/src/MacTahoeCursor $out/share/icons
      bash $src/scripts/build-xcursor.sh $src/src/MacTahoeXCursor $out/share/icons/${cursorName}
    '';

    installPhase = "true";
  };
in

{
  home.pointerCursor = {
    name = cursorName;
    package = macTahoeCursor;
  };

  xdg.configFile = {
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-cursor-theme-name=${cursorName}
      gtk-cursor-theme-size=36
    '';
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-cursor-theme-name=${cursorName}
      gtk-cursor-theme-size=36
    '';
  };
}
