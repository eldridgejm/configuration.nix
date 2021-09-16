{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.dpi = 145;

  # Set up dual monitors; see: https://download.nvidia.com/XFree86/Linux-x86_64/304.137/README/configtwinview.html
  services.xserver.screenSection = ''
    Option "metamodes" "DP-2: nvidia-auto-select +2160+854 {primary=true}, DP-0: nvidia-auto-select +0+0 {rotation=left}"
  '';
}
