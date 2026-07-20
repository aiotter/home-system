{
  deployment.keys = {
    cloudflared-token = {
      keyCommand = [ "sh" "-c" "printf %s \"\${TUNNEL_TOKEN:?undefined}\"" ];
      destDir = "/var/keys"; # permanent
      permissions = "0600";
    };

    homepage-dashboard-unifi-password = {
      keyCommand = [ "sh" "-c" "printf %s \"\${HOMEPAGE_DASHBOARD_UNIFI_PASSWORD:?undefined}\"" ];
      destDir = "/var/keys"; # permanent
      permissions = "0600";
    };
  };
}
