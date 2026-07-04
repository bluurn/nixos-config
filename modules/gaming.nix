{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    gamemode
    mangohud
    protonup-qt
    mangohud
    mesa-demos
    vulkan-tools
  ];

  programs.steam.enable = true;
  programs.gamemode.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
