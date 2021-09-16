# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

rec {
  networking.hostName = (import ./machine.nix);

  # import all files in the directory ./${machine}, except for secrets.nix
  imports = let
    machine = (import ./machine.nix);
    machine-files = map (f: ./. + "/${machine}/${f}") (
            builtins.filter (f: f != "secrets.nix")
            (builtins.attrNames (builtins.readDir (./. + "/${machine}")))
        );
  in
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ machine-files;

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

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

}
