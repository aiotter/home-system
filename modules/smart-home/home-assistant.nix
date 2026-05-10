{ ... }:

{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "default_config"
      "met" # weather forecast
      "mqtt"
    ];

    config = {
      default_config = { };

      homeassistant = {
        name = "おうち";
        temperature_unit = "C";
        unit_system = "metric";
        auth_providers = [
          {
            type = "trusted_networks";
            trusted_networks = [
              "0.0.0.0/0"
              "::/0"
            ];
            allow_bypass_login = true;
          }
          {
            type = "homeassistant";
          }
        ];
      };
    };
  };
}
