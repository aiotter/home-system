{ config, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;
    # allowedHosts = "*";

    settings = {
      title = "おうちシステム";
      disableCollapse = true;
      headerStyle = "boxedWidgets";
    };

    widgets = [
      {
        logo = {
          icon = "https://github.com/aiotter.png";
        };
      }
      {
        glances = {
          href = "/services/glances";
          url = "http://127.0.0.1:${toString config.services.glances.port}";
          version = 4;
          label = "おうちサーバー";
          cputemp = true;
          uptime = true;
          disk = "/";
          expanded = true;
        };
      }
      {
        unifi_console = {
          href = "https://unifi.ui.com/";
          url = "https://192.168.0.1";
          username = "homepage-dashboard";
          password = "{{HOMEPAGE_FILE_UNIFI_PASSWORD}}";
        };
      }
    ];

    services = [
      {
        Servers = [
          {
            "おうちサーバー" = {
              description = "Raspberry Pi 4";
              href = "/services/glances";
              widgets =
                let
                  glances = metric: {
                    type = "glances";
                    url = "http://127.0.0.1:${toString config.services.glances.port}";
                    version = 4;
                    inherit metric;
                    chart = false;
                  };
                in
                [
                  (glances "info")
                  # (glances "cpu")
                  # (glances "memory")
                ];
            };
          }
          {
            "リンゴモドキ" = {
              description = "UniFi UDR7";
              href = "https://unifi.ui.com/";
              widget = {
                type = "unifi";
                url = "https://192.168.0.1";
                username = "homepage-dashboard";
                password = "{{HOMEPAGE_FILE_UNIFI_PASSWORD}}";
              };
            };
          }
        ];
      }
      {
        "Smart Home" = [
          {
            "Home Assistant" = {
              href = "/services/home-assistant/";
              icon = "home-assistant";
            };
          }
          {
            Zigbee2Mqtt = {
              href = "/services/zigbee2mqtt/";
              icon = "zigbee2mqtt";
            };
          }
        ];
      }
    ];

    customCSS = ''
      /* ロゴをくり抜く */
      .information-widget-logo > div {
        width: 48px !important;
        height: 48px !important;
        margin-right: 0 !important;
        border-radius: 9999px;
        overflow: hidden;
      }
      .information-widget-logo img {
        width: 100% !important;
        height: 100% !important;
        object-fit: cover !important;
      }

      /* Uptime のバーゲージを削除 */
      .information-widget-glances.expanded > :first-child > :last-child .resource-usage {
        display: none;
      }

      /* Information widget を中央揃えに */
      #information-widgets > #widgets-wrap {
        justify-content: center;
      }
      #information-widgets-right:empty {
        display: none;
      }
    '';
  };

  services.nginx = {
    enable = true;

    virtualHosts."home.local" = {
      default = true;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}/";
        };

        "/services/home-assistant/" = {
          return = "301 $scheme://$host:8123/";
        };

        "/services/zigbee2mqtt/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}/";
          proxyWebsockets = true;
        };

        "/services/glances/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.glances.port}/";
        };
      };
    };

    virtualHosts."home.aiotter.com".locations =
      config.services.nginx.virtualHosts."home.local".locations
      // {
        "/services/home-assistant/" = {
          return = "301 $scheme://home-assistant.aiotter.com/";
        };
      };
  };

  systemd.services.homepage-dashboard =
    let
      unifiPasswordKey = config.deployment.keys.homepage-dashboard-unifi-password;
      unifiPasswordKeyService = "${unifiPasswordKey.name}-key.service";
    in
    {
      after = [ unifiPasswordKeyService ];
      requires = [ unifiPasswordKeyService ];

      serviceConfig.LoadCredential = [
        "unifi-password:${unifiPasswordKey.path}"
      ];

      environment = {
        HOMEPAGE_FILE_UNIFI_PASSWORD = "%d/unifi-password";
      };
    };

  services.glances.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
}
