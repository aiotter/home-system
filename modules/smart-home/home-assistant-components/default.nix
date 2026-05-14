{
  home-assistant,
}:

let
  inherit (home-assistant.python.pkgs) callPackage;
in

{
  setup_assistant = callPackage ./setup_assistant { };
  ef_ble = callPackage ./ef_ble.nix { };
}
