{ pkgs, ...}:

{
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  environment.systemPackages = with pkgs; [
    gamescope
    proton-ge-bin
    libdecor
    mangohud
    mesa
    mesa-demos
    pciutils
    protonup-qt
    vulkan-loader
    vulkan-tools
    xwayland
  ];
}
