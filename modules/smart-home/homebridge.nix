{ config, pkgs, lib, ... }:

{
  containers.homebridge = {
    autoStart = true;

    config = {
      services.homebridge = {
        enable = true;
        openFirewall = true;

        # buggy
        # コンテナ作成直後に UI がうまく動かない場合は、一旦 ui.auth = "form" でコンテナを作り直すと動く
        # 最新版では修正されている？
        # https://github.com/homebridge/homebridge-config-ui-x/issues/2256
        uiSettings.auth = "none";
      };

      system.stateVersion = "25.05";
    };
  };

  networking.firewall = {
    inherit (config.containers.homebridge.config.networking.firewall) allowedTCPPorts;
  };
}
