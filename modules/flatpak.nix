# home.nix
{ lib, ... }:

{
  services.flatpak = {
    update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
    uninstallUnmanaged = true;
    # Add here the flatpaks you want to install
    packages = [
      { appId = "org.vinegarhq.Sober"; origin = "flathub"; }
      # { appId = "com.brave.Browser"; origin = "flathub"; }
    ];
  };
}
