{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    # Enable networking
    networkmanager.enable = true;
    hostName = "Nix-PC";
    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Config auto mount external drives
  fileSystems = {
    "/run/media/penguin/Data" = {
      device = "/dev/disk/by-uuid/0F2C121B0F2C121B";
      fsType = "ntfs3";
      options = [ "nofail" "uid=1000" "gid=1000" "windows_names" ];
    };
    "/run/media/penguin/Docker" = {
      device = "/dev/disk/by-uuid/bfc0adbc-1fdc-a64a-9371-c577db51e4f6";
      fsType = "ext4";
      options = [ "nofail" ];
    };
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.penguin = {
    isNormalUser = true;
    description = "Penguin";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "docker" ];
  };

  # Ensure graphics support for Vulkan/Intel
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
    };
    # Enable the KDE Plasma Desktop Environment.
    desktopManager.plasma6.enable = true;
    # Enable CUPS to print documents.
    printing.enable = true;
    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # List services that you want to enable:
    flatpak.enable = true;
    timesyncd.enable = true;
  };
  security.rtkit.enable = true;

  programs = {
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        #proton-ge-bin      # community packaged Proton-GE
      ];
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    npm.enable = true;
    partition-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ghostty
    tzdata
    nil
    kdePackages.qtmultimedia
    (sddm-astronaut.override {
      embeddedTheme = "purple_leaves";
    })
  ];
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.konsole
    kdePackages.spectacle
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "penguin" ];
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      experimental = true;
      data-root = "/run/media/penguin/Docker";
    };
    enableOnBoot = false;
  };

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
  ];
}
