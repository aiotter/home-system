{ pkgs, config, ... }:

let
  components =
    with pkgs.home-assistant-custom-components;
    with pkgs.callPackage ./home-assistant-components { };
    [
      setup_assistant
    ];
in

{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "default_config"
      "met" # weather forecast
      "mqtt"
    ];

    customComponents = components;

    config = {
      default_config = { };

      setup_assistant.required_integrations = map (builtins.getAttr "domain") components ++ [
        "mqtt"
      ];

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
