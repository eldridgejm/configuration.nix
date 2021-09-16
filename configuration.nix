# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  # Mount disks
  fileSystems."/mnt/dc" = {
    device = "/dev/lvmdc/lvol0";
    fsType = "ext4";
  };

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/622f34fe-aee0-4f38-814e-fbd7e131b87f";
    fsType = "ext4";
  };

  fileSystems."/mnt/arch" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };

  networking.hostName = "alamere"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp31s0.useDHCP = true;
  networking.interfaces.wlp30s0.useDHCP = true;

  # Enable WPA supplicant
  networking.wireless.enable = true;
  networking.wireless.networks = {
    MisterEero = {
      psk = (import ./secrets.nix).wireless_psk;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  
  # Configure the packages
  nixpkgs.config = {
    # Allow non-free packages to be installed
    allowUnfree = true;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    stow
    git
    gparted
    libnotify
    dunst
    restic
    rclone
    unzip
    zip
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];


  # List services that you want to enable:

  # Docker, of course
  virtualisation.docker.enable = true;

  # lorri, for automatic rebuilding of nix shells
  services.lorri.enable = true;

  services.restic.backups = {

    home-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/home/eldridge/"
      ];
      repository = "/backup/alamere-home";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='github-runner/*'"
        "--exclude='/home/eldridge/mnt'"
        "--exclude='/home/eldridge/downloads'"
        "--exclude='/home/eldridge/sandbox'"
        "--exclude='*VirtualBox*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
      };
    };

    home-remote = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/home/eldridge"
      ];
      repository = "b2:Eldridge-Backup:alamere-home";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='github-runner/*'"
        "--exclude='/home/eldridge/mnt'"
        "--exclude='/home/eldridge/downloads'"
        "--exclude='/home/eldridge/sandbox'"
        "--exclude='*VirtualBox*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
      };
    };

    etc-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/etc"
      ];
      repository = "/backup/alamere-etc";
      extraBackupArgs = [
        "--verbose"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
      };
    };

    etc-remote = {
      passwordFile = "/etc/nixos/restic-password";
      initialize = true;
      paths = [
        "/etc"
      ];
      repository = "b2:Eldridge-Backup:alamere-etc";
      extraBackupArgs = [
        "--verbose"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
      };
    };

    dc-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/mnt/dc/photos" "/mnt/dc/archive" "/mnt/dc/.backup-tester"
      ];
      repository = "/backup/dc";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 03:30:00";
      };
    };

    dc-remote = {
      passwordFile = "/etc/nixos/restic-password";
      initialize = true;
      paths = [
        "/mnt/dc/photos" "/mnt/dc/archive" "/mnt/dc/.backup-tester"
      ];
      repository = "b2:Eldridge-Backup:dc";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='*/autc/*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 04:30:00";
      };
    };

  };

  systemd.services.backup-tester-home = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "eldridge";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /home/eldridge/.backup-tester'";
    };
  };

  systemd.services.backup-tester-etc = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "root";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /etc/.backup-tester'";
    };
  };

  systemd.services.backup-tester-dc = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "eldridge";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /mnt/dc/.backup-tester'";
    };
  };

  systemd.services.restic-backups-home-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };

  systemd.services.restic-backups-etc-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };

  systemd.services.restic-backups-dc-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.syncthing = {
    enable = true;
    user = "eldridge";
    dataDir = "/home/eldridge/syncthing";
    configDir = "/home/eldridge/.config/syncthing";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.dpi = 145;

  # Set up dual monitors; see: https://download.nvidia.com/XFree86/Linux-x86_64/304.137/README/configtwinview.html
  services.xserver.screenSection = ''
    Option "metamodes" "DP-2: nvidia-auto-select +2160+854 {primary=true}, DP-0: nvidia-auto-select +0+0 {rotation=left}"
  '';

  # Don't use any display manager (just startx)
  services.xserver.displayManager.startx.enable = true;

  # Use BSPWM as the window manager
  services.xserver.windowManager.bspwm.enable = true;

  # Enable the Fish shell.
  programs.fish.enable = true;

  # added to help configure thunar
  programs.dconf.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eldridge = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
    ];
  };

  users.users.github-runner = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

}
