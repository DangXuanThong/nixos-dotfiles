{ config, lib }:

path:
let
  configDir = "${config.home.homeDirectory}/nixos-dotfiles/config";
  fullPath = "${configDir}/${path}";
  source = config.lib.file.mkOutOfStoreSymlink fullPath;
in

{
  "${path}" =
    if lib.filesystem.pathType fullPath == "directory" then {
      inherit source;
      recursive = true;
    } else {
      inherit source;
    };
}
