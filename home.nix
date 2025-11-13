{ config, pkgs, pkgsUnstable, quickshell, inputs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ 
    pygobject3 
    requests 
    pillow
    pycairo
    syncedlyrics
  ]);
  
  waybar-mediaplayer = pkgs.writeShellScriptBin "waybar-mediaplayer" ''
    export GI_TYPELIB_PATH="${pkgs.glib.out}/lib/girepository-1.0:${pkgs.playerctl}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0"
    exec ${pythonEnv}/bin/python /home/sohail/.config/waybar/waybar-mediaplayer/src/mediaplayer "$@"
  '';
in
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
      sw = "sudo nixos-rebuild switch";
      hu = "nmcli connection up Hotspot";
      hd = "nmcli connection down Hotspot";
    };
    initExtra = ''
      PROMPT="%F{cyan}%n@%m%f:%F{yellow}%~%f$ "
      export GI_TYPELIB_PATH="${pkgs.playerctl}/lib/girepository-1.0:${pkgs.glib}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0"
      setopt INTERACTIVE_COMMENTS
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
    nerd-fonts.code-new-roman
    swww
    wofi
    swaynotificationcenter
    wlogout
    tasks
    playerctl
    gobject-introspection
    waybar-mediaplayer
    feh
    swayidle
    hyprlock

    (pkgs.python3.withPackages (ps: with ps; [
    pillow
    pycairo
    pygobject3
    syncedlyrics

    cheese
    ]))
  ];

  fonts.fontconfig.enable = true;

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
    
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      color = "1e1e2e";
      font-size = 24;
      
      indicator-radius = 100;
      indicator-thickness = 7;
      
      # Ring colors
      ring-color = "313244";
      ring-ver-color = "89b4fa";
      ring-wrong-color = "f38ba8";
      
      # Inside colors
      inside-color = "1e1e2e";
      inside-ver-color = "1e1e2e";
      inside-wrong-color = "1e1e2e";
      
      # Line colors (transparent)
      line-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      
      # Separator color
      separator-color = "00000000";
      
      # Key highlight and text colors
      key-hl-color = "cba6f7";
      text-color = "cdd6f4";
      text-ver-color = "89b4fa";
      text-wrong-color = "f38ba8";
      
      # Effects
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      fade-in = "0.2";
      
      show-failed-attempts = true;
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
    GTK_THEME = "Adwaita-dark";  
    GI_TYPELIB_PATH = "${pkgs.playerctl}/lib/girepository-1.0:${pkgs.glib}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0";
  };
  
  home.stateVersion = "25.05";
}
