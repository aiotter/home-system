{ config, ... }:

{
  services = {
    mosquitto.enable = true;

    zigbee2mqtt = {
      enable = true;
      settings = {
        # permit_join = true;
        mqtt.base_topic = "zigbee2mqtt";
        # 左下の USB ポート
        serial.port = "/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.4:1.0-port0";
        frontend = {
          enabled = true;
          port = 8088;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.zigbee2mqtt.settings.frontend.port ];
}
