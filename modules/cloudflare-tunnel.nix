{ pkgs, lib, config, ... }:

let
  public-key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGGucn5vE5q4Rk5ulsFVUAVSwQVbSEcwl0R7bxJk84bQdpPJwGknDJtDvbI07Azys81qTP4uDTYhmveGTqn4AyE= open-ssh-ca@cloudflareaccess.org";
in

{
  deployment.keys = {
    cloudflared-token.keyCommand = [ "printenv" "TUNNEL_TOKEN" ];
    # "cloudflared-credential.json".keyCommand = [ "printenv" "TUNNEL_CREDENTIAL" ];
  };

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
  users.users.aiotter.openssh.authorizedKeys.keys = [ public-key ];
}
