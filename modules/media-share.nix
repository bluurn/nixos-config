{
  pkgs,
  ...
}:

let
  smbFirewall = {
    allowedTCPPorts = [
      139
      445
      5357
    ];

    allowedUDPPorts = [
      137
      138
      3702
    ];
  };
in
{
  services.samba = {
    enable = true;
    openFirewall = false;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nixos";
        "netbios name" = "nixos";

        "server role" = "standalone server";
        "security" = "user";
        "map to guest" = "bad user";

        "interfaces" = "lo wlp3s0";
        "bind interfaces only" = "yes";

        "server min protocol" = "SMB2_10";
        "client min protocol" = "SMB2";
      };

      torrents = {
        "path" = "/srv/torrents/downloads";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "vova";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.interfaces = {
    wlp3s0 = smbFirewall;
  };

  environment.systemPackages = [
    pkgs.samba
  ];
}
