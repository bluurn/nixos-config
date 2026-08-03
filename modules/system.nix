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
  networking.hostName = "t480";
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
