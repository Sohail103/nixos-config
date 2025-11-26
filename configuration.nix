{ config, pkgs, system, ... }:

{
  # Nix configuration
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.hostName = "sohail-nixos";
  networking.networkmanager.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
  services.cloudflare-warp.enable = true;

  boot.kernelParams = [
  "i915.modeset=1"
  "i915.enable_guc=3"
  "i915.vram_size=512M"
  ];


  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [
    "v4l2loopback"
  ];


  virtualisation.docker.enable = true;
  networking.firewall = {
    enable = false;
    trustedInterfaces = [ "docker0" "wlo1" ];
    allowedUDPPorts = [ 67 68 53 22000 21027];
    allowedTCPPorts = [ 53 8384 22000];
  };

  services = {
    syncthing = {
      enable = true;
      user = "sohail";
      dataDir = "/home/sohail/.local/share/syncthing";
      openDefaultPorts = true;
    };
  };

  hardware.bluetooth = {
  	enable = true;
	powerOnBoot = true;
	settings = {
		General = {
			Enable = "Source,Sink,Media,Socket";
			Experimental = true;
		};
	};
  };

  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;

  # Time and locale
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Mount additional filesystem
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/f602b400-d48c-4cf4-8aeb-bef6e71cecc5";
    fsType = "ext4";
  };

  systemd.tmpfiles.rules = [
    "z /mnt/hdd 0755 sohail users -"
  ];

  # Display manager
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = false;
    desktopManager.gnome.enable = true;
  };

  services.displayManager.ly = {
    enable = true;
    settings = {
    path="/run/current-system/sw/bin";
    restart_cmd="/run/current-system/systemd/bin/systemctl reboot";
    service_name="ly";
    # Remove or comment out the X11-specific setup_cmd
    # setup_cmd="/run/current-system/sw/bin/xsession-wrapper";
    shutdown_cmd="/run/current-system/systemd/bin/systemctl poweroff";
    term_reset_cmd="/run/current-system/sw/bin/clear";
    term_restore_cursor_cmd="/run/current-system/sw/bin/tput cnorm";
    tty=1;
    waylandsessions="/etc/wayland-sessions/";
    # x_cmd and xauth_cmd are only needed for X11 sessions
    #x_cmd="/run/current-system/sw/bin/X";
    #xauth_cmd="/run/current-system/sw/bin/xauth";
    #xsessions="/run/current-system/sw/share/xsessions";
    animation = "gameoflife";
    animation_timeout_ms=500;
    bigclock = true;
    numlock = true;
    };
  };

  programs.hyprland = {
  enable = true;
  xwayland.enable = true; # Needed for apps that don’t support Wayland
  };

  environment.etc."wayland-sessions/niri.desktop".text=''
  [Desktop Entry]
  Name=Niri
  Comment=Niri Wayland Compositor
  Exec=niri-session
  Type=Application
  DesktopNames=Niri
  '';
  
  environment.sessionVariables = {
  NIXOS_OZONE_WL = "1"; # Makes Electron apps run natively on Wayland
  WLR_NO_HARDWARE_CURSORS = "1"; # Fixes black cursor on some GPUs
  # MESA_LOADER_DRIVER_OVERRIDE = "iris";
  LIBGL_ALWAYS_SOFTWARE = "0";
  };

  # Enable niri compositor
   programs.niri.enable = true;

  # Printing
  services.printing.enable = true;
  services.flatpak.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire = {
    	"context.properties" = {
		"default.clock.rate" = 48000;
	};
    };
  };

  # User configuration
  users.users.sohail = {
    isNormalUser = true;
    description = "sohail";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" "kvm" "libvirtd"];
  };

  services.udisks2.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true; # optional, for GUI VMs

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    kitty
    neovim
    distrobox
    firefox
    qutebrowser
    bluez
    bluez-tools
    brightnessctl
    pavucontrol
    upower
    linux-wifi-hotspot
    iw
    iwd
    pyenv

    vscode.fhs
    python3
    xwayland-satellite
    xwayland
    libnotify
    kdePackages.kdenlive
    obs-studio
    droidcam
    android-tools

    nmap
    zip
    
    qemu_full
    virt-manager
    tmux
    gemini-cli
    vivaldi

    intel-gpu-tools
    pciutils
    xorg.xeyes

  ];

  programs.steam.enable = true;
  # environment.sessionVariables.STEAM_USE_WAYLAND = "1";

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};

  

hardware.graphics = {
  enable = true;

  # enables 32-bit OpenGL, Vulkan, VAAPI for Steam / Proton
  extraPackages = with pkgs; [
    intel-media-driver
    libva
    libvdpau-va-gl
  ];

  extraPackages32 = with pkgs.pkgsi686Linux; [
    intel-media-driver
    libva
    libvdpau-va-gl
  ];
};



  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
      
      bluez_monitor.rules = {
        {
          matches = {
            {
              { "device.name", "matches", "bluez_card.*" },
            },
          },
          apply_properties = {
            ["bluez5.auto-connect"] = "[ a2dp_sink ]",
            ["bluez5.codec"] = "aac",
          },
        },
      }
    '';
  };

  programs.zsh.enable = true;

  services.upower = {
  	enable = true;
  };

  system.stateVersion = "25.05";
}
