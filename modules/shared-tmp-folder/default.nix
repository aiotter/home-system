{ lib, ... }:

let
  sharePath = "/srv/samba/tmp";
  imageDir = "/var/lib/samba-tmp-share";
  imagePath = "${imageDir}/tmp-share.ext4";
in
{
  imports = [
    ./storage.nix
    ./samba.nix
    ./webdav.nix
    ./filebrowser.nix
  ];

  options.services.shared-tmp-folder = {
    sharePath = lib.mkOption { };
    sharedDirectory = lib.mkOption { };
    imageDir = lib.mkOption { };
    imagePath = lib.mkOption { };
    imageSizeBytes = lib.mkOption {
      type = lib.types.ints.positive;
    };
    imageTmpPath = lib.mkOption { };
    serverName = lib.mkOption { };
    shareName = lib.mkOption { };

    webdav = {
      port = lib.mkOption { };
      endpointBase = lib.mkOption { };
      endpointPath = lib.mkOption { };
    };

    filebrowser = {
      port = lib.mkOption { };
      baseUrl = lib.mkOption { };
      database = lib.mkOption { };
    };
  };

  config.services.shared-tmp-folder = {
    inherit sharePath imageDir imagePath;

    sharedDirectory = "${sharePath}/share";
    imageSizeBytes = 1024 * 1024 * 1024; # 1GiB
    imageTmpPath = "${imagePath}.new";
    serverName = "国際空港";
    shareName = "黄色の窓口";

    webdav = {
      port = 8081;
      endpointBase = "services/webdav";
      endpointPath = "/services/webdav";
    };

    filebrowser = {
      port = 8082;
      baseUrl = "/services/filebrowser";
      database = "/var/lib/filebrowser/database.db";
    };
  };
}
