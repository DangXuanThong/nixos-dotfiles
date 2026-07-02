{ pkgs, ... }:

let
  cursorName = "MacTahoeCursor";

  accurse = pkgs.python314.pkgs.buildPythonApplication rec {
    pname = "accurse";
    version = "0.1.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "DangXuanThong";
      repo = "accurse";
      rev = "beea835d6b5ae29e00c41abfe3efa07f32b7d66f";
      hash = "sha256-SLlQQqJPTPOEXZkcIys1Nn0RUr1XoSIH+g7+L5j5DAo=";
    };

    build-system = [ pkgs.python314.pkgs.hatchling ];
    dependencies = [ pkgs.python314.pkgs.lxml ];

    nativeBuildInputs = [ pkgs.python314.pkgs.pythonRelaxDepsHook ];
    pythonRelaxDeps = [ "lxml" ];

    makeWrapperArgs = [
      "--prefix" "PATH" ":" (pkgs.lib.makeBinPath (with pkgs; [ librsvg hyprcursor xcursorgen ]))
    ];

    pythonImportsCheck = [ "accurse" ];
  };

  macTahoeCursor = pkgs.stdenv.mkDerivation {
    name = cursorName;
    src = ../config/cursor/${cursorName};
    nativeBuildInputs = [ accurse ];
    buildPhase = ''
      cp -r $src ./${cursorName}
      chmod -R u+w ./${cursorName}
      accurse ./${cursorName}/metadata.toml
      mkdir -p $out/share/icons
      cp -r AC-${cursorName} $out/share/icons/${cursorName}
    '';
    installPhase = "true";
  };
in

{
  home.pointerCursor = {
    name = cursorName;
    package = macTahoeCursor;
  };
}
