{ lib, ... }: {

  boot.loader.systemd-boot.configurationLimit = lib.mkForce 5;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  networking.networkmanager.enable = true;
  networking.hostName = "t480";
  time.timeZone = "Europe/Berlin";
}
