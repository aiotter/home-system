{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "127.0.0.1";
        acl = [ "topic readwrite #" ];
        settings.allow_anonymous = true;
      }
      {
        address = "::1";
        acl = [ "topic readwrite #" ];
        settings.allow_anonymous = true;
      }
    ];
  };
}
