{ pkgs, ...}:

{
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope
    mangohud
    mesa-demos
    pciutils
    protonup-qt
    vulkan-tools
  ];
}
