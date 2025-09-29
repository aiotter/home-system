{ config, pkgs, lib, ... }:

let
  contents = {
    # slug = {
    #   enable = true;
    #   title = "title";
    #   nginx = {
    #     proxyPass = "http://localhost:9999/";
    #   };
    # };

    homebridge = {
      enable = config.containers.homebridge.config.systemd.services.homebridge.enable or false;
      title = "Homebridge";
      nginx = {
        # proxyPass ではダメ
        # https://github.com/homebridge/homebridge-config-ui-x/issues/628
        return = "301 $scheme://$host:${toString config.containers.homebridge.config.services.homebridge.uiSettings.port}$request_uri";
      };
    };

    zigbee2mqtt = {
      enable = config.services.zigbee2mqtt.settings.frontend.enabled or false;
      nginx = {
        proxyPass = "http://localhost:${toString config.services.zigbee2mqtt.settings.frontend.port}/";
        proxyWebsockets = true;
      };
    };
  };

  enabledContents = lib.filterAttrs (_: { enable ? false, ... }: enable) contents;

  rootHtml = ''
    <html>
      <head>
        <title>おうちシステム</title>
        <style>
          body {
            text-align: center;
            align-content: center;
          }
          ul {
            width: fit-content;
            margin: auto;
          }
        </style>
      </head>
      <body>
        <h1>おうちシステム</h1>
        <ul>${
          let
            toHtml = slug: {title ? slug, ...}: ''<li><a href="/${slug}/">${title}</a></li>'';
          in
          lib.concatStrings (lib.mapAttrsToList toHtml enabledContents)
        }</ul>
      </body>
    </html>
  '';
in

{
  services.nginx = {
    enable = true;

    virtualHosts."home.local" = {
      default = true;
      locations = {
        "/".root = pkgs.writeTextDir "index.html" rootHtml;
      } // lib.mapAttrs' (slug: { nginx, ... }: lib.nameValuePair "/${slug}/" nginx) enabledContents;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
