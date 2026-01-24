{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    # Enable networking
    networkmanager.enable = true;
    hostName = "Nix-PC";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Ensure graphics support for Vulkan/Intel
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];
  };

  services = {
    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    # Enable CUPS to print documents.
    printing.enable = true;
    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # List services that you want to enable:
    flatpak.enable = true;
    timesyncd.enable = true;
  };
  security.rtkit.enable = true;

  programs = {
    firefox.enable = true;
    fish.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk25;
    };
    git.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        #proton-ge-bin      # community packaged Proton-GE
        protonplus
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    bat
    eza
    ghostty
    tzdata
  ];
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.konsole
    kdePackages.spectacle
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.penguin = {
    isNormalUser = true;
    description = "Penguin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      prismlauncher
      jetbrains.idea
      flameshot
    ];
    shell = pkgs.fish;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
