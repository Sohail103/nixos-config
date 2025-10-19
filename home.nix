{ config, pkgs, pkgsUnstable, quickshell, inputs, ... }:
{
  home.username = "sohail";
  home.homeDirectory = "/home/sohail";
  
  # Import Caelestia shell home manager module
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];
  
  # Configure Caelestia shell
  programs.caelestia = {
    enable = false;
    
    systemd = {
      enable = false;  # We'll start it from niri instead
      target = "graphical-session.target";
    };
    
    settings = {
      bar.status = {
        showBattery = true;  # Set to false if you're on desktop
      };
      paths = {
        wallpaperDir = "~/Pictures/Wallpapers";
      };
    };
    
    cli = {
      enable = true;  # Enable CLI for full functionality
      settings = {
        theme = {
          enableGtk = true;
        };
      };
    };
  };
  
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      nv = "nvim";
      cls = "clear";
    };
    initExtra = ''
      PROMPT="%F{cyan}%n@%m%f:%F{yellow}%~%f$ "
    '';
  };
  
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  
  programs.git = {
    enable = true;
    userName = "Sohail103";
    userEmail = "sohailraj.satapathy@gmail.com";
    extraConfig = {
      core.editor = "nvim";
    };
  };
  
  home.packages = with pkgs; [
    neovim
    kitty
    wget
    fastfetch
    distrobox
    obsidian
    cloudflare-warp
    lazygit
    unzip
    luarocks
    zoxide
    niri
    
    # Wayland utilities
    fuzzel  # Application launcher (fallback)
    grim  # Screenshot utility
    slurp  # Screen area selector
    wl-clipboard  # Clipboard utilities
    swaylock  # Screen locker
    wlogout  # Logout menu
    brightnessctl  # Brightness control
    pavucontrol  # Audio control GUI
    nautilus
    spotify
    evince
    vlc
    gimp

    # GTK themes (add these)
    gnome-themes-extra  # For Adwaita-dark
    adwaita-icon-theme  # For cursor theme
    libreoffice
    kicad

    yazi
    foliate
    yt-dlp
    stm32cubemx
    quickshell.packages.${pkgs.system}.default
    waybar
    pywal
  ];
  
  # GTK Configuration - ADD THIS SECTION
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  
  # Cursor Configuration - ADD THIS SECTION
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };
  
  xdg.desktopEntries.spotify = {
    name = "Spotify";
    genericName = "Music Player";
    exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    terminal = false;
    categories = [ "Audio" "Music" "Player" "AudioVideo" ];
    mimeType = [ "x-scheme-handler/spotify" ];
    icon = "spotify-client";
  };

  xdg.desktopEntries.obsidian = {
    name = "Obsidian";
    genericName = "Obsidian";
    exec = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    terminal = false;
    categories = [ "Office" "TextEditor" ];
    mimeType = [ "x-scheme-handler/obsidian" ];
    icon = "obsidian";
  };
  
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
    GTK_THEME = "Adwaita-dark";  # Add this
  };
  
  home.stateVersion = "25.05";
}
