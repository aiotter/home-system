{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.shared-tmp-folder;
in
{
  systemd.services.temporary-share-webdav = {
    description = "Anonymous WebDAV access to the temporary shared folder";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "srv-samba-tmp.mount"
      "samba-tmp-share-permissions.service"
    ];
    after = [
      "srv-samba-tmp.mount"
      "samba-tmp-share-permissions.service"
      "network.target"
    ];
    path = [ pkgs.rclone ];

    serviceConfig = {
      User = "nobody";
      Group = "nogroup";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      exec rclone serve webdav ${cfg.sharedDirectory} --addr 127.0.0.1:${toString cfg.webdav.port} --baseurl ${lib.escapeShellArg cfg.webdav.endpointBase} --no-modtime
    '';
  };

  services.avahi = {
    publish.userServices = true;
    extraServiceFiles.webdav = ''
      <?xml version="1.0" standalone="no"?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name>${cfg.serverName}</name>
        <service>
          <type>_webdav._tcp</type>
          <port>80</port>
          <txt-record>path=${cfg.webdav.endpointPath}/</txt-record>
        </service>
      </service-group>
    '';
  };
}
