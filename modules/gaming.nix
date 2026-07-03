{ pkgs, ...}:

{
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    mesa-demos
    vulkan-tools
    pciutils
  ];
}
