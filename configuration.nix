{ inputs, config, pkgs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernel.sysctl."kernel.sysrq" = 1;
    kernelModules = [ "uinput" ];
  };

  networking = {
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
    "/run/media/penguin/Games" = {
      device = "/dev/disk/by-uuid/0E9213840E921384";
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

  users.users.penguin = {
    isNormalUser = true;
    description = "Penguin";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "docker" "vboxusers" "input" "libvirtd" ];
  };

  hardware = {
    # Ensure graphics support for Vulkan/Intel
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ mangohud ];
    };
    bluetooth = {
      enable = true;
      settings = {
        General.Experimental = true;
      };
    };
    uinput.enable = true;
  };

  services = {
    greetd.enable = true;
    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = [
      (pkgs.callPackage ./printers/Canon/LBP6030/LBP6030PrinterDriver.nix {})
    ];
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
    regreet.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    steam = {
      enable = true;
      # remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
      # dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
      # gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    npm.enable = true;
    partition-manager.enable = true;
    virt-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    tzdata
    nil
    libGL
  ];
  environment.variables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libGL
    ];
  };

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        experimental = true;
        data-root = "/run/media/penguin/Docker";
      };
      enableOnBoot = false;
    };
    # virtualbox.host.enable = true;
    # virtualbox.host.enableKvm = true;
    # virtualbox.host.addNetworkInterface = false;
    libvirtd.enable = true;
  };

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    corefonts
  ];
}
