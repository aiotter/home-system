{
  callPackage,
  home-assistant,
}:

let
  pythonCallPackage = home-assistant.python.pkgs.callPackage;
in

{
  setup_assistant = pythonCallPackage ./setup_assistant { };
  ef_ble = pythonCallPackage ./ef_ble.nix { };
  utils = callPackage ./utils.nix { };
}
