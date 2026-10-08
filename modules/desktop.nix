_: {

  services.xserver.enable = true;
  services.xserver.xkb.options = "ctrl:nocaps";
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.firefox.enable = true;
}
