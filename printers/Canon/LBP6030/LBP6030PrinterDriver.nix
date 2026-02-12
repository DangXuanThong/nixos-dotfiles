{ stdenv }:

stdenv.mkDerivation rec {
  name = "canon-lbp6030-${version}";
  version = "1.0";

  src = ./.;

  installPhase = ''
    mkdir -p $out/share/cups/model/Canon/
    cp ppd/CNRCUPSLBP6030ZNK.ppd $out/share/cups/model/Canon/

    mkdir -p $out/lib/cups/filter
    cp filter/* $out/lib/cups/filter/

    mkdir -p $out/lib/Canon/CUPS_SFPR/Libs
    cp Libs/* $out/lib/Canon/CUPS_SFPR/Libs/
    substituteInPlace $out/share/cups/model/Canon/CNRCUPSLBP6030ZNK.ppd \
      --replace "/usr/lib/Canon/CUPS_SFPR" "$out/lib/Canon/CUPS_SFPR"
  '';
}
