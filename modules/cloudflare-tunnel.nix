{ pkgs, lib, config, ... }:

let
  public-keys = [
    # Cloudflare short-lived CA
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGGucn5vE5q4Rk5ulsFVUAVSwQVbSEcwl0R7bxJk84bQdpPJwGknDJtDvbI07Azys81qTP4uDTYhmveGTqn4AyE= open-ssh-ca@cloudflareaccess.org"

    # Cloudflare SSH CA (Access for Infrastructure)
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBADnXTRi0epgyH2NkIY1wNFOdcF6kX7YgKotAoPf/2fZ4nG09mPD0Z5Vr+IHmhrN8KLw6E2U41ljab7FrmPnIf0= open-ssh-ca@cloudflareaccess.org"
  ];
in

{
  systemd.services.cloudflared-tunnel-home =
    let
      tokenFile = with config.deployment.keys.cloudflared-token; "${destDir}/${name}";
      tokenService = "${config.deployment.keys.cloudflared-token.name}-key.service";
      # credentialFile = with config.deployment.keys."cloudflared-credential.json"; "${destDir}/${name}";

      # https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/configuration-file/
      configFile = pkgs.writeText "cloudflared.yml" (builtins.toJSON {
        # tunnel = "020a00ad-9300-4070-849f-c730eebdd888";
        # credentials-file = credentialFile;
        ingress = [
          { hostname = "home.aiotter.com"; service = "ssh://127.0.0.1"; }
          { service = "http_status:404"; }
        ];
        warp-routing.enabled = true;
      });

      serviceCommand = pkgs.writeShellScript
        "cloudflared-tunnel-run-home"
        "TUNNEL_TOKEN=$(cat ${tokenFile}) ${lib.getExe pkgs.cloudflared} tunnel --no-autoupdate --config=${configFile} --protocol=http2 run";
    in
    {
      after = [ "network.target" "network-online.target" tokenService ];
      wants = [ "network.target" "network-online.target" tokenService ];
      wantedBy = [ "multi-user.target" ];
      # unitConfig.ConditionPathExists = tokenFile;
      serviceConfig = {
        ExecStart = serviceCommand;
        Restart = "on-failure";
      };
    };

  users.users.aiotter.openssh.authorizedKeys.keys = public-keys;
  environment.etc."ssh/ca.pub" = { mode = "600"; text = lib.concatStringsSep "\n" public-keys; };

  services.openssh = {
    settings = {
      TrustedUserCAKeys = "/etc/ssh/ca.pub";
      Macs = [ "hmac-sha2-256" "hmac-sha2-512" ];
    };
    extraConfig = ''
      # Cloudflare Access 経由でのログインはすべて aiotter としてログインできる
      # https://developers.cloudflare.com/cloudflare-one/applications/non-http/short-lived-certificates-legacy/
      Match User aiotter
        AuthorizedPrincipalsCommand ${pkgs.lib.getExe pkgs.bash} -c "echo '%t %k' | ssh-keygen -L -f - | grep -A1 Principals"
        AuthorizedPrincipalsCommandUser nobody
    '';
  };
}
