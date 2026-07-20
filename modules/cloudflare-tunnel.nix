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
    in
    {
      after = [ "network.target" "network-online.target" tokenService ];
      wants = [ "network.target" "network-online.target" ];
      requires = [ tokenService ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.AssertFileNotEmpty = tokenFile;
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.cloudflared} tunnel --no-autoupdate --protocol=http2 run --token-file ${tokenFile}";
        Restart = "on-failure";
      };
      # environment.TUNNEL_LOGLEVEL = "debug";
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
