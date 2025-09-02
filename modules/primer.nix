{ config, pkgs, lib, consts, ... }:

{
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "home";

  users.users.aiotter = {
    isNormalUser = true;
    extraGroups = [ "wheel" "gpio" ]; # enable sudo
    openssh.authorizedKeys.keys = [ consts.ssh-key ];
    hashedPassword = ""; # password-less login
  };
  security.sudo.extraConfig = "aiotter ALL=(ALL) NOPASSWD: ALL";

  # Enable MDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      hinfo = true;
      workstation = true;
      # domain = true;
    };
  };

  programs.zsh.enable = true;

  services.openssh.settings = {
    # LogLevel = "DEBUG3";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
