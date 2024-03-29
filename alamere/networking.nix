{ pkgs, ... }:

{
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
}
