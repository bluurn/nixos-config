{ pkgs, ... }: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry = {
      package = pkgs.pinentry-curses;
    };
  };
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
}
