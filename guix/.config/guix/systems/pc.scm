;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (gnu))
(use-modules (gnu packages admin))
(use-modules (gnu packages certs))
(use-modules (gnu packages compression))
(use-modules (gnu packages cups))
(use-modules (gnu packages curl))
(use-modules (gnu packages dunst))
(use-modules (gnu packages freedesktop))
(use-modules (gnu packages gimp))
(use-modules (gnu packages gnome))
(use-modules (gnu packages gnome-xyz))
(use-modules (gnu packages kde))
(use-modules (gnu packages linux))
(use-modules (gnu packages image))
(use-modules (gnu packages mpd))
(use-modules (gnu packages networking))
(use-modules (gnu packages package-management))
(use-modules (gnu packages pciutils))
(use-modules (gnu packages pulseaudio))
(use-modules (gnu packages rsync))
(use-modules (gnu packages rust-apps))
(use-modules (gnu packages terminals))
(use-modules (gnu packages version-control))
(use-modules (gnu packages vim))
(use-modules (gnu packages wget))
(use-modules (gnu packages wm))
(use-modules (gnu packages xdisorg))
(use-modules (gnu packages xfce))
(use-modules (nongnu packages linux))
(use-modules (nongnu packages mozilla))
(use-modules (nongnu system linux-initrd))
(use-modules (gnu services admin))
(use-modules (gnu services audio))
(use-modules (gnu services cups))
(use-modules (gnu services desktop))
(use-modules (gnu services mcron))
(use-modules (gnu services networking))
(use-modules (gnu services nfs))
(use-modules (gnu services sound))
(use-modules (gnu services ssh))
(use-modules (gnu services xorg))

(define desktop-packages
  (list i3-wm i3status
        rofi
        alacritty
        dunst
        papirus-icon-theme
        kdeconnect
        flameshot
        xclip
        zenity
        thunar gvfs
        xdg-utils))

(define shell-packages
  (list stow
        pciutils
        zoxide
        zip unzip))

(define media-packages
  (list pulseaudio
        pavucontrol
        mpd mpd-mpc))

(define net-packages
  (list nss-certs
        net-tools
        nmap
        curl
        wget
        wireshark
        rsync))

(define editor-packages
  (list neovim))

(define web-packages
  (list firefox
        git))

(define graphics-packages
  (list gimp))

(define beets-update-job
  ;; Update the music library every morning at 10 AM ;;
  #~(job "0 10 * * *"
         "beet fetchart && beet update && beet duplicates"))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Amsterdam")
  ;; Use the default international keyboard layout ;;
  (keyboard-layout #f)
  (host-name "pc")

  ;; Use a kernel and firmware with non-free binary blobs ;;
  (kernel linux)
  (firmware (list linux-firmware))
  (initrd microcode-initrd)

  (users (cons* (user-account
                  (name "thomas")
                  (comment "Thomas Versteeg")
                  (group "users")
                  (home-directory "/home/thomas")
                  (supplementary-groups
                    '(
                      ;; sudo ;;
                      "wheel" 
                      ;; Network devices ;;
                      "netdev" 
                      ;; Audio devices ;;
                      "audio" 
                      ;; Video devices ;;
                      "video")))
                %base-user-accounts))

  ;; Install the defined packages ;;
  (packages
    (append
      desktop-packages
      shell-packages
      media-packages
      net-packages
      editor-packages
      web-packages
      graphics-packages
      %base-packages))

  ;; Setup the system services ;;
  (services
    (append
      (list (service tor-service-type)

            ;; Music player ;;
            (service mpd-service-type
                     (mpd-configuration
                       (user "thomas")
                       (port "6600")
                       (music-dir "/home/thomas/Music")))

            ;; Export media directories for Kodi ;;
            (service nfs-service-type
                     (nfs-configuration
                       (exports
                         '(("/home/thomas/TV"
                            "*(ro,all_squash,insecure)")
                           ("/home/thomas/Movies"
                            "*(ro,all_squash,insecure)")))))

            ;; Automatically apply security updates ;;
            (service unattended-upgrade-service-type)

            ;; Cron jobs ;;
            (simple-service 'my-cron-jobs
                            mcron-service-type
                            (list beets-update-job))

            ;; Printers ;;
            (service cups-service-type
                     (cups-configuration
                       (web-interface? #t)
                       (extensions
                         (list cups-filters hplip-minimal))))

            (set-xorg-configuration
              (xorg-configuration
                (keyboard-layout keyboard-layout))))

      %desktop-services))

  (bootloader
    (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (timeout 1)
      (target "/boot/efi")))

  ;; Blacklist some kernel modules ;;
  (kernel-arguments
    ;; Disable HDMI audio devices ;;
    (list "modprobe.blacklist=snd_hda_codec_hdmi"))

  (swap-devices
    (list (uuid "e700885b-7b72-4b87-8f9f-e72edac93812")))

  (file-systems
    (cons* (file-system
             (mount-point "/")
             (device
               (uuid "7ace9d14-5d93-425c-9639-dfcc2417ffa3"
                     'ext4))
             (type "ext4"))

           (file-system
             (mount-point "/boot/efi")
             (device "/dev/nvme0n1p1")
             (type "vfat"))

           %base-file-systems))

  ;; Block Facebook ;;
  (hosts-file
    (plain-file "hosts"
                (string-append (local-host-aliases host-name)
                               %facebook-host-aliases)))

  ;; Allow resolution of '.local' host names with mDNS ;;
  (name-service-switch %mdns-host-lookup-nss))

; vim: et
