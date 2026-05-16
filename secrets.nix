{
  deployment.keys = {
    cloudflared-token = {
      keyCommand = [ "printenv" "TUNNEL_TOKEN" ];
      destDir = "/var/keys"; # permanent
      permissions = "0600";
    };

    # "cloudflared-credential.json" = {
    #   keyCommand = [ "printenv" "TUNNEL_CREDENTIAL" ];
    #   destDir = "/var/keys"; # permanent
    #   permissions = "0600";
    # };

    homepage-dashboard-unifi-password = {
      keyCommand = [ "sh" "-c" "printf %s \"\${HOMEPAGE_DASHBOARD_UNIFI_PASSWORD:?undefined}\"" ];
      destDir = "/var/keys"; # permanent
      permissions = "0600";
    };
  };
}
