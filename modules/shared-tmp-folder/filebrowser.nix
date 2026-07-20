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
  services.filebrowser = {
    enable = true;
    user = "nobody";
    group = "nogroup";

    settings = {
      address = "127.0.0.1";
      port = cfg.filebrowser.port;
      root = cfg.sharedDirectory;
      database = cfg.filebrowser.database;
      baseURL = cfg.filebrowser.baseUrl;
      noauth = true;
    };
  };

  systemd.services.filebrowser = {
    requires = [
      "srv-samba-tmp.mount"
      "samba-tmp-share-permissions.service"
    ];
    after = [
      "srv-samba-tmp.mount"
      "samba-tmp-share-permissions.service"
    ];
    path = [
      config.services.filebrowser.package
      pkgs.getent
    ];

    serviceConfig.UMask = lib.mkForce "0000";

    preStart = ''
      if [ ! -e ${lib.escapeShellArg cfg.filebrowser.database} ]; then
        filebrowser config init \
          --database ${lib.escapeShellArg cfg.filebrowser.database} \
          --root ${lib.escapeShellArg cfg.sharedDirectory} \
          --address 127.0.0.1 \
          --port ${toString cfg.filebrowser.port} \
          --baseURL ${lib.escapeShellArg cfg.filebrowser.baseUrl} \
          --auth.method noauth \
          --branding.name ${lib.escapeShellArg cfg.serverName} \
          --locale ja \
          --scope / \
          --fileMode 0o666 \
          --dirMode 0o777 \
          --disableExec
      fi

      filebrowser config set \
        --database ${lib.escapeShellArg cfg.filebrowser.database} \
        --root ${lib.escapeShellArg cfg.sharedDirectory} \
        --address 127.0.0.1 \
        --port ${toString cfg.filebrowser.port} \
        --baseURL ${lib.escapeShellArg cfg.filebrowser.baseUrl} \
        --auth.method noauth \
        --branding.name ${lib.escapeShellArg cfg.serverName} \
        --locale ja \
        --scope / \
        --fileMode 0o666 \
        --dirMode 0o777 \
        --disableExec

      if ! filebrowser users find 1 --database ${lib.escapeShellArg cfg.filebrowser.database} >/dev/null 2>&1; then
        filebrowser users add guest unused-noauth-password \
          --database ${lib.escapeShellArg cfg.filebrowser.database} \
          --scope / \
          --locale ja
      fi

      filebrowser users update 1 \
        --database ${lib.escapeShellArg cfg.filebrowser.database} \
        --username guest \
        --scope / \
        --locale ja
    '';
  };
}
