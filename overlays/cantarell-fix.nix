final: prev:

let
  stable = import (builtins.fetchTarball {
    # nixos-26.05 snapshot (pre breakage era)
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-26.05.tar.gz";
  }) {
    system = prev.system;
  };
in

{
  cantarell-fonts = stable.cantarell-fonts;
}
