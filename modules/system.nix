{ lib, pkgs, ... }: {

  boot.loader.systemd-boot.configurationLimit = lib.mkForce 5;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "vova"
    ];
  };
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.hostName = "t480";

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
    ];
  };
  time.timeZone = "Europe/Berlin";
  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      icu
    ];
  };
}
