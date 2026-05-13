{ config, ... }:

{
  services = {
    mosquitto.enable = true;

    zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant.enabled = config.services.home-assistant.enable;
        # permit_join = true;
        mqtt.base_topic = "zigbee2mqtt";
        serial.port = ""; # auto-discovery
        frontend = {
          enabled = true;
          port = 8088;
        };
      };
    };
  };

  # auto-discovery のために全ての USB serial デバイスを許可
  systemd.services.zigbee2mqtt.serviceConfig.DeviceAllow = [ "char-ttyUSB rw" "char-ttyACM rw" ];

  networking.firewall.allowedTCPPorts = [ config.services.zigbee2mqtt.settings.frontend.port ];
}
