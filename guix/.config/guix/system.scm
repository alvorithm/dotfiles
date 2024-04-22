;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules
 (gnu)
 (nongnu packages linux) ;;22042024 ATC: linux kernel (daviwil)
 (nongnu packages firmware) ;;22042024 ATC: kjhoerr Framework 13 first post
 (nongnu system linux-initrd)) ;;22042024 ATC: extra from nonguix gitlab 

(use-service-modules cups desktop networking ssh xorg)

(operating-system
 (kernel linux)
 (initrd microcode-initrd) ;;220424 ATC: extra from nonguix gitlab
  (firmware (list linux-firmware)) ;;22042024 ATC: nonfree firmware & drivers
  (locale "en_GB.utf8")
  (timezone "Europe/Madrid")
  (keyboard-layout (keyboard-layout "us" "intl"))
  (host-name "oile")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "alvar")
                  (comment "Álvaro Tejero Cantero")
                  (group "users")
                  (home-directory "/home/alvar")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (map specification->package 
			  '("nss-certs" ;; SSL root certificates 
					;; NB. in base-packages since 042024
			    "git" 
	  		    "stow" 
	  		    "emacs-no-x-toolkit" 
	  		    "gvfs" )) ;; enable user mounts
          %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list (service gnome-desktop-service-type)

                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service cups-service-type)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout))))

	   (modify-services
	    ;; 22042014 ATC: the default list of services we
            ;; are modifying here and then appending (see above) to.
	    %desktop-services
	    (guix-service-type config => (guix-configuration
	     (inherit config)
       (substitute-urls
	(append (list "https://substitutes.nonguix.org") %default-substitute-urls))
       (authorized-keys
	(append (list (local-file "./nonguix-signing-key.pub"))
	%default-authorized-guix-keys)))))))


  
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (mapped-devices (list (mapped-device
                          (source (uuid
                                   "20f26fde-a8bc-4522-9285-25d4521c5731"))
                          (target "cryptroot")
                          (type luks-device-mapping))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "2549-766A"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "ext4")
                         (dependencies mapped-devices)) %base-file-systems)))
