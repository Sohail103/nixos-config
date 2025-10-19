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

  virtualisation.docker.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "docker0" "wlo1" ];
    allowedUDPPorts = [ 67 68 53 ];
    allowedTCPPorts = [ 53 ];
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
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  programs.hyprland = {
  enable = true;
  xwayland.enable = true; # Needed for apps that don’t support Wayland
  };
  
  environment.sessionVariables = {
  NIXOS_OZONE_WL = "1"; # Makes Electron apps run natively on Wayland
  WLR_NO_HARDWARE_CURSORS = "1"; # Fixes black cursor on some GPUs
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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  services.udisks2.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    kitty
    neovim
    distrobox
    firefox
    bluez
    bluez-tools
    brightnessctl
    pavucontrol
    upower
    xwayland
    adwaita-icon-theme
    linux-wifi-hotspot
    iw
    iwd
    pyenv

    vscode
    python3
    xwayland-satellite
  ];

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
