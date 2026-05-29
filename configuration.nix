{ config, pkgs, ... }:
{ 
  imports =
    [ 
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nix.settings.experimental-features = [
    "nix-command"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernel.sysctl = {
    "vm.laptop_mode" = 5;
    "vm.dirty_writeback_centisecs" = 1500;
  };

  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
    options bluetooth disable_ertm=Y
    options iwlwifi power_save=1
  '';

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = false;
        KernelExperimental = false;
        FastConnectable = true;
        JustWorksRepairing = "always";
      };
    };
  };

  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.steam-hardware.enable = true;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "ignore";
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
      WIFI_PWR_ON_BAT = "on";
      WOL_DISABLE = "Y";
      USB_AUTOSUSPEND = 1;
      RESTORE_THRESHOLDS_ON_BAT = 1;
    };
  };
  services.power-profiles-daemon.enable = false;
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
    };
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    tlp
    mesa-demos
  ];

  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.steam.enable = true;


  users.users.vova = { 
     isNormalUser = true;
     description = "vova";
     extraGroups = [ "networkmanager" "wheel" ];
     shell = pkgs.zsh;
  };

  home-manager.extraSpecialArgs = {
    configurationLimit = 5;
  };
  home-manager.users.vova = import ./home.nix;

  system.stateVersion = "25.11";
}
