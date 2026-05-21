{
  pkgs,
  config,
  ...
}:

let
  toYaml = (pkgs.formats.yaml { }).generate;

  componentPkgs = pkgs.callPackage ./home-assistant-components { };

  enabledComponents =
    with componentPkgs;
    with pkgs.home-assistant-custom-components;
    [
      setup_assistant
      ecoflow_cloud
      # ef_ble
    ];

  customComponentSources = map componentPkgs.utils.mkPatchedComponentSource enabledComponents;
  customComponentsDir = componentPkgs.utils.collectCustomComponentSources customComponentSources;

  requiredIntegrations = map (builtins.getAttr "domain") enabledComponents ++ [
    "homekit"
    "mqtt"
  ];

  hassConfig = {
    default_config = { };

    setup_assistant = {
      required_integrations = requiredIntegrations;
    };

    homeassistant = {
      name = "おうち";
      temperature_unit = "C";
      unit_system = "metric";
      time_zone = config.time.timeZone;
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

    http = {
      server_host = [
        "0.0.0.0"
        "::"
      ];
      server_port = 8123;
      use_x_forwarded_for = true;
      trusted_proxies = [ "127.0.0.1" ];
    };
  };

  hassConfigDir = "/var/lib/hass";
  hassConfigFile = toYaml "home-assistant-configuration.yaml" hassConfig;
in

{
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";

      extraOptions = [ "--network=host" ];

      volumes = [
        "${hassConfigDir}:/config"
        "${hassConfigFile}:/config/configuration.yaml:ro"
        "${customComponentsDir}:/config/custom_components:ro"
        "/run/dbus:/run/dbus:ro"
      ]
      ++ map (componentSource: "${componentSource}:${componentSource}:ro") customComponentSources;

      environment.TZ = config.time.timeZone;

      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${hassConfigDir} - - - -"
    "d ${hassConfigDir}/custom_components - - - -"
  ];

  systemd.services.podman-home-assistant = {
    after = [
      "bluetooth.service"
      "dbus.service"
      "mosquitto.service"
    ];
    wants = [
      "bluetooth.service"
      "dbus.service"
      "mosquitto.service"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant top page
    21064 # Homekit Bridge
  ];
}
