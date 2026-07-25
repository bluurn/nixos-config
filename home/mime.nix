{
  xdg = {
    desktopEntries.qbittorrent-web = {
      name = "qBittorrent Web";
      genericName = "Torrent client";
      exec = "xdg-open http://127.0.0.1:8080";
      terminal = false;
      categories = [
        "Network"
        "FileTransfer"
      ];
    };

    desktopEntries.qbittorrent-add = {
      name = "Add to qBittorrent";
      exec = "qb-add %u";
      terminal = false;
      noDisplay = true;
      mimeType = [
        "x-scheme-handler/magnet"
        "application/x-bittorrent"
      ];
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/magnet" = [ "qbittorrent-add.desktop" ];
        "application/x-bittorrent" = [ "qbittorrent-add.desktop" ];
      };
    };

    configFile."mimeapps.list".force = true;
  };
}
