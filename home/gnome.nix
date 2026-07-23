{ lib, ... }:

{
  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/session" = {
        idle-delay = lib.hm.gvariant.mkUint32 0;
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "compose:ralt" ];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        idle-dim = false;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };
    };
  };
}
