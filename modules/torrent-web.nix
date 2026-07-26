_:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = false;
    allowInterfaces = [ "wlp3s0" ];

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts."http://t480.local".extraConfig = ''
      reverse_proxy 127.0.0.1:8080 {
        header_up Host 127.0.0.1:8080
        header_up X-Forwarded-Host {host}
        header_up X-Forwarded-Proto {scheme}
      }
    '';
  };

  networking.firewall.interfaces.wlp3s0.allowedTCPPorts = [
    80
  ];

  networking.firewall.interfaces.wlp3s0.allowedUDPPorts = [
    5353
  ];
}
