{ pkgs, lib, config, ... }:

{
  deployment.keys = {
    cloudflared-token.keyCommand = [ "printenv" "TUNNEL_TOKEN" ];
    # "cloudflared-credential.json".keyCommand = [ "printenv" "TUNNEL_CREDENTIAL" ];
  };
}
