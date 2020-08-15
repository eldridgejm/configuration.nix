configuration.nix
=================

My NixOS system configuration.

Installation
------------

1. `git clone` this repository into `/etc/nixos`.
2. Create a file called `secrets.nix` which includes the following:
```
{
    wireless_psk = "your_wireless_psk_goes_here";
}
```
3. Run `nixos-rebuild switch`.
