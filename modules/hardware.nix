{
  hardware = {
    raspberry-pi."4".bluetooth.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
