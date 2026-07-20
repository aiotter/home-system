{ config, ... }:

let
  cfg = config.services.shared-tmp-folder;
in
{
  services.samba = {
    enable = true;
    openFirewall = false;

    settings = {
      global = {
        "server role" = "standalone server";
        "map to guest" = "Bad Password";
        "guest account" = "nobody";
      };

      "${cfg.shareName}" = {
        path = cfg.sharedDirectory;
        browseable = "yes";
        writable = "yes";
        public = "yes";
        "guest ok" = "yes";
        "guest only" = "yes";
        "only guest" = "yes";
        "read only" = "no";
        "force user" = "nobody";
        "force group" = "nogroup";
        "create mask" = "0666";
        "directory mask" = "0777";
      };
    };
  };

  # Windows からは WebDAV / Filebrowser でアクセスするため、Windows のネットワーク探索には SMB を出さない。
  # macOS からは Bonjour で広告された SMB にアクセスする。
  services.samba-wsdd.enable = false;
  services.samba.nmbd.enable = false;

  services.avahi = {
    publish.userServices = true;
    extraServiceFiles.smb = ''
      <?xml version="1.0" standalone="no"?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name>${cfg.serverName}</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
      </service-group>
    '';
  };

  networking.firewall.allowedTCPPorts = [ 445 ];
}
