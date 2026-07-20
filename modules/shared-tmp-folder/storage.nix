{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.shared-tmp-folder;

  prepareSambaTmpShareImage = pkgs.writeShellApplication {
    name = "prepare-samba-tmp-share-image";
    runtimeEnv = {
      SHARE_IMAGE_DIR = cfg.imageDir;
      SHARE_MOUNT_PATH = cfg.sharePath;
      SHARE_IMAGE_PATH = cfg.imagePath;
      SHARE_IMAGE_SIZE_BYTES = toString cfg.imageSizeBytes;
      SHARE_IMAGE_TMP_PATH = cfg.imageTmpPath;
    };
    runtimeInputs = with pkgs; [ coreutils e2fsprogs util-linux ];
    inheritPath = false;

    text = ''
      install -d -m 0755 "$SHARE_IMAGE_DIR" "$SHARE_MOUNT_PATH"

      if [ ! -e "$SHARE_IMAGE_PATH" ]; then
        truncate -s "$SHARE_IMAGE_SIZE_BYTES" "$SHARE_IMAGE_TMP_PATH"
        mkfs.ext4 -F -L samba-tmp "$SHARE_IMAGE_TMP_PATH"
        mv "$SHARE_IMAGE_TMP_PATH" "$SHARE_IMAGE_PATH"
      fi

      share_image_size="$(stat -c %s "$SHARE_IMAGE_PATH")"
      if [ "$share_image_size" -ne "$SHARE_IMAGE_SIZE_BYTES" ]; then
        echo "$SHARE_IMAGE_PATH is not $SHARE_IMAGE_SIZE_BYTES bytes; refusing to use it as the temporary shared folder" >&2
        exit 1
      fi

      share_image_fs_type="$(blkid -p -s TYPE -o value "$SHARE_IMAGE_PATH" || true)"
      if [ -z "$share_image_fs_type" ]; then
        mkfs.ext4 -F -L samba-tmp "$SHARE_IMAGE_PATH"
      elif [ "$share_image_fs_type" != "ext4" ]; then
        echo "$SHARE_IMAGE_PATH is $share_image_fs_type, not ext4; refusing to use it as the temporary shared folder" >&2
        exit 1
      fi
    '';
  };
in
{
  fileSystems.${cfg.sharePath} = {
    device = cfg.imagePath;
    fsType = "ext4";
    options = [
      "loop"
      "noatime"
    ];
    neededForBoot = false;
  };

  system.activationScripts.samba-tmp-share-image = {
    deps = [ "specialfs" ];
    text = lib.getExe prepareSambaTmpShareImage;
  };

  systemd.services.samba-tmp-share-permissions = {
    description = "Set permissions for the temporary shared folder";
    requires = [ "srv-samba-tmp.mount" ];
    after = [ "srv-samba-tmp.mount" ];
    before = [
      "samba-smbd.service"
      "samba-nmbd.service"
    ];
    requiredBy = [
      "samba-smbd.service"
      "samba-nmbd.service"
    ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.coreutils ];
    script = ''
      mkdir -p ${cfg.sharedDirectory}
      chown nobody:nogroup ${cfg.sharedDirectory}
      chmod 0777 ${cfg.sharedDirectory}
    '';
  };
}
